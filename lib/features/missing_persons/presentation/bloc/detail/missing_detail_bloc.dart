import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/missing_person_entity.dart';
import '../../../domain/usecases/get_missing_person_detail.dart';

part 'missing_detail_event.dart';
part 'missing_detail_state.dart';

class MissingDetailBloc extends Bloc<MissingDetailEvent, MissingDetailState> {
  final GetMissingPersonDetail _getDetail;

  MissingDetailBloc({required GetMissingPersonDetail getDetail})
      : _getDetail = getDetail,
        super(const MissingDetailState()) {
    on<MissingDetailLoaded>(_onLoaded);
  }

  Future<void> _onLoaded(
    MissingDetailLoaded event,
    Emitter<MissingDetailState> emit,
  ) async {
    // For Interpol cases: ALWAYS fetch full detail from the API.
    // The list endpoint returns minimal fields (no place_of_birth,
    // place_of_last_known_location, sex_id, countries_of_visit, etc.).
    // We can show the prefetched data immediately while loading the full detail.
    if (event.prefetched != null) {
      emit(state.copyWith(
        status: MissingDetailStatus.success,
        person: event.prefetched,
      ));
    } else {
      emit(state.copyWith(status: MissingDetailStatus.loading));
    }

    // Always fetch full detail for Interpol cases — list data is incomplete.
    // For Firebase cases, prefetched data is already complete.
    final shouldFetchDetail = event.isInterpolCase || event.prefetched == null;

    if (!shouldFetchDetail) return;

    final (person, failure) = await _getDetail(
      GetMissingPersonDetailParams(
        id: event.id,
        isInterpolCase: event.isInterpolCase,
      ),
    );

    if (failure != null) {
      // If we already have prefetched data, keep showing it
      if (event.prefetched != null) return;
      emit(state.copyWith(status: MissingDetailStatus.failure));
      return;
    }

    emit(state.copyWith(
      status: MissingDetailStatus.success,
      person: person,
    ));
  }
}
