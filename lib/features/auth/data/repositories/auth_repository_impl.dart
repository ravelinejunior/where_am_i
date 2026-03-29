import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../datasources/supabase_auth_datasource.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../../../core/error/failures.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  @override
  AppUser? get currentUser => _mapUser(_datasource.currentUser);

  @override
  Stream<AppUser?> get authStateChanges => _datasource.authStateChanges
      .map((state) => _mapUser(state.session?.user));

  @override
  Future<(AppUser?, Failure?)> signInWithGoogle() async {
    try {
      final user = await _datasource.signInWithGoogle();
      return (_mapUser(user), null);
    } on AuthException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(AppUser?, Failure?)> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user =
          await _datasource.signInWithEmailAndPassword(email, password);
      return (_mapUser(user), null);
    } on AuthException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(AppUser?, Failure?)> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _datasource.createUserWithEmailAndPassword(
          email, password, displayName);
      return (_mapUser(user.user), null);
    } on AuthException catch (e) {
      return (null, AuthFailure(e.message));
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<(bool, Failure?)> sendPasswordResetEmail(String email) async {
    try {
      await _datasource.sendPasswordResetEmail(email);
      return (true, null);
    } on AuthException catch (e) {
      return (false, AuthFailure(e.message));
    } catch (e) {
      return (false, UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  AppUser? _mapUser(sb.User? user) {
    if (user == null) return null;
    final meta = user.userMetadata ?? {};
    return AppUser(
      uid: user.id,
      email: user.email,
      displayName: meta['display_name'] as String? ??
          meta['full_name'] as String? ??
          meta['name'] as String?,
      photoUrl: meta['avatar_url'] as String?,
    );
  }
}
