import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/firestore_case_model.dart';
import '../../domain/entities/missing_person_entity.dart';
import '../../domain/value_objects/missing_person_filter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/error/failures.dart';

abstract interface class IFirestoreRemoteDatasource {
  Future<List<FirestoreCaseModel>> getCases({
    required MissingPersonFilter filter,
    DocumentSnapshot? startAfter,
  });

  Future<FirestoreCaseModel> getCaseDetail(String id);

  Future<FirestoreCaseModel> createCase({
    required MissingPersonEntity entity,
    required String userId,
    required List<String> localPhotoPaths,
  });

  Future<void> updateCaseStatus({
    required String id,
    required CaseStatus status,
  });

  Future<List<FirestoreCaseModel>> getPendingCases();

  Stream<FirestoreCaseModel?> watchCase(String id);
}

class FirestoreRemoteDatasource implements IFirestoreRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const FirestoreRemoteDatasource(this._firestore, this._storage);

  CollectionReference<Map<String, dynamic>> get _cases =>
      _firestore.collection(AppConstants.casesCollection);

  @override
  Future<List<FirestoreCaseModel>> getCases({
    required MissingPersonFilter filter,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _cases
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .limit(filter.pageSize);

      if (filter.nationalities.isNotEmpty) {
        query = query.where('nationality', whereIn: filter.nationalities);
      }

      if (filter.sex != null && filter.sex != PersonSex.unknown) {
        query = query.where('sex', isEqualTo: filter.sex!.interpolId);
      }

      if (filter.lastSeenAfter != null) {
        query = query.where(
          'lastSeenDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filter.lastSeenAfter!),
        );
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map(FirestoreCaseModel.fromDoc).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error', statusCode: null);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<FirestoreCaseModel> getCaseDetail(String id) async {
    try {
      final doc = await _cases.doc(id).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Case not found.', statusCode: 404);
      }
      return FirestoreCaseModel.fromDoc(doc);
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }

  @override
  Future<FirestoreCaseModel> createCase({
    required MissingPersonEntity entity,
    required String userId,
    required List<String> localPhotoPaths,
  }) async {
    try {
      // 1. Upload photos first
      final uploadedUrls = await _uploadPhotos(localPhotoPaths);

      // 2. Build model with uploaded URLs
      final model = FirestoreCaseModel.fromEntity(
        entity.copyWith(photoUrls: uploadedUrls),
        userId,
      );

      // 3. Write to Firestore
      final ref = await _cases.add(model.toFirestore());
      final doc = await ref.get();
      return FirestoreCaseModel.fromDoc(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }

  @override
  Future<void> updateCaseStatus({
    required String id,
    required CaseStatus status,
  }) async {
    try {
      await _cases.doc(id).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }

  @override
  Future<List<FirestoreCaseModel>> getPendingCases() async {
    try {
      final snapshot = await _cases
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(FirestoreCaseModel.fromDoc).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firestore error');
    }
  }

  @override
  Stream<FirestoreCaseModel?> watchCase(String id) {
    return _cases.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FirestoreCaseModel.fromDoc(doc);
    });
  }

  // --- Photo upload ---

  Future<List<String>> _uploadPhotos(List<String> localPaths) async {
    if (localPaths.isEmpty) return [];

    final futures = localPaths.asMap().entries.map((entry) async {
      final path = entry.value;
      final index = entry.key;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'photo_${timestamp}_$index.jpg';
      final ref = _storage
          .ref()
          .child(AppConstants.casePhotosPath)
          .child(fileName);

      final file = File(path);
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    });

    return Future.wait(futures);
  }
}
