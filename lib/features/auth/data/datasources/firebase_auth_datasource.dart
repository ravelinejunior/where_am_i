import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/failures.dart';

abstract interface class IAuthRemoteDatasource {
  User? get currentFirebaseUser;
  Stream<User?> get authStateChanges;
  Future<User> signInWithGoogle();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(
      String email, String password, String? displayName);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

class FirebaseAuthDatasource implements IAuthRemoteDatasource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDatasource(this._auth, this._googleSignIn);

  @override
  User? get currentFirebaseUser => _auth.currentUser;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      if (result.user == null) throw const AuthException('Sign-in failed.');
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google sign-in failed.');
    }
  }

  @override
  Future<User> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result.user == null) throw const AuthException('Sign-in failed.');
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      String email, String password, String? displayName) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user == null) throw const AuthException('Sign-up failed.');
      if (displayName != null) {
        await result.user!.updateDisplayName(displayName);
        await result.user!.reload();
      }
      return _auth.currentUser!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password.',
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'Invalid email address.',
      'weak-password' => 'Password must be at least 6 characters.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      'network-request-failed' => 'Network error. Check your connection.',
      _ => e.message ?? 'Authentication failed.',
    };
  }
}
