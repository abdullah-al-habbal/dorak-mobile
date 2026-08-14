import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show ScrollController;

import 'package:core/src/network/exceptions/api.exception.dart';
import 'package:core/src/network/paginated_data.dto.dart';

class ScrollPaginationNotifier<T> extends ChangeNotifier {
  final Future<PaginatedData<T>> Function({required int page, int perPage}) fetch;
  final int perPage;
  final double loadMoreThreshold;

  ScrollPaginationNotifier({
    required this.fetch,
    this.perPage = 15,
    this.loadMoreThreshold = 200,
  });

  List<T> _items = const [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  ApiException? _error;

  List<T> get items => List.unmodifiable(_items);
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  ApiException? get error => _error;

  Future<void> loadFirst() async {
    _items = const [];
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    await _loadNext();
  }

  Future<void> refresh() => loadFirst();

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await _loadNext();
  }

  void onScroll(ScrollController controller) {
    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - loadMoreThreshold) {
      loadMore();
    }
  }

  Future<void> _loadNext() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await fetch(page: _currentPage + 1, perPage: perPage);
      _items = [..._items, ...result.data];
      _currentPage = result.meta.currentPage;
      _hasMore = result.data.isNotEmpty && _currentPage < result.meta.totalPages;
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
