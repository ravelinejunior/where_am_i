import '../../../../core/error/failures.dart';

/// Base class for all use cases that take [Params] and return [Result].
/// Uses Dart records for lightweight (result, failure) returns — no Either dependency needed.
abstract class UseCase<Result, Params> {
  Future<(Result?, Failure?)> call(Params params);
}

/// For use cases with no parameters.
class NoParams {
  const NoParams();
}
