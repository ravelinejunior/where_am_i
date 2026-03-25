import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:http/http.dart' as http;
import 'package:where_am_i/features/missing_persons/data/datasources/firestore_remote_datasource.dart';
import 'package:where_am_i/features/missing_persons/data/datasources/interpol_remote_datasource.dart';
import 'package:where_am_i/features/missing_persons/data/repositories/missing_repository_impl.dart';
import 'package:where_am_i/features/missing_persons/domain/repositories/i_missing_person_repository.dart';
import 'package:where_am_i/features/missing_persons/domain/usecases/get_missing_person_detail.dart';
import 'package:where_am_i/features/missing_persons/domain/usecases/get_missing_persons.dart';
import 'package:where_am_i/features/missing_persons/domain/usecases/get_pending_cases.dart';
import 'package:where_am_i/features/missing_persons/domain/usecases/report_missing_person.dart';
import 'package:where_am_i/features/missing_persons/domain/usecases/update_case_status.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // --- External ---
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  sl.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );

  // --- Datasources ---
  sl.registerLazySingleton<IInterpolRemoteDatasource>(
    () => InterpolRemoteDatasource(sl<http.Client>()),
  );
  sl.registerLazySingleton<IFirestoreRemoteDatasource>(
    () => FirestoreRemoteDatasource(
      sl<FirebaseFirestore>(),
      sl<FirebaseStorage>(),
    ),
  );

  // --- Repository ---
  sl.registerLazySingleton<IMissingPersonRepository>(
    () => MissingRepositoryImpl(
      interpol: sl<IInterpolRemoteDatasource>(),
      firestore: sl<IFirestoreRemoteDatasource>(),
    ),
  );

  // --- Use Cases ---
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
