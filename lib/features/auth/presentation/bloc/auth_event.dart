part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthUserChanged extends AuthEvent {
  final AppUser? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

final class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

final class AuthEmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthEmailSignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

final class AuthEmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;
  const AuthEmailSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });
  @override
  List<Object?> get props => [email, password, displayName];
}

final class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
