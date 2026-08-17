import 'package:equatable/equatable.dart';

import 'package:core/src/network/page_status.entity.dart';
import 'package:core/src/network/page_trigger.entity.dart';
import 'package:core/src/network/paginated_data.dto.dart';
import 'package:core/src/network/pagination_meta.dto.dart';

class Paged<T> extends Equatable {
  const Paged._({
    required this.items,
    required this.meta,
    required this.status,
    required this.trigger,
    this.error,
  });

  const Paged.initial()
      : items = const [],
        meta = const PaginationMeta.empty(),
        status = PageStatus.initial,
        trigger = PageTrigger.first,
        error = null;

  final List<T> items;
  final PaginationMeta meta;
  final PageStatus status;
  final PageTrigger trigger;
  final Object? error;

  bool get hasMore => meta.currentPage < meta.totalPages;
  bool get isEmpty => status == PageStatus.success && items.isEmpty;
  bool get isEndOfList => items.isNotEmpty && !hasMore;

  bool get isBusy => status == PageStatus.loading;
  bool get isFirstLoad => isBusy && trigger == PageTrigger.first;
  bool get isLoadingMore => isBusy && trigger == PageTrigger.more;
  bool get isRefreshing => isBusy && trigger == PageTrigger.refresh;

  bool get hasFailed => status == PageStatus.failure;
  bool get hasFailedFirst => hasFailed && trigger == PageTrigger.first;
  bool get hasFailedMore => hasFailed && trigger == PageTrigger.more;
  bool get hasFailedRefresh => hasFailed && trigger == PageTrigger.refresh;

  Paged<T> loadingFirst() => Paged<T>._(
        items: items,
        meta: meta,
        status: PageStatus.loading,
        trigger: PageTrigger.first,
      );

  Paged<T> loadingMore() => Paged<T>._(
        items: items,
        meta: meta,
        status: PageStatus.loading,
        trigger: PageTrigger.more,
      );

  Paged<T> refreshing() => Paged<T>._(
        items: items,
        meta: meta,
        status: PageStatus.loading,
        trigger: PageTrigger.refresh,
      );

  Paged<T> succeeded(PaginatedData<T> page) => Paged<T>._(
        items: List<T>.unmodifiable(
          trigger == PageTrigger.more ? [...items, ...page.data] : page.data,
        ),
        meta: page.meta,
        status: PageStatus.success,
        trigger: trigger,
      );

  Paged<T> failed(Object error) => Paged<T>._(
        items: items,
        meta: meta,
        status: PageStatus.failure,
        trigger: trigger,
        error: error,
      );

  Paged<T> reset() => Paged<T>.initial();

  @override
  List<Object?> get props => [
        items,
        meta.total,
        meta.count,
        meta.perPage,
        meta.currentPage,
        meta.totalPages,
        status,
        trigger,
        error,
      ];
}
