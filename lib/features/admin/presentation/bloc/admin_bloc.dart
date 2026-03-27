import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:where_am_i/features/missing_persons/domain/usecases/base_use_case.dart';

import '../../../missing_persons/domain/entities/missing_person_entity.dart';
import '../../../missing_persons/domain/usecases/get_pending_cases.dart';
import '../../../missing_persons/domain/usecases/update_case_status.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/error/failures.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPendingCases _getPendingCases;
  final UpdateCaseStatus _updateCaseStatus;

  AdminBloc({
    required GetPendingCases getPendingCases,
    required UpdateCaseStatus updateCaseStatus,
  })  : _getPendingCases = getPendingCases,
        _updateCaseStatus = updateCaseStatus,
        super(const AdminState()) {
    on<AdminPendingCasesLoaded>(_onLoaded);
    on<AdminCaseApproved>(_onApproved);
    on<AdminCaseRejected>(_onRejected);
  }

  Future<void> _onLoaded(
    AdminPendingCasesLoaded event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final (cases, failure) = await _getPendingCases(const NoParams());
    if (failure != null) {
      emit(state.copyWith(
        status: AdminStatus.failure,
        errorMessage: _map(failure),
      ));
      return;
    }
    emit(state.copyWith(
      status: AdminStatus.success,
      cases: cases ?? [],
    ));
  }

  Future<void> _onApproved(
    AdminCaseApproved event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(processingId: event.firestoreId));
    final (_, failure) = await _updateCaseStatus(
      UpdateCaseStatusParams(
        firestoreId: event.firestoreId,
        status: CaseStatus.approved,
      ),
    );
    if (failure != null) {
      emit(state.copyWith(
        processingId: null,
        errorMessage: _map(failure),
      ));
      return;
    }
    final updated =
        state.cases.where((c) => c.firestoreId != event.firestoreId).toList();
    emit(state.copyWith(
      cases: updated,
      processingId: null,
      lastActionMessage: 'Case approved and published.',
    ));
  }

  Future<void> _onRejected(
    AdminCaseRejected event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(processingId: event.firestoreId));
    final (_, failure) = await _updateCaseStatus(
      UpdateCaseStatusParams(
        firestoreId: event.firestoreId,
        status: CaseStatus.rejected,
      ),
    );
    if (failure != null) {
      emit(state.copyWith(
        processingId: null,
        errorMessage: _map(failure),
      ));
      return;
    }
    final updated =
        state.cases.where((c) => c.firestoreId != event.firestoreId).toList();
    emit(state.copyWith(
      cases: updated,
      processingId: null,
      lastActionMessage: 'Case rejected.',
    ));
  }

  String _map(Failure f) {
    if (f is NetworkFailure) return 'No connection. Try again.';
    if (f is AuthFailure) return 'Admin access required.';
    return 'Something went wrong.';
  }
}
