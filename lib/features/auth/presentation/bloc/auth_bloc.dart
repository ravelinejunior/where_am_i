import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/i_auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repository;
  StreamSubscription<AppUser?>? _authSub;

  AuthBloc({required IAuthRepository repository})
      : _repository = repository,
        super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthEmailSignInRequested>(_onEmailSignIn);
    on<AuthEmailSignUpRequested>(_onEmailSignUp);
    on<AuthPasswordResetRequested>(_onPasswordReset);
    on<AuthSignOutRequested>(_onSignOut);

    add(const AuthStarted());
  }

  Future<void> _onStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    _authSub = _repository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: event.user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      user: event.user,
      clearUser: event.user == null,
    ));
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final (user, failure) = await _repository.signInWithGoogle();
    if (failure != null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ));
      return;
    }
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearError: true,
    ));
  }

  Future<void> _onEmailSignIn(
    AuthEmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final (user, failure) = await _repository.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    if (failure != null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ));
      return;
    }
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearError: true,
    ));
  }

  Future<void> _onEmailSignUp(
    AuthEmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final (user, failure) =
        await _repository.createUserWithEmailAndPassword(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );
    if (failure != null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ));
      return;
    }
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      clearError: true,
    ));
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final (_, failure) =
        await _repository.sendPasswordResetEmail(event.email);
    if (failure != null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ));
      return;
    }
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      successMessage: 'Password reset email sent.',
      clearError: true,
    ));
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.signOut();
    emit(const AuthState());
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
