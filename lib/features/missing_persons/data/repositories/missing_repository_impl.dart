import '../../domain/entities/missing_person_entity.dart';
import '../../domain/repositories/i_missing_person_repository.dart';
import '../../domain/value_objects/missing_person_filter.dart';
import '../../domain/value_objects/paginated_result.dart';
import '../datasources/interpol_remote_datasource.dart';
import '../datasources/supabase_remote_datasource.dart';
import '../../../../core/enums/enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';

class MissingRepositoryImpl implements IMissingPersonRepository {
  final IInterpolRemoteDatasource _interpol;
  final IFirestoreRemoteDatasource _supabase;

  const MissingRepositoryImpl({
    required IInterpolRemoteDatasource interpol,
    required IFirestoreRemoteDatasource firestore,
  })  : _interpol = interpol,
        _supabase = firestore;

  @override
  Future<(PaginatedResult<MissingPersonEntity>?, Failure?)> getMissingPersons({
    required MissingPersonFilter filter,
  }) async {
    final results = <MissingPersonEntity>[];
    Failure? lastFailure;

    final fetchInterpol = filter.sources.contains(MissingPersonSource.interpol);
    final fetchSupabase = filter.sources.contains(MissingPersonSource.firebase);

    final futures = await Future.wait([
      if (fetchInterpol) _fetchInterpol(filter) else Future.value(null),
      if (fetchSupabase) _fetchSupabase(filter) else Future.value(null),
    ]);

    final interpolResult = fetchInterpol ? futures[0] : null;
    final supabaseResult =
        fetchSupabase ? futures[fetchInterpol ? 1 : 0] : null;

    if (interpolResult != null) {
      final (entities, failure) = interpolResult;
      if (entities != null) results.addAll(entities);
      if (failure != null) lastFailure = failure;
    }
    if (supabaseResult != null) {
      final (entities, failure) = supabaseResult;
      if (entities != null) results.addAll(entities);
      if (failure != null && lastFailure == null) lastFailure = failure;
    }

    if (results.isEmpty && lastFailure != null) return (null, lastFailure);

    final seen = <String>{};
    final unique = results.where((e) => seen.add(e.id)).toList();
    _sort(unique, filter.sortOrder);
    final filtered = _applySearch(unique, filter.searchQuery);

    return (
      PaginatedResult<MissingPersonEntity>(
        items: filtered,
        currentPage: filter.page,
        pageSize: filter.pageSize,
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
        final model = await _supabase.getCaseDetail(id);
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
    // Get real user ID from Supabase auth session
    // reported_by is nullable in DB — allow unauthenticated reports (pending review)
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    try {
      final model = await _supabase.createCase(
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
      await _supabase.updateCaseStatus(id: firestoreId, status: status);
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
      final models = await _supabase.getPendingCases();
      return (models.map((m) => m.toEntity()).toList(), null);
    } on ServerException catch (e) {
      return (<MissingPersonEntity>[], ServerFailure(message: e.message));
    } catch (e) {
      return (<MissingPersonEntity>[], UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<MissingPersonEntity?> watchCase(String firestoreId) {
    return _supabase.watchCase(firestoreId).map((model) => model?.toEntity());
  }

  Future<(List<MissingPersonEntity>?, Failure?)> _fetchInterpol(
      MissingPersonFilter filter) async {
    try {
      final response = await _interpol.getYellowNotices(filter: filter);
      return (response.notices.map((n) => n.toEntity()).toList(), null);
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

  Future<(List<MissingPersonEntity>?, Failure?)> _fetchSupabase(
      MissingPersonFilter filter) async {
    try {
      final models = await _supabase.getCases(filter: filter);
      return (models.map((m) => m.toEntity()).toList(), null);
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
          final da = a.lastSeenDate ?? a.createdAt ?? DateTime(1970);
          final db = b.lastSeenDate ?? b.createdAt ?? DateTime(1970);
          return db.compareTo(da);
        });
      case SortOrder.oldestFirst:
        items.sort((a, b) {
          final da = a.lastSeenDate ?? a.createdAt ?? DateTime(1970);
          final db = b.lastSeenDate ?? b.createdAt ?? DateTime(1970);
          return da.compareTo(db);
        });
      case SortOrder.nameAZ:
        items.sort((a, b) => a.name.compareTo(b.name));
      case SortOrder.nameZA:
        items.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  List<MissingPersonEntity> _applySearch(
      List<MissingPersonEntity> items, String? query) {
    if (query == null || query.trim().isEmpty) return items;
    final q = query.toLowerCase().trim();
    return items.where((e) {
      return e.name.toLowerCase().contains(q) ||
          (e.lastSeenLocation?.toLowerCase().contains(q) ?? false) ||
          (e.nationality?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
