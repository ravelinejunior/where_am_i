import '../../domain/entities/missing_person_entity.dart';
import '../../domain/repositories/i_missing_person_repository.dart';
import '../../domain/value_objects/missing_person_filter.dart';
import '../../domain/value_objects/paginated_result.dart';
import '../datasources/interpol_remote_datasource.dart';
import '../datasources/firestore_remote_datasource.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/error/failures.dart';

class MissingRepositoryImpl implements IMissingPersonRepository {
  final IInterpolRemoteDatasource _interpol;
  final IFirestoreRemoteDatasource _firestore;

  const MissingRepositoryImpl({
    required IInterpolRemoteDatasource interpol,
    required IFirestoreRemoteDatasource firestore,
  })  : _interpol = interpol,
        _firestore = firestore;

  @override
  Future<(PaginatedResult<MissingPersonEntity>?, Failure?)> getMissingPersons({
    required MissingPersonFilter filter,
  }) async {
    final results = <MissingPersonEntity>[];
    Failure? lastFailure;

    // Determine which sources to query
    final fetchInterpol = filter.sources.contains(MissingPersonSource.interpol);
    final fetchFirestore =
        filter.sources.contains(MissingPersonSource.firebase);

    // Query both in parallel where possible
    final futures = await Future.wait([
      if (fetchInterpol) _fetchInterpol(filter) else Future.value(null),
      if (fetchFirestore) _fetchFirestore(filter) else Future.value(null),
    ]);

    final interpolResult = fetchInterpol ? futures[0] : null;
    final firestoreResult =
        fetchFirestore ? futures[fetchInterpol ? 1 : 0] : null;

    if (interpolResult != null) {
      final (entities, failure) = interpolResult;
      if (entities != null) results.addAll(entities);
      if (failure != null) lastFailure = failure;
    }

    if (firestoreResult != null) {
      final (entities, failure) = firestoreResult;
      if (entities != null) results.addAll(entities);
      if (failure != null && lastFailure == null) lastFailure = failure;
    }

    // If both sources failed, surface the error
    if (results.isEmpty && lastFailure != null) {
      return (null, lastFailure);
    }

    // Deduplicate by id
    final seen = <String>{};
    final unique = results.where((e) => seen.add(e.id)).toList();

    // Apply client-side sort after merge
    _sort(unique, filter.sortOrder);

    // Apply client-side text search if query present
    final filtered = _applySearch(unique, filter.searchQuery);

    return (
      PaginatedResult<MissingPersonEntity>(
        items: filtered,
        currentPage: filter.page,
        pageSize: filter.pageSize,
        totalCount: null, // Exact total unknown after merge
      ),
      null,
    );
  }

  @override
  Future<(MissingPersonEntity?, Failure?)> getMissingPersonDetail({
    required String id,
    required bool isInterpolCase,
  }) async {
    try {
      if (isInterpolCase) {
        final model = await _interpol.getYellowNoticeDetail(id);
        return (model.toEntity(), null);
      } else {
        final model = await _firestore.getCaseDetail(id);
        return (model.toEntity(), null);
      }
    } on ServerException catch (e) {
      if (e.statusCode == 404) return (null, const NotFoundFailure());
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode)
      );
    } on NetworkException catch (e) {
      return (null, NetworkFailure(e.message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(MissingPersonEntity?, Failure?)> reportMissingPerson({
    required MissingPersonEntity person,
    required List<String> localPhotoPaths,
  }) async {
    // TODO: inject current user ID from AuthRepository in commit #10
    const userId = 'anonymous';
    try {
      final model = await _firestore.createCase(
        entity: person,
        userId: userId,
        localPhotoPaths: localPhotoPaths,
      );
      return (model.toEntity(), null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return (null, NetworkFailure(e.message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> updateCaseStatus({
    required String firestoreId,
    required CaseStatus status,
  }) async {
    try {
      await _firestore.updateCaseStatus(id: firestoreId, status: status);
      return (true, null);
    } on ServerException catch (e) {
      return (false, ServerFailure(message: e.message));
    } catch (e) {
      return (false, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(List<MissingPersonEntity>, Failure?)> getPendingCases() async {
    try {
      final models = await _firestore.getPendingCases();
      return (models.map((m) => m.toEntity()).toList(), null);
    } on ServerException catch (e) {
      return (<MissingPersonEntity>[], ServerFailure(message: e.message));
    } catch (e) {
      return (<MissingPersonEntity>[], UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<MissingPersonEntity?> watchCase(String firestoreId) {
    return _firestore.watchCase(firestoreId).map((model) => model?.toEntity());
  }

  // --- Private helpers ---

  Future<(List<MissingPersonEntity>?, Failure?)> _fetchInterpol(
    MissingPersonFilter filter,
  ) async {
    try {
      final response = await _interpol.getYellowNotices(filter: filter);
      final entities = response.notices.map((n) => n.toEntity()).toList();
      return (entities, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode)
      );
    } on NetworkException catch (e) {
      return (null, NetworkFailure(e.message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  Future<(List<MissingPersonEntity>?, Failure?)> _fetchFirestore(
    MissingPersonFilter filter,
  ) async {
    try {
      final models = await _firestore.getCases(filter: filter);
      final entities = models.map((m) => m.toEntity()).toList();
      return (entities, null);
    } on ServerException catch (e) {
      return (null, ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return (null, NetworkFailure(e.message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  void _sort(List<MissingPersonEntity> items, SortOrder order) {
    switch (order) {
      case SortOrder.newestFirst:
        items.sort((a, b) {
          final dateA = a.lastSeenDate ?? a.createdAt ?? DateTime(1970);
          final dateB = b.lastSeenDate ?? b.createdAt ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
      case SortOrder.oldestFirst:
        items.sort((a, b) {
          final dateA = a.lastSeenDate ?? a.createdAt ?? DateTime(1970);
          final dateB = b.lastSeenDate ?? b.createdAt ?? DateTime(1970);
          return dateA.compareTo(dateB);
        });
      case SortOrder.nameAZ:
        items.sort((a, b) => a.name.compareTo(b.name));
      case SortOrder.nameZA:
        items.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  List<MissingPersonEntity> _applySearch(
    List<MissingPersonEntity> items,
    String? query,
  ) {
    if (query == null || query.trim().isEmpty) return items;
    final q = query.toLowerCase().trim();
    return items.where((e) {
      return e.name.toLowerCase().contains(q) ||
          (e.lastSeenLocation?.toLowerCase().contains(q) ?? false) ||
          (e.nationality?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
