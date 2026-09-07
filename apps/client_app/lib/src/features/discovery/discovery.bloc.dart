import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/discovery/discovery.event.dart';
import 'package:client_app/src/features/discovery/discovery.state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  DiscoveryBloc(
    this._repository,
    this._locationProvider, {
    this._cache,
    DateTime Function()? clock,
  })  : _now = clock ?? DateTime.now,
        super(const DiscoveryState()) {
    on<DiscoveryLocationRequested>(_onLocationRequested);
    on<DiscoveryUniverseChanged>(_onUniverseChanged);
    on<DiscoveryFiltersChanged>(_onFiltersChanged);
    on<DiscoveryLoadMoreRequested>(_onLoadMore);
    on<DiscoveryRefreshRequested>(_onRefresh);
    on<DiscoveryRetryRequested>(_onRetry);
  }

  final ExploreRepository _repository;
  final LocationProvider _locationProvider;
  final FeedCache? _cache;
  final DateTime Function() _now;

  Future<void> _onLocationRequested(
    DiscoveryLocationRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    final status = await _locationProvider.ensurePermission();
    if (emit.isDone) return;
    if (status != LocationPermissionStatus.granted) {
      emit(state.copyWith(locationStatus: status));
      return;
    }
    final position = await _locationProvider.getCurrentPosition();
    if (emit.isDone) return;
    if (position == null) {
      emit(state.copyWith(locationStatus: status));
      return;
    }
    emit(
      state.copyWith(
        locationStatus: status,
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
    await _loadFirst(emit);
  }

  Future<void> _onUniverseChanged(
    DiscoveryUniverseChanged event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (event.universe == state.filters.universe) return;
    await _evictCurrentKey();
    emit(
      state.copyWith(
        filters: state.filters.copyWith(universe: event.universe),
        page: state.page.reset(),
        isStale: false,
      ),
    );
    await _loadFirst(emit);
  }

  Future<void> _onFiltersChanged(
    DiscoveryFiltersChanged event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (event.filters == state.filters) return;
    await _evictCurrentKey();
    emit(
      state.copyWith(
        filters: event.filters,
        page: state.page.reset(),
        isStale: false,
      ),
    );
    await _loadFirst(emit);
  }

  Future<void> _onLoadMore(
    DiscoveryLoadMoreRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (!state.locationReady || !state.page.hasMore || state.page.isBusy) {
      return;
    }
    emit(state.copyWith(page: state.page.loadingMore()));
    try {
      final page = await _repository.getBranches(
        latitude: state.latitude!,
        longitude: state.longitude!,
        radius: state.filters.radius,
        universe: state.filters.universe,
        page: state.page.meta.currentPage + 1,
        perPage: state.filters.perPage,
        availableNow: state.filters.availableNow,
        priceRangeMin: state.filters.priceRangeMin,
        priceRangeMax: state.filters.priceRangeMax,
        ratingMin: state.filters.ratingMin,
      );
      if (emit.isDone) return;
      emit(state.copyWith(page: state.page.succeeded(page)));
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(page: state.page.failed(error)));
    }
  }

  Future<void> _onRefresh(
    DiscoveryRefreshRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (!state.locationReady) return;
    emit(state.copyWith(page: state.page.refreshing(), isStale: false));
    await _fetchFirst(emit, _cacheKey());
  }

  Future<void> _onRetry(
    DiscoveryRetryRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (!state.locationReady) {
      await _onLocationRequested(const DiscoveryLocationRequested(), emit);
      return;
    }
    if (state.page.hasFailedMore) {
      await _onLoadMore(const DiscoveryLoadMoreRequested(), emit);
      return;
    }
    await _loadFirst(emit);
  }

  Future<void> _loadFirst(Emitter<DiscoveryState> emit) async {
    if (!state.locationReady) return;
    emit(state.copyWith(page: state.page.loadingFirst(), isStale: false));
    final key = _cacheKey();
    if (key != null) {
      final entry = await _cache!.read(key);
      if (emit.isDone) return;
      final cached = entry == null ? null : _parseEntry(entry);
      if (cached != null && entry != null) {
        final stale = entry.isStale(_now());
        emit(state.copyWith(page: state.page.succeeded(cached), isStale: stale));
        if (!stale) return;
      }
    }
    await _fetchFirst(emit, key);
  }

  Future<void> _fetchFirst(Emitter<DiscoveryState> emit, String? key) async {
    try {
      final payload = await _repository.getBranchesPayload(
        latitude: state.latitude!,
        longitude: state.longitude!,
        radius: state.filters.radius,
        universe: state.filters.universe,
        perPage: state.filters.perPage,
        availableNow: state.filters.availableNow,
        priceRangeMin: state.filters.priceRangeMin,
        priceRangeMax: state.filters.priceRangeMax,
        ratingMin: state.filters.ratingMin,
      );
      if (emit.isDone) return;
      if (key != null) {
        await _cache?.write(
          key,
          FeedCacheEntry(
            items: payload.rawItems,
            meta: payload.rawMeta,
            storedAt: _now(),
          ),
        );
        if (emit.isDone) return;
      }
      emit(
        state.copyWith(page: state.page.succeeded(payload.data), isStale: false),
      );
    } catch (error) {
      if (emit.isDone) return;
      if (state.page.items.isNotEmpty) {
        emit(
          state.copyWith(
            page: state.page.succeeded(
              PaginatedData(
                data: state.page.items,
                meta: state.page.meta,
              ),
            ),
            isStale: true,
          ),
        );
      } else {
        emit(state.copyWith(page: state.page.failed(error)));
      }
    }
  }

  String? _cacheKey() {
    final cache = _cache;
    final latitude = state.latitude;
    final longitude = state.longitude;
    if (cache == null || latitude == null || longitude == null) return null;
    return cache.keyFor(
      universe: state.filters.universe,
      latitude: latitude,
      longitude: longitude,
      radius: state.filters.radius,
      perPage: state.filters.perPage,
    );
  }

  Future<void> _evictCurrentKey() async {
    final key = _cacheKey();
    if (key != null) await _cache?.evict(key);
  }

  PaginatedData<BranchDto>? _parseEntry(FeedCacheEntry entry) {
    try {
      final items = entry.items
          .map(
            (item) => BranchDto.fromJson(
              (item as Map).cast<String, dynamic>(),
            ),
          )
          .toList();
      final pagination = entry.meta['pagination'];
      final meta = pagination is Map
          ? PaginationMeta.fromJson(pagination.cast<String, dynamic>())
          : const PaginationMeta.empty();
      return PaginatedData(data: items, meta: meta);
    } catch (_) {
      return null;
    }
  }
}
