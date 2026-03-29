import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart' hide AuthException;

abstract interface class IAuthRemoteDatasource {
  User? get currentUser;
  bool get hasActiveSession;
  Stream<AuthState> get authStateChanges;
  Future<User> signInWithGoogle();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<({User user, bool needsConfirmation})> createUserWithEmailAndPassword(
      String email, String password, String? displayName);
  Future<User> signInAnonymously();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

class SupabaseAuthDatasource implements IAuthRemoteDatasource {
  final SupabaseClient _client;

  const SupabaseAuthDatasource(this._client);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  bool get hasActiveSession => _client.auth.currentSession != null;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<User> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.whereami://login-callback',
      );
      final user = _client.auth.currentUser;
      if (user == null) throw const AuthException('Google sign-in failed.');
      return user;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) throw const AuthException('Sign-in failed.');
      return response.user!;
    } on AuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  @override
  Future<({User user, bool needsConfirmation})> createUserWithEmailAndPassword(
      String email, String password, String? displayName) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user == null) {
        throw const AuthException('Sign-up failed. Please try again.');
      }

      // Confirm email is OFF → session comes back immediately
      if (response.session != null) {
        return (user: response.user!, needsConfirmation: false);
      }

      // Confirm email is ON → try signing in to get session anyway
      try {
        final signIn = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (signIn.session != null) {
          return (user: signIn.user!, needsConfirmation: false);
        }
      } catch (_) {}

      // Genuinely needs email confirmation
      return (user: response.user!, needsConfirmation: true);
    } on AuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  @override
  Future<User> signInAnonymously() async {
    try {
      final response = await _client.auth.signInAnonymously();
      if (response.user == null) {
        throw const AuthException('Anonymous sign-in failed.');
      }
      return response.user!;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  String _mapError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return 'Email ou senha incorretos.';
    }
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'Este email já está cadastrado.';
    }
    if (msg.contains('password')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (msg.contains('rate limit')) {
      return 'Muitas tentativas. Tente novamente mais tarde.';
    }
    if (msg.contains('network')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu email antes de entrar.';
    }
    return e.message;
  }
}
