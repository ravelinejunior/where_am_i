import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:where_am_i/features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/auth/data/datasources/supabase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/missing_persons/data/datasources/interpol_remote_datasource.dart';
import '../../features/missing_persons/data/datasources/supabase_remote_datasource.dart';
import '../../features/missing_persons/data/repositories/missing_repository_impl.dart';
import '../../features/missing_persons/domain/repositories/i_missing_person_repository.dart';
import '../../features/missing_persons/domain/usecases/get_missing_person_detail.dart';
import '../../features/missing_persons/domain/usecases/get_missing_persons.dart';
import '../../features/missing_persons/domain/usecases/get_pending_cases.dart';
import '../../features/missing_persons/domain/usecases/report_missing_person.dart';
import '../../features/missing_persons/domain/usecases/update_case_status.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

/// Call in main() after Supabase.initialize().
Future<void> configureDependencies() async {
  // --- HTTP (Interpol REST) ---
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // --- Supabase client ---
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // --- Auth ---
  sl.registerLazySingleton<IAuthRemoteDatasource>(
    () => SupabaseAuthDatasource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<IAuthRemoteDatasource>()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(repository: sl<IAuthRepository>()),
  );

  // --- Datasources ---
  sl.registerLazySingleton<IInterpolRemoteDatasource>(
    () => InterpolRemoteDatasource(sl<http.Client>()),
  );
  sl.registerLazySingleton<IFirestoreRemoteDatasource>(
    () => SupabaseRemoteDatasource(sl<SupabaseClient>()),
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

Future<void> configureSharedServices() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<SettingsBloc>(
      () => SettingsBloc(sl<SharedPreferences>()));
}
