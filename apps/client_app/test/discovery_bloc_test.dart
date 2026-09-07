import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/discovery/discovery.bloc.dart';
import 'package:client_app/src/features/discovery/discovery.event.dart';
import 'package:client_app/src/features/discovery/discovery.state.dart';
import 'package:client_app/src/features/discovery/discovery_filter.entity.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeExploreRepository repository;
  late FakeLocationProvider location;
  late FakeFeedCache cache;

  setUp(() {
    repository = FakeExploreRepository();
    location = FakeLocationProvider();
    cache = FakeFeedCache();
  });

  DiscoveryBloc bloc() => DiscoveryBloc(repository, location, cache: cache);

  group('initial state', () {
    test('asks for location before anything else', () {
      expect(
        bloc().state,
        const DiscoveryState(
          page: Paged<BranchDto>.initial(),
        ),
      );
    });
  });

  group('DiscoveryLocationRequested', () {
    blocTest<DiscoveryBloc, DiscoveryState>(
      'denied permission stays on the location prompt',
      build: bloc,
      setUp: () => location.status = LocationPermissionStatus.denied,
      act: (bloc) => bloc.add(const DiscoveryLocationRequested()),
      expect: () => [
        const DiscoveryState(
          locationStatus: LocationPermissionStatus.denied,
          page: Paged<BranchDto>.initial(),
        ),
      ],
      verify: (_) {
        expect(repository.getBranchesPayloadCalls, 0);
      },
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'granted permission with a fix loads the first page and writes cache',
      build: bloc,
      act: (bloc) => bloc.add(const DiscoveryLocationRequested()),
      verify: (bloc) {
        expect(bloc.state.locationReady, isTrue);
        expect(bloc.state.page.items, hasLength(1));
        expect(bloc.state.page.items.first.name, 'Branch 1');
        expect(bloc.state.isStale, isFalse);
        expect(cache.writeCalls, 1);
      },
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'granted permission without a fix stays on the location prompt',
      build: bloc,
      setUp: () => location.position = null,
      act: (bloc) => bloc.add(const DiscoveryLocationRequested()),
      expect: () => [
        const DiscoveryState(
          locationStatus: LocationPermissionStatus.granted,
          page: Paged<BranchDto>.initial(),
        ),
      ],
      verify: (_) {
        expect(repository.getBranchesPayloadCalls, 0);
      },
    );
  });

  group('cache', () {
    blocTest<DiscoveryBloc, DiscoveryState>(
      'fresh cache renders without touching the network',
      build: bloc,
      setUp: () {
        final key = cache.keyFor(
          universe: 'men',
          latitude: 24.7136,
          longitude: 46.6753,
          radius: 10,
        );
        cache.entries[key] = FeedCacheEntry(
          items: const [
            {
              'id': 9,
              'name': 'Cached Branch',
              'email': 'cached@example.com',
              'status': 'approved',
              'latitude': 24.7136,
              'longitude': 46.6753,
              'brand_id': 7,
            },
          ],
          meta: const {
            'pagination': {
              'total': 1,
              'count': 1,
              'per_page': 20,
              'current_page': 1,
              'total_pages': 1,
            },
          },
          storedAt: DateTime.now(),
        );
      },
      act: (bloc) => bloc.add(const DiscoveryLocationRequested()),
      verify: (bloc) {
        expect(bloc.state.page.items.first.name, 'Cached Branch');
        expect(bloc.state.isStale, isFalse);
        expect(repository.getBranchesPayloadCalls, 0);
      },
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'stale cache renders first, then revalidates from the network',
      build: bloc,
      setUp: () {
        final key = cache.keyFor(
          universe: 'men',
          latitude: 24.7136,
          longitude: 46.6753,
          radius: 10,
        );
        cache.entries[key] = FeedCacheEntry(
          items: const [
            {
              'id': 9,
              'name': 'Cached Branch',
              'email': 'cached@example.com',
              'status': 'approved',
              'latitude': 24.7136,
              'longitude': 46.6753,
              'brand_id': 7,
            },
          ],
          meta: const {
            'pagination': {
              'total': 1,
              'count': 1,
              'per_page': 20,
              'current_page': 1,
              'total_pages': 1,
            },
          },
          storedAt: DateTime.utc(2020, 1, 1),
        );
      },
      act: (bloc) => bloc.add(const DiscoveryLocationRequested()),
      verify: (bloc) {
        expect(repository.getBranchesPayloadCalls, 1);
        expect(bloc.state.page.items.first.name, 'Branch 1');
        expect(bloc.state.isStale, isFalse);
      },
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'offline with a stale cache keeps the cached items marked stale',
      build: bloc,
      setUp: () {
        repository.error = offline();
        final key = cache.keyFor(
          universe: 'men',
          latitude: 24.7136,
          longitude: 46.6753,
          radius: 10,
        );
        cache.entries[key] = FeedCacheEntry(
          items: const [
            {
              'id': 9,
              'name': 'Cached Branch',
              'email': 'cached@example.com',
              'status': 'approved',
              'latitude': 24.7136,
              'longitude': 46.6753,
              'brand_id': 7,
            },
          ],
          meta: const {
            'pagination': {
              'total': 1,
              'count': 1,
              'per_page': 20,
              'current_page': 1,
              'total_pages': 1,
            },
          },
          storedAt: DateTime.utc(2020, 1, 1),
        );
      },
      act: (bloc) => bloc.add(const DiscoveryLocationRequested()),
      verify: (bloc) {
        expect(bloc.state.page.items.first.name, 'Cached Branch');
        expect(bloc.state.isStale, isTrue);
        expect(bloc.state.page.hasFailed, isFalse);
      },
    );
  });

  group('failures', () {
    blocTest<DiscoveryBloc, DiscoveryState>(
      'first load with no cache fails the page',
      build: bloc,
      setUp: () => repository.error = offline(),
      act: (bloc) => bloc.add(const DiscoveryLocationRequested()),
      verify: (bloc) {
        expect(bloc.state.page.hasFailedFirst, isTrue);
        expect(bloc.state.page.items, isEmpty);
      },
    );
  });

  group('DiscoveryUniverseChanged', () {
    blocTest<DiscoveryBloc, DiscoveryState>(
      'evicts the old universe key and reloads',
      build: bloc,
      seed: () => DiscoveryState(
        locationStatus: LocationPermissionStatus.granted,
        latitude: 24.7136,
        longitude: 46.6753,
        page: Paged<BranchDto>.initial().succeeded(testBranchPage()),
      ),
      act: (bloc) => bloc.add(const DiscoveryUniverseChanged('women')),
      verify: (bloc) {
        expect(bloc.state.filters.universe, 'women');
        expect(repository.lastUniverse, 'women');
        expect(
          cache.evictedKeys,
          contains(
            cache.keyFor(
              universe: 'men',
              latitude: 24.7136,
              longitude: 46.6753,
              radius: 10,
            ),
          ),
        );
      },
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'same universe is a no-op',
      build: bloc,
      seed: () => const DiscoveryState(
        locationStatus: LocationPermissionStatus.granted,
        latitude: 24.7136,
        longitude: 46.6753,
      ),
      act: (bloc) => bloc.add(const DiscoveryUniverseChanged('men')),
      expect: () => [],
      verify: (_) {
        expect(repository.getBranchesPayloadCalls, 0);
      },
    );
  });

  group('DiscoveryFiltersChanged', () {
    blocTest<DiscoveryBloc, DiscoveryState>(
      'forwards the available-now filter to the query',
      build: bloc,
      seed: () => const DiscoveryState(
        locationStatus: LocationPermissionStatus.granted,
        latitude: 24.7136,
        longitude: 46.6753,
      ),
      act: (bloc) => bloc.add(
        const DiscoveryFiltersChanged(
          DiscoveryFilters(availableNow: true),
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.filters.availableNow, isTrue);
        expect(repository.lastAvailableNow, isTrue);
      },
    );
  });

  group('pagination', () {
    blocTest<DiscoveryBloc, DiscoveryState>(
      'load more appends the next page',
      build: bloc,
      seed: () => DiscoveryState(
        locationStatus: LocationPermissionStatus.granted,
        latitude: 24.7136,
        longitude: 46.6753,
        page: Paged<BranchDto>.initial().succeeded(
          testBranchPage(branches: [testBranch(id: 1)], totalPages: 2),
        ),
      ),
      setUp: () {
        repository.morePage = testBranchPage(
          branches: [testBranch(id: 2)],
          currentPage: 2,
          totalPages: 2,
        );
      },
      act: (bloc) => bloc.add(const DiscoveryLoadMoreRequested()),
      verify: (bloc) {
        expect(repository.lastPage, 2);
        expect(
          bloc.state.page.items.map((branch) => branch.id),
          [1, 2],
        );
      },
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'load more failure keeps the loaded items',
      build: bloc,
      seed: () => DiscoveryState(
        locationStatus: LocationPermissionStatus.granted,
        latitude: 24.7136,
        longitude: 46.6753,
        page: Paged<BranchDto>.initial().succeeded(
          testBranchPage(branches: [testBranch(id: 1)], totalPages: 2),
        ),
      ),
      setUp: () => repository.error = offline(),
      act: (bloc) => bloc.add(const DiscoveryLoadMoreRequested()),
      verify: (bloc) {
        expect(bloc.state.page.hasFailedMore, isTrue);
        expect(bloc.state.page.items, hasLength(1));
      },
    );

    blocTest<DiscoveryBloc, DiscoveryState>(
      'refresh revalidates the first page',
      build: bloc,
      seed: () => DiscoveryState(
        locationStatus: LocationPermissionStatus.granted,
        latitude: 24.7136,
        longitude: 46.6753,
        page: Paged<BranchDto>.initial().succeeded(testBranchPage()),
      ),
      act: (bloc) => bloc.add(const DiscoveryRefreshRequested()),
      verify: (bloc) {
        expect(repository.getBranchesPayloadCalls, 1);
        expect(bloc.state.page.items, hasLength(1));
        expect(bloc.state.isStale, isFalse);
      },
    );
  });

  group('DiscoveryRetryRequested', () {
    blocTest<DiscoveryBloc, DiscoveryState>(
      'retry without location asks for permission first',
      build: bloc,
      act: (bloc) => bloc.add(const DiscoveryRetryRequested()),
      verify: (bloc) {
        expect(location.ensurePermissionCalls, 1);
        expect(bloc.state.locationReady, isTrue);
      },
    );
  });
}
