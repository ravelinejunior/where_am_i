part of 'missing_list_bloc.dart';

enum MissingListStatus { initial, loading, loadingMore, success, failure }

final class MissingListState extends Equatable {
  final MissingListStatus status;
  final List<MissingPersonEntity> persons;
  final MissingPersonFilter filter;
  final bool hasMore;
  final int currentPage;
  final bool hasReachedMax;
  final String? errorMessage;

  const MissingListState({
    this.status = MissingListStatus.initial,
    this.persons = const [],
    this.filter = const MissingPersonFilter(),
    this.hasMore = true,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  bool get isInitial => status == MissingListStatus.initial;
  bool get isLoading => status == MissingListStatus.loading;
  bool get isLoadingMore => status == MissingListStatus.loadingMore;
  bool get isSuccess => status == MissingListStatus.success;
  bool get isFailure => status == MissingListStatus.failure;
  bool get isEmpty => isSuccess && persons.isEmpty;

  MissingListState copyWith({
    MissingListStatus? status,
    List<MissingPersonEntity>? persons,
    MissingPersonFilter? filter,
    bool? hasMore,
    int? currentPage,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return MissingListState(
      status: status ?? this.status,
      persons: persons ?? this.persons,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        persons,
        filter,
        hasMore,
        currentPage,
        hasReachedMax,
        errorMessage
      ];
}
