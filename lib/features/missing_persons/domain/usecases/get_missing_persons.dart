import '../entities/missing_person_entity.dart';
import '../repositories/i_missing_person_repository.dart';
import '../value_objects/missing_person_filter.dart';
import '../value_objects/paginated_result.dart';
import '../../../../core/error/failures.dart';
import 'base_use_case.dart';

class GetMissingPersons extends UseCase<PaginatedResult<MissingPersonEntity>,
    GetMissingPersonsParams> {
  final IMissingPersonRepository _repository;

  GetMissingPersons(this._repository);

  @override
  Future<(PaginatedResult<MissingPersonEntity>?, Failure?)> call(
    GetMissingPersonsParams params,
  ) {
    return _repository.getMissingPersons(filter: params.filter);
  }
}

class GetMissingPersonsParams {
  final MissingPersonFilter filter;
  const GetMissingPersonsParams({required this.filter});
}
