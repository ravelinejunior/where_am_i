import 'package:equatable/equatable.dart';

/// Wraps a paginated list response from any datasource.
class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int? totalCount;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    this.totalCount,
  });

  bool get hasMore {
    if (totalCount != null) return currentPage * pageSize < totalCount!;
    return items.length >= pageSize;
  }

  bool get isEmpty => items.isEmpty;

  bool get isFirstPage => currentPage == 1;

  PaginatedResult<T> appendPage(PaginatedResult<T> nextPage) {
    return PaginatedResult<T>(
      items: [...items, ...nextPage.items],
      currentPage: nextPage.currentPage,
      pageSize: nextPage.pageSize,
      totalCount: nextPage.totalCount ?? totalCount,
    );
  }

  @override
  List<Object?> get props => [items, currentPage, pageSize, totalCount];
}
