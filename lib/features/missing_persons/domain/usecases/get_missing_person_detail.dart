import '../entities/missing_person_entity.dart';
import '../repositories/i_missing_person_repository.dart';
import '../../../../core/error/failures.dart';
import 'base_use_case.dart';

class GetMissingPersonDetail
    extends UseCase<MissingPersonEntity, GetMissingPersonDetailParams> {
  final IMissingPersonRepository _repository;

  GetMissingPersonDetail(this._repository);

  @override
  Future<(MissingPersonEntity?, Failure?)> call(
    GetMissingPersonDetailParams params,
  ) {
    return _repository.getMissingPersonDetail(
      id: params.id,
      isInterpolCase: params.isInterpolCase,
    );
  }
}

class GetMissingPersonDetailParams {
  final String id;
  final bool isInterpolCase;
  const GetMissingPersonDetailParams({
    required this.id,
    required this.isInterpolCase,
  });
}
