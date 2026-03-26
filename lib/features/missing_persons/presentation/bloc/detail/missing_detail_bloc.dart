import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/missing_person_entity.dart';
import '../../../domain/usecases/get_missing_person_detail.dart';

part 'missing_detail_event.dart';
part 'missing_detail_state.dart';

class MissingDetailBloc
    extends Bloc<MissingDetailEvent, MissingDetailState> {
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
    // If the entity was passed directly (from list extra), use it immediately
    // and skip the network call
    if (event.prefetched != null) {
      emit(state.copyWith(
        status: MissingDetailStatus.success,
        person: event.prefetched,
      ));
      return;
    }

    emit(state.copyWith(status: MissingDetailStatus.loading));

    final (person, failure) = await _getDetail(
      GetMissingPersonDetailParams(
        id: event.id,
        isInterpolCase: event.isInterpolCase,
      ),
    );

    if (failure != null) {
      emit(state.copyWith(status: MissingDetailStatus.failure));
      return;
    }

    emit(state.copyWith(
      status: MissingDetailStatus.success,
      person: person,
    ));
  }
}
