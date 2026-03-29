import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/missing_person_entity.dart';
import '../../../domain/usecases/get_missing_persons.dart';
import '../../../domain/value_objects/missing_person_filter.dart';
import '../../../../../../core/enums/enums.dart';

part 'missing_list_event.dart';
part 'missing_list_state.dart';

class MissingListBloc extends Bloc<MissingListEvent, MissingListState> {
  final GetMissingPersons _getMissingPersons;

  // Debounce timer for search
  Timer? _searchDebounce;
  static const _debounceDuration = Duration(milliseconds: 450);

  MissingListBloc({required GetMissingPersons getMissingPersons})
      : _getMissingPersons = getMissingPersons,
        super(const MissingListState()) {
    on<MissingListFetched>(_onFetched);
    on<MissingListNextPage>(_onNextPage);
    on<MissingListSearchChanged>(_onSearchChanged);
    on<MissingListFilterChanged>(_onFilterChanged);
    on<MissingListFilterCleared>(_onFilterCleared);
    on<MissingListSortChanged>(_onSortChanged);
    on<MissingListRefreshed>((_, emit) async {
      emit(state.copyWith(
        status: MissingListStatus.initial,
        persons: [],
        hasMore: true,
        currentPage: 1,
        hasReachedMax: false,
      ));
      add(const MissingListFetched());
    });
  }

  // ── Handlers ──────────────────────────────────────────────────

  Future<void> _onFetched(
    MissingListFetched event,
    Emitter<MissingListState> emit,
  ) async {
    emit(state.copyWith(status: MissingListStatus.loading));
    await _fetch(emit, filter: state.filter.resetPage());
  }

  Future<void> _onNextPage(
    MissingListNextPage event,
    Emitter<MissingListState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(status: MissingListStatus.loadingMore));
    final nextFilter = state.filter.copyWith(page: state.filter.page + 1);
    await _fetch(emit, filter: nextFilter, append: true);
  }

  Future<void> _onSearchChanged(
    MissingListSearchChanged event,
    Emitter<MissingListState> emit,
  ) async {
    _searchDebounce?.cancel();

    final completer = Completer<void>();
    _searchDebounce = Timer(_debounceDuration, () async {
      final newFilter = state.filter
          .copyWith(searchQuery: event.query.isEmpty ? null : event.query)
          .resetPage();
      emit(state.copyWith(
        status: MissingListStatus.loading,
        filter: newFilter,
      ));
      await _fetch(emit, filter: newFilter);
      completer.complete();
    });

    await completer.future;
  }

  Future<void> _onFilterChanged(
    MissingListFilterChanged event,
    Emitter<MissingListState> emit,
  ) async {
    final newFilter = event.filter.resetPage();
    emit(state.copyWith(
      status: MissingListStatus.loading,
      filter: newFilter,
    ));
    await _fetch(emit, filter: newFilter);
  }

  Future<void> _onFilterCleared(
    MissingListFilterCleared event,
    Emitter<MissingListState> emit,
  ) async {
    final cleared = MissingPersonFilter.initial();
    emit(state.copyWith(
      status: MissingListStatus.loading,
      filter: cleared,
    ));
    await _fetch(emit, filter: cleared);
  }

  Future<void> _onSortChanged(
    MissingListSortChanged event,
    Emitter<MissingListState> emit,
  ) async {
    final newFilter = state.filter.copyWith(sortOrder: event.order).resetPage();
    emit(state.copyWith(
      status: MissingListStatus.loading,
      filter: newFilter,
    ));
    await _fetch(emit, filter: newFilter);
  }

  // ── Core fetch ────────────────────────────────────────────────

  Future<void> _fetch(
    Emitter<MissingListState> emit, {
    required MissingPersonFilter filter,
    bool append = false,
  }) async {
    final (result, failure) = await _getMissingPersons(
      GetMissingPersonsParams(filter: filter),
    );

    if (failure != null) {
      emit(state.copyWith(
        status: MissingListStatus.failure,
        errorMessage: failure.message,
      ));
      return;
    }

    final newItems = result?.items ?? [];
    final allItems = append ? [...state.persons, ...newItems] : newItems;

    emit(state.copyWith(
      status: MissingListStatus.success,
      persons: allItems,
      filter: filter,
      hasMore: result?.hasMore ?? false,
      errorMessage: null,
    ));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
