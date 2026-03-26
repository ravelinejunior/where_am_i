import '../entities/app_user.dart';
import '../../../../core/error/failures.dart';

abstract interface class IAuthRepository {
  /// Current signed-in user, or null if not authenticated.
  AppUser? get currentUser;

  /// Stream of auth state changes.
  Stream<AppUser?> get authStateChanges;

  Future<(AppUser?, Failure?)> signInWithGoogle();
  Future<(AppUser?, Failure?)> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<(AppUser?, Failure?)> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });
  Future<(bool, Failure?)> sendPasswordResetEmail(String email);
  Future<void> signOut();
}
