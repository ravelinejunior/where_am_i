import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/missing_persons/data/datasources/firestore_remote_datasource.dart';
import '../../features/missing_persons/data/datasources/interpol_remote_datasource.dart';
import '../../features/missing_persons/data/repositories/missing_repository_impl.dart';
import '../../features/missing_persons/domain/entities/missing_person_entity.dart';
import '../../features/missing_persons/domain/repositories/i_missing_person_repository.dart';
import '../../features/missing_persons/domain/usecases/get_missing_person_detail.dart';
import '../../features/missing_persons/domain/usecases/get_missing_persons.dart';
import '../../features/missing_persons/domain/usecases/get_pending_cases.dart';
import '../../features/missing_persons/domain/usecases/report_missing_person.dart';
import '../../features/missing_persons/domain/usecases/update_case_status.dart';
import '../../features/missing_persons/domain/value_objects/missing_person_filter.dart';
import '../../features/missing_persons/data/models/firestore_case_model.dart';
import '../enums/enums.dart';
import '../error/failures.dart';

final sl = GetIt.instance;

/// Call in main() before runApp().
///
/// Set [withFirebase] to true after calling Firebase.initializeApp().
Future<void> configureDependencies({bool withFirebase = false}) async {
  // --- HTTP ---
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // --- Interpol ---
  sl.registerLazySingleton<IInterpolRemoteDatasource>(
    () => InterpolRemoteDatasource(sl<http.Client>()),
  );

  // --- Firebase (only when initialised) ---
  if (withFirebase) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    sl.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance);
    sl.registerLazySingleton<FirebaseStorage>(
        () => FirebaseStorage.instance);
    sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

    sl.registerLazySingleton<IAuthRemoteDatasource>(
      () => FirebaseAuthDatasource(
        sl<FirebaseAuth>(),
        sl<GoogleSignIn>(),
      ),
    );
    sl.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(sl<IAuthRemoteDatasource>()),
    );
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(repository: sl<IAuthRepository>()),
    );

    sl.registerLazySingleton<IFirestoreRemoteDatasource>(
      () => FirestoreRemoteDatasource(
        sl<FirebaseFirestore>(),
        sl<FirebaseStorage>(),
      ),
    );
  } else {
    sl.registerLazySingleton<IFirestoreRemoteDatasource>(
      () => const _NoOpFirestoreDatasource(),
    );
  }

  // --- Missing Persons ---
  sl.registerLazySingleton<IMissingPersonRepository>(
    () => MissingRepositoryImpl(
      interpol: sl<IInterpolRemoteDatasource>(),
      firestore: sl<IFirestoreRemoteDatasource>(),
    ),
  );

  sl.registerLazySingleton(
      () => GetMissingPersons(sl<IMissingPersonRepository>()));
  sl.registerLazySingleton(
      () => GetMissingPersonDetail(sl<IMissingPersonRepository>()));
  sl.registerLazySingleton(
      () => ReportMissingPerson(sl<IMissingPersonRepository>()));
  sl.registerLazySingleton(
      () => UpdateCaseStatus(sl<IMissingPersonRepository>()));
  sl.registerLazySingleton(
      () => GetPendingCases(sl<IMissingPersonRepository>()));
}

// ── No-op Firestore stub ───────────────────────────────────────

class _NoOpFirestoreDatasource implements IFirestoreRemoteDatasource {
  const _NoOpFirestoreDatasource();

  @override
  Future<List<FirestoreCaseModel>> getCases({
    required MissingPersonFilter filter,
    dynamic startAfter,
  }) async => [];

  @override
  Future<FirestoreCaseModel> getCaseDetail(String id) async =>
      throw const ServerException(
          message: 'Firebase not configured.', statusCode: null);

  @override
  Future<FirestoreCaseModel> createCase({
    required MissingPersonEntity entity,
    required String userId,
    required List<String> localPhotoPaths,
  }) async =>
      throw const ServerException(
          message: 'Firebase not configured.', statusCode: null);

  @override
  Future<void> updateCaseStatus({
    required String id,
    required CaseStatus status,
  }) async {}

  @override
  Future<List<FirestoreCaseModel>> getPendingCases() async => [];

  @override
  Stream<FirestoreCaseModel?> watchCase(String id) =>
      const Stream.empty();
}
