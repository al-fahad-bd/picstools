import 'package:flutter_test/flutter_test.dart';
import 'package:picstools/core/services/auth_service.dart';
import 'package:picstools/features/settings/presentation/bloc/auth_bloc.dart';

void main() {
  group('AuthService (Mock Implementation)', () {
    late AuthService authService;

    setUp(() {
      authService = MockAuthServiceImpl();
    });

    test('Initial state is anonymous guest user when initialized', () async {
      expect(authService.currentUserId, isNull);
      await authService.signInAnonymously();
      expect(authService.isSignedIn, isTrue);
      expect(authService.isAnonymous, isTrue);
      expect(authService.userEmail, isNull);
      expect(authService.displayName, isNull);
      expect(authService.userAge, isNull);
    });

    test('Signing in with email updates user state to permanent account', () async {
      await authService.signInWithEmailPassword('alex@example.com', 'password123');
      expect(authService.isSignedIn, isTrue);
      expect(authService.isAnonymous, isFalse);
      expect(authService.userEmail, 'alex@example.com');
    });

    test('Sign up with name and age stores extra profile info', () async {
      await authService.signUpWithEmailPassword(
        'alex@example.com',
        'password123',
        displayName: 'Alex Johnson',
        age: 28,
      );
      expect(authService.isSignedIn, isTrue);
      expect(authService.isAnonymous, isFalse);
      expect(authService.userEmail, 'alex@example.com');
      expect(authService.displayName, 'Alex Johnson');
      expect(authService.userAge, 28);
    });

    test('Signing out reverts session to a fresh anonymous session', () async {
      await authService.signInWithEmailPassword('alex@example.com', 'password123');
      expect(authService.isAnonymous, isFalse);

      await authService.signOut();
      expect(authService.isAnonymous, isTrue);
      expect(authService.userEmail, isNull);
      expect(authService.displayName, isNull);
      expect(authService.userAge, isNull);
    });
  });

  group('AuthBloc', () {
    late AuthService mockAuthService;
    late AuthBloc authBloc;

    setUp(() async {
      mockAuthService = MockAuthServiceImpl();
      authBloc = AuthBloc(authService: mockAuthService);
      // Wait briefly for initial subscription event
      await Future.delayed(const Duration(milliseconds: 20));
    });

    tearDown(() {
      authBloc.close();
    });

    test('CheckAuthStatusEvent updates state with current session', () async {
      expect(authBloc.state, isA<AuthStateChangedState>());
      final currentState = authBloc.state as AuthStateChangedState;
      expect(currentState.isAnonymous, isTrue);
      expect(currentState.email, isNull);
    });

    test('SignUpWithEmailEvent with name and age creates account and updates state', () async {
      authBloc.add(const SignUpWithEmailEvent(
        email: 'alex@picstools.com',
        password: 'password123',
        name: 'Alex Johnson',
        age: 28,
      ));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoadingState>(),
          isA<AuthSuccessMessageState>().having(
            (s) => s.email,
            'email',
            'alex@picstools.com',
          ),
          isA<AuthStateChangedState>()
              .having((s) => s.email, 'email', 'alex@picstools.com')
              .having((s) => s.displayName, 'displayName', 'Alex Johnson')
              .having((s) => s.age, 'age', 28),
        ]),
      );

      expect(authBloc.state, isA<AuthStateChangedState>());
      final state = authBloc.state as AuthStateChangedState;
      expect(state.email, 'alex@picstools.com');
      expect(state.displayName, 'Alex Johnson');
      expect(state.age, 28);
      expect(state.isAnonymous, isFalse);
    });

    test('SignInWithEmailEvent successfully authenticates user and updates state', () async {
      authBloc.add(const SignInWithEmailEvent(
        email: 'user@picstools.com',
        password: 'password123',
      ));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoadingState>(),
          isA<AuthSuccessMessageState>().having(
            (s) => s.email,
            'email',
            'user@picstools.com',
          ),
          isA<AuthStateChangedState>().having(
            (s) => s.email,
            'email',
            'user@picstools.com',
          ),
        ]),
      );

      expect(authBloc.state, isA<AuthStateChangedState>());
      final state = authBloc.state as AuthStateChangedState;
      expect(state.email, 'user@picstools.com');
      expect(state.isAnonymous, isFalse);
    });

    test('SignOutEvent restores anonymous guest state', () async {
      await mockAuthService.signInWithEmailPassword('user@picstools.com', 'password123');

      authBloc.add(SignOutEvent());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoadingState>(),
          isA<AuthSuccessMessageState>().having(
            (s) => s.isAnonymous,
            'isAnonymous',
            isTrue,
          ),
          isA<AuthStateChangedState>().having(
            (s) => s.isAnonymous,
            'isAnonymous',
            isTrue,
          ),
        ]),
      );

      expect(authBloc.state, isA<AuthStateChangedState>());
      final state = authBloc.state as AuthStateChangedState;
      expect(state.isAnonymous, isTrue);
      expect(state.email, isNull);
    });
  });
}
