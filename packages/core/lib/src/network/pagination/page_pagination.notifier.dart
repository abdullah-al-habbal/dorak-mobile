import 'package:flutter/foundation.dart';

import 'package:core/src/network/exceptions/api.exception.dart';
import 'package:core/src/network/paginated_data.dto.dart';

class PagePaginationNotifier<T> extends ChangeNotifier {
  final Future<PaginatedData<T>> Function({required int page, int perPage}) fetch;
  final int perPage;

  PagePaginationNotifier({required this.fetch, this.perPage = 15});

  List<T> _items = const [];
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = false;
  ApiException? _error;

  List<T> get items => List.unmodifiable(_items);
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasNext => _totalPages == 0 || _currentPage < _totalPages;
  bool get hasPrev => _currentPage > 1;
  bool get isLoading => _isLoading;
  ApiException? get error => _error;

  Future<void> loadFirst() => goTo(1);

  Future<void> next() async {
    if (hasNext && !_isLoading) await goTo(_currentPage + 1);
  }

  Future<void> previous() async {
    if (hasPrev && !_isLoading) await goTo(_currentPage - 1);
  }

  Future<void> refresh() => goTo(_currentPage);

  Future<void> goTo(int page) async {
    if (page < 1) page = 1;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await fetch(page: page, perPage: perPage);
      _items = result.data;
      _currentPage = result.meta.currentPage;
      _totalPages = result.meta.totalPages;
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
