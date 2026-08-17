import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmailEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  final int? age;

  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
    this.name,
    this.age,
  });

  @override
  List<Object?> get props => [email, password, name, age];
}

class SendPasswordResetEvent extends AuthEvent {
  final String email;
  const SendPasswordResetEvent(this.email);
  @override
  List<Object?> get props => [email];
}

class SignOutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthStateChangedState extends AuthState {
  final bool isSignedIn;
  final bool isAnonymous;
  final String? email;
  final String? displayName;
  final int? age;
  final String? uid;

  const AuthStateChangedState({
    required this.isSignedIn,
    required this.isAnonymous,
    this.email,
    this.displayName,
    this.age,
    this.uid,
  });

  @override
  List<Object?> get props => [isSignedIn, isAnonymous, email, displayName, age, uid];
}

class AuthSuccessMessageState extends AuthState {
  final String message;
  final bool isAnonymous;
  final String? email;
  final String? displayName;

  const AuthSuccessMessageState(
    this.message, {
    this.isAnonymous = false,
    this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [message, isAnonymous, email, displayName];
}

class AuthErrorState extends AuthState {
  final String errorMessage;
  const AuthErrorState(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  StreamSubscription<String?>? _authSubscription;

  AuthBloc({required this.authService}) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SendPasswordResetEvent>(_onSendPasswordReset);
    on<SignOutEvent>(_onSignOut);

    _authSubscription = authService.authStateChanges.listen((_) {
      add(CheckAuthStatusEvent());
    });
  }

  void _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) {
    emit(AuthStateChangedState(
      isSignedIn: authService.isSignedIn,
      isAnonymous: authService.isAnonymous,
      email: authService.userEmail,
      displayName: authService.displayName,
      age: authService.userAge,
      uid: authService.currentUserId,
    ));
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final success = await authService.signInWithEmailPassword(
        event.email,
        event.password,
      );
      if (success) {
        emit(AuthSuccessMessageState(
          '🎉 Welcome back! Signed in as ${authService.userEmail}',
          isAnonymous: false,
          email: authService.userEmail,
          displayName: authService.displayName,
        ));
        emit(AuthStateChangedState(
          isSignedIn: true,
          isAnonymous: false,
          email: authService.userEmail,
          displayName: authService.displayName,
          age: authService.userAge,
          uid: authService.currentUserId,
        ));
      } else {
        emit(const AuthErrorState('Could not sign in with provided credentials.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthErrorState(_mapFirebaseError(e)));
    } catch (e) {
      emit(AuthErrorState('Sign in failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final success = await authService.signUpWithEmailPassword(
        event.email,
        event.password,
        displayName: event.name,
        age: event.age,
      );
      if (success) {
        emit(AuthSuccessMessageState(
          '🎉 Account created & linked successfully!',
          isAnonymous: false,
          email: authService.userEmail,
          displayName: authService.displayName,
        ));
        emit(AuthStateChangedState(
          isSignedIn: true,
          isAnonymous: false,
          email: authService.userEmail,
          displayName: authService.displayName,
          age: authService.userAge,
          uid: authService.currentUserId,
        ));
      } else {
        emit(const AuthErrorState('Could not create account.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthErrorState(_mapFirebaseError(e)));
    } catch (e) {
      emit(AuthErrorState('Registration failed: ${e.toString()}'));
    }
  }

  Future<void> _onSendPasswordReset(
    SendPasswordResetEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      await authService.sendPasswordReset(event.email);
      emit(AuthSuccessMessageState(
        '📧 Password reset link sent to ${event.email}',
        isAnonymous: authService.isAnonymous,
        email: authService.userEmail,
        displayName: authService.displayName,
      ));
      emit(AuthStateChangedState(
        isSignedIn: authService.isSignedIn,
        isAnonymous: authService.isAnonymous,
        email: authService.userEmail,
        displayName: authService.displayName,
        age: authService.userAge,
        uid: authService.currentUserId,
      ));
    } on FirebaseAuthException catch (e) {
      emit(AuthErrorState(_mapFirebaseError(e)));
    } catch (e) {
      emit(AuthErrorState('Failed to send reset email: ${e.toString()}'));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    await authService.signOut();
    emit(const AuthSuccessMessageState(
      'Signed out. Reverted to guest session.',
      isAnonymous: true,
    ));
    emit(AuthStateChangedState(
      isSignedIn: authService.isSignedIn,
      isAnonymous: true,
      email: null,
      displayName: null,
      age: null,
      uid: authService.currentUserId,
    ));
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Please sign in instead.';
      case 'credential-already-in-use':
        return 'This email is already linked to another account.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
