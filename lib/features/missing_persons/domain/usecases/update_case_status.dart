import 'package:where_am_i/core/enums/enums.dart';

import '../repositories/i_missing_person_repository.dart';
import '../../../../core/error/failures.dart';
import 'base_use_case.dart';

class UpdateCaseStatus extends UseCase<bool, UpdateCaseStatusParams> {
  final IMissingPersonRepository _repository;

  UpdateCaseStatus(this._repository);

  @override
  Future<(bool?, Failure?)> call(UpdateCaseStatusParams params) {
    return _repository.updateCaseStatus(
      firestoreId: params.firestoreId,
      status: params.status,
    );
  }
}

class UpdateCaseStatusParams {
  final String firestoreId;
  final CaseStatus status;

  const UpdateCaseStatusParams({
    required this.firestoreId,
    required this.status,
  });
}
