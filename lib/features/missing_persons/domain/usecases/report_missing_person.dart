import '../entities/missing_person_entity.dart';
import '../repositories/i_missing_person_repository.dart';
import '../../../../core/error/failures.dart';
import 'base_use_case.dart';

class ReportMissingPerson
    extends UseCase<MissingPersonEntity, ReportMissingPersonParams> {
  final IMissingPersonRepository _repository;

  ReportMissingPerson(this._repository);

  @override
  Future<(MissingPersonEntity?, Failure?)> call(
    ReportMissingPersonParams params,
  ) async {
    // Validate required fields before hitting the repo
    if (params.person.name.trim().isEmpty) {
      return (null, const ValidationFailure('Name is required.'));
    }
    if (params.person.lastSeenDate == null) {
      return (null, const ValidationFailure('Last seen date is required.'));
    }
    if (params.person.lastSeenLocation == null ||
        params.person.lastSeenLocation!.trim().isEmpty) {
      return (null, const ValidationFailure('Last seen location is required.'));
    }

    return _repository.reportMissingPerson(
      person: params.person,
      localPhotoPaths: params.localPhotoPaths,
    );
  }
}

class ReportMissingPersonParams {
  final MissingPersonEntity person;
  final List<String> localPhotoPaths;

  const ReportMissingPersonParams({
    required this.person,
    this.localPhotoPaths = const [],
  });
}
