part of 'missing_list_bloc.dart';

sealed class MissingListEvent extends Equatable {
  const MissingListEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load or full refresh
final class MissingListFetched extends MissingListEvent {
  const MissingListFetched();
}

/// Load next page (infinite scroll)
final class MissingListNextPage extends MissingListEvent {
  const MissingListNextPage();
}

/// User typed in search box
final class MissingListSearchChanged extends MissingListEvent {
  final String query;
  const MissingListSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// User applied a new filter set
final class MissingListFilterChanged extends MissingListEvent {
  final MissingPersonFilter filter;
  const MissingListFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Clear all active filters
final class MissingListFilterCleared extends MissingListEvent {
  const MissingListFilterCleared();
}

/// Sort order changed
final class MissingListSortChanged extends MissingListEvent {
  final SortOrder order;
  const MissingListSortChanged(this.order);

  @override
  List<Object?> get props => [order];
}
