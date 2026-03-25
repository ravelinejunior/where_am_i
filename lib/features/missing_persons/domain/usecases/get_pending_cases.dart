import '../entities/missing_person_entity.dart';
import '../repositories/i_missing_person_repository.dart';
import '../../../../core/error/failures.dart';
import 'base_use_case.dart';

class GetPendingCases extends UseCase<List<MissingPersonEntity>, NoParams> {
  final IMissingPersonRepository _repository;

  GetPendingCases(this._repository);

  @override
  Future<(List<MissingPersonEntity>?, Failure?)> call(NoParams params) async {
    final (cases, failure) = await _repository.getPendingCases();
    if (failure != null) return (null, failure);
    return (cases, null);
  }
}
