import 'dart:developer';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_case_model.dart';
import '../../domain/entities/missing_person_entity.dart';
import '../../domain/value_objects/missing_person_filter.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/error/failures.dart';

// Keep the same interface name so injection.dart only changes the implementation
abstract interface class IFirestoreRemoteDatasource {
  Future<List<SupabaseCaseModel>> getCases({
    required MissingPersonFilter filter,
    dynamic startAfter,
  });
  Future<SupabaseCaseModel> getCaseDetail(String id);
  Future<SupabaseCaseModel> createCase({
    required MissingPersonEntity entity,
    required String userId,
    required List<String> localPhotoPaths,
  });
  Future<void> updateCaseStatus(
      {required String id, required CaseStatus status});
  Future<List<SupabaseCaseModel>> getPendingCases();
  Stream<SupabaseCaseModel?> watchCase(String id);
}

class SupabaseRemoteDatasource implements IFirestoreRemoteDatasource {
  final SupabaseClient _client;
  static const _table = 'cases';
  static const _bucket = 'case-photos';

  const SupabaseRemoteDatasource(this._client);

  @override
  Future<List<SupabaseCaseModel>> getCases({
    required MissingPersonFilter filter,
    dynamic startAfter,
  }) async {
    try {
      // Single simple query — client-side filter for sex/nationality
      // to avoid needing composite indexes
      var query = _client
          .from(_table)
          .select()
          .eq('status', 'approved')
          .order('created_at', ascending: false)
          .limit(filter.pageSize * 3);

      final response = await query;
      var results = (response as List)
          .map((row) => SupabaseCaseModel.fromRow(row as Map<String, dynamic>))
          .toList();

      // Client-side filters
      if (filter.nationalities.isNotEmpty) {
        results = results
            .where((m) =>
                m.nationality != null &&
                filter.nationalities.contains(m.nationality))
            .toList();
      }
      if (filter.sex != null && filter.sex != PersonSex.unknown) {
        results =
            results.where((m) => m.sex == filter.sex!.interpolId).toList();
      }
      if (filter.lastSeenAfter != null) {
        results = results
            .where((m) =>
                m.lastSeenDate != null &&
                m.lastSeenDate!.isAfter(filter.lastSeenAfter!))
            .toList();
      }
      if (filter.minAge != null || filter.maxAge != null) {
        final now = DateTime.now();
        results = results.where((m) {
          if (m.birthDate == null) return true;
          final age = now.year - m.birthDate!.year;
          if (filter.minAge != null && age < filter.minAge!) return false;
          if (filter.maxAge != null && age > filter.maxAge!) return false;
          return true;
        }).toList();
      }

      if (results.length > filter.pageSize) {
        results = results.take(filter.pageSize).toList();
      }
      return results;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<SupabaseCaseModel> getCaseDetail(String id) async {
    try {
      final response =
          await _client.from(_table).select().eq('id', id).single();
      return SupabaseCaseModel.fromRow(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const ServerException(
            message: 'Case not found.', statusCode: 404);
      }
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<SupabaseCaseModel> createCase({
    required MissingPersonEntity entity,
    required String userId,
    required List<String> localPhotoPaths,
  }) async {
    try {
      // Ensure there is an active session before inserting.
      // If the user has no session, sign in anonymously so the request
      // goes through as 'authenticated' role (required by RLS policies).
      if (_client.auth.currentSession == null) {
        await _client.auth.signInAnonymously();
      }

      final uploadedUrls = await _uploadPhotos(localPhotoPaths, userId);
      final model = SupabaseCaseModel.fromEntity(
        entity.copyWith(photoUrls: uploadedUrls),
        userId,
      );
      final response =
          await _client.from(_table).insert(model.toInsert()).select().single();
      return SupabaseCaseModel.fromRow(response);
    } on PostgrestException catch (e) {
      log('PostgrestException: ${e.message}, details: ${e.details}, hint: ${e.hint}');
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<void> updateCaseStatus({
    required String id,
    required CaseStatus status,
  }) async {
    try {
      await _client.from(_table).update({
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<List<SupabaseCaseModel>> getPendingCases() async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return (response as List)
          .map((row) => SupabaseCaseModel.fromRow(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Stream<SupabaseCaseModel?> watchCase(String id) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((rows) {
          if (rows.isEmpty) return null;
          return SupabaseCaseModel.fromRow(rows.first);
        });
  }

  // ── Photo upload ───────────────────────────────────────────────

  Future<List<String>> _uploadPhotos(
      List<String> localPaths, String userId) async {
    if (localPaths.isEmpty) return [];

    // Use actual auth user id — falls back to provided userId param
    final authUserId = _client.auth.currentUser?.id ?? userId;

    final futures = localPaths.asMap().entries.map((entry) async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Path: {userId}/{timestamp}_{index}.jpg
      final fileName = '$authUserId/${timestamp}_${entry.key}.jpg';

      await _client.storage.from(_bucket).upload(
            fileName,
            File(entry.value),
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // getPublicUrl works for public buckets (no expiry needed)
      return _client.storage.from(_bucket).getPublicUrl(fileName);
    });

    return Future.wait(futures);
  }
}
