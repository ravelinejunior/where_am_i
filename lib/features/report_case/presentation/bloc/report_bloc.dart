import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/missing_persons/domain/entities/missing_person_entity.dart';
import '../../../../features/missing_persons/domain/usecases/report_missing_person.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/error/failures.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportMissingPerson _reportMissingPerson;

  ReportBloc({required ReportMissingPerson reportMissingPerson})
      : _reportMissingPerson = reportMissingPerson,
        super(const ReportState()) {
    on<ReportNameChanged>((e, emit) => emit(state.copyWith(name: e.value)));
    on<ReportNationalityChanged>(
        (e, emit) => emit(state.copyWith(nationality: e.value)));
    on<ReportBirthDateChanged>((e, emit) => e.value == null
        ? emit(state.copyWith(clearBirthDate: true))
        : emit(state.copyWith(birthDate: e.value)));
    on<ReportLastSeenDateChanged>((e, emit) => e.value == null
        ? emit(state.copyWith(clearLastSeenDate: true))
        : emit(state.copyWith(lastSeenDate: e.value)));
    on<ReportLastLocationChanged>(
        (e, emit) => emit(state.copyWith(lastSeenLocation: e.value)));
    on<ReportSexChanged>((e, emit) => emit(state.copyWith(sex: e.value)));
    on<ReportHeightChanged>((e, emit) => emit(state.copyWith(height: e.value)));
    on<ReportEyeColorChanged>(
        (e, emit) => emit(state.copyWith(eyeColor: e.value)));
    on<ReportHairColorChanged>(
        (e, emit) => emit(state.copyWith(hairColor: e.value)));
    on<ReportFactsChanged>((e, emit) => emit(state.copyWith(facts: e.value)));
    on<ReportPhotoAdded>(_onPhotoAdded);
    on<ReportPhotoRemoved>(_onPhotoRemoved);
    on<ReportSubmitted>(_onSubmitted);
    on<ReportReset>((_, emit) => emit(const ReportState()));
  }

  void _onPhotoAdded(ReportPhotoAdded event, Emitter<ReportState> emit) {
    if (state.localPhotoPaths.length >= 5) return;
    emit(state.copyWith(
      localPhotoPaths: [...state.localPhotoPaths, event.localPath],
    ));
  }

  void _onPhotoRemoved(ReportPhotoRemoved event, Emitter<ReportState> emit) {
    final updated = List<String>.from(state.localPhotoPaths)
      ..removeAt(event.index);
    emit(state.copyWith(localPhotoPaths: updated));
  }

  Future<void> _onSubmitted(
    ReportSubmitted event,
    Emitter<ReportState> emit,
  ) async {
    if (!state.isFormValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }

    emit(state.copyWith(status: ReportStatus.loading, showErrors: false));

    final (_, failure) = await _reportMissingPerson(
      ReportMissingPersonParams(
        person: _buildEntity(),
        localPhotoPaths: state.localPhotoPaths,
      ),
    );

    if (failure != null) {
      emit(state.copyWith(
        status: ReportStatus.failure,
        errorMessage: _mapFailure(failure),
      ));
      return;
    }

    emit(state.copyWith(status: ReportStatus.success, clearError: true));
  }

  MissingPersonEntity _buildEntity() {
    final factsList = state.facts
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return MissingPersonEntity(
      id: '',
      name: state.name.trim(),
      nationality: state.nationality.trim().isEmpty
          ? null
          : state.nationality.trim().toUpperCase(),
      birthDate: state.birthDate,
      lastSeenDate: state.lastSeenDate,
      lastSeenLocation: state.lastSeenLocation.trim(),
      sex: state.sex,
      heightCm: int.tryParse(state.height.trim()),
      eyeColor: state.eyeColor.trim().isEmpty ? null : state.eyeColor.trim(),
      hairColor: state.hairColor.trim().isEmpty ? null : state.hairColor.trim(),
      facts: factsList,
      source: MissingPersonSource.firebase,
      status: CaseStatus.pending,
    );
  }

  String _mapFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Sem conexão. Verifique sua internet.';
    }
    if (failure is AuthFailure) return 'Você precisa estar conectado.';
    return 'Algo deu errado. Tente novamente.';
  }
}
