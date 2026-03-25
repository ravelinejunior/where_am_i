import 'package:where_am_i/core/enums/enums.dart';

import '../entities/missing_person_entity.dart';
import '../value_objects/missing_person_filter.dart';
import '../value_objects/paginated_result.dart';
import '../../../../core/error/failures.dart';

/// Contract for the missing persons data layer.
/// The domain layer depends ONLY on this interface — never on implementations.
abstract interface class IMissingPersonRepository {
  /// Returns a paginated, merged list from all active sources (Interpol + Firestore).
  /// Applies [filter] for search, sex, age, nationality, last-seen, and pagination.
  Future<(PaginatedResult<MissingPersonEntity>?, Failure?)> getMissingPersons({
    required MissingPersonFilter filter,
  });

  /// Returns the full detail for a single case by [id].
  /// [id] may be an Interpol notice ID or a Firestore document ID.
  Future<(MissingPersonEntity?, Failure?)> getMissingPersonDetail({
    required String id,
    required bool isInterpolCase,
  });

  /// Submits a new community-reported case to Firestore.
  /// Returns the created entity (with assigned ID) on success.
  Future<(MissingPersonEntity?, Failure?)> reportMissingPerson({
    required MissingPersonEntity person,
    required List<String> localPhotoPaths,
  });

  /// Updates the [status] of a case — admin only.
  Future<(bool, Failure?)> updateCaseStatus({
    required String firestoreId,
    required CaseStatus status,
  });

  /// Returns all pending community cases awaiting admin approval.
  Future<(List<MissingPersonEntity>, Failure?)> getPendingCases();

  /// Streams real-time updates for a single Firestore case.
  Stream<MissingPersonEntity?> watchCase(String firestoreId);
}
