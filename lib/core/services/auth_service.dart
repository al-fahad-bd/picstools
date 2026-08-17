import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthService {
  Future<void> initialize();
  Future<bool> signInAnonymously();
  Future<bool> signInWithEmailPassword(String email, String password);
  Future<bool> signUpWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    int? age,
  });
  Future<bool> linkAnonymousWithEmail(
    String email,
    String password, {
    String? displayName,
    int? age,
  });
  Future<bool> sendPasswordReset(String email);
  Future<void> signOut();
  String? get currentUserId;
  String? get userEmail;
  String? get displayName;
  int? get userAge;
  bool get isAnonymous;
  bool get isSignedIn;
  Stream<String?> get authStateChanges;
}

class FirebaseAuthServiceImpl implements AuthService {
  final FirebaseAuth _auth;
  int? _cachedAge;
  String? _cachedName;

  FirebaseAuthServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint(
        '🔑 [PicsTools Auth] User session active | UID: ${user.uid} (isAnonymous: ${user.isAnonymous}, Email: ${user.email}, Name: ${user.displayName})',
      );
    } else {
      debugPrint('🔑 [PicsTools Auth] No active user session on startup.');
    }
  }

  @override
  Future<bool> signInAnonymously() async {
    final existingUser = _auth.currentUser;
    if (existingUser != null) {
      debugPrint(
        '🔑 [PicsTools Auth] Already signed in anonymously | UID: ${existingUser.uid}',
      );
      return true;
    }

    try {
      debugPrint('🔑 [PicsTools Auth] Initiating Firebase anonymous sign-in...');
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        debugPrint(
          '🎉 [PicsTools Auth] Anonymous sign-in SUCCESS! | UID: ${user.uid} | isAnonymous: ${user.isAnonymous}',
        );
        return true;
      } else {
        debugPrint('⚠️ [PicsTools Auth] Anonymous sign-in returned null user.');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [PicsTools Auth] Anonymous sign-in FAILED: $e');
      debugPrint('❌ [PicsTools Auth] Stacktrace: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      debugPrint('🔑 [PicsTools Auth] Signing in with email: $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user != null;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [PicsTools Auth] Email sign-in failed: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PicsTools Auth] Unexpected sign-in error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> signUpWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    int? age,
  }) async {
    try {
      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        return await linkAnonymousWithEmail(
          email,
          password,
          displayName: displayName,
          age: age,
        );
      } else {
        final result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = result.user;
        if (user != null) {
          if (displayName != null && displayName.trim().isNotEmpty) {
            await user.updateDisplayName(displayName.trim());
          }
          _cachedName = displayName;
          _cachedAge = age;
        }
        return user != null;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [PicsTools Auth] Sign up failed: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PicsTools Auth] Unexpected sign up error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> linkAnonymousWithEmail(
    String email,
    String password, {
    String? displayName,
    int? age,
  }) async {
    try {
      final current = _auth.currentUser;
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );

      User? user;
      if (current != null && current.isAnonymous) {
        final result = await current.linkWithCredential(credential);
        user = result.user;
        debugPrint('🎉 [PicsTools Auth] Successfully linked anonymous session to email: $email');
      } else {
        final result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        user = result.user;
      }

      if (user != null) {
        if (displayName != null && displayName.trim().isNotEmpty) {
          await user.updateDisplayName(displayName.trim());
        }
        _cachedName = displayName;
        _cachedAge = age;
      }
      return user != null;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [PicsTools Auth] Link anonymous failed: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PicsTools Auth] Unexpected link error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [PicsTools Auth] Password reset failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _cachedName = null;
      _cachedAge = null;
      await signInAnonymously();
    } catch (e) {
      debugPrint('❌ [PicsTools Auth] Sign out error: $e');
    }
  }

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get userEmail => _auth.currentUser?.email;

  @override
  String? get displayName => _auth.currentUser?.displayName ?? _cachedName;

  @override
  int? get userAge => _cachedAge;

  @override
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().map((user) => user?.uid);
}

class MockAuthServiceImpl implements AuthService {
  String? _mockUserId;
  String? _mockEmail;
  String? _mockDisplayName;
  int? _mockAge;
  bool _mockIsAnonymous;

  MockAuthServiceImpl({
    String? initialUserId,
    String? initialEmail,
    String? initialDisplayName,
    int? initialAge,
    bool isAnonymous = true,
  })  : _mockUserId = initialUserId,
        _mockEmail = initialEmail,
        _mockDisplayName = initialDisplayName,
        _mockAge = initialAge,
        _mockIsAnonymous = isAnonymous;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> signInAnonymously() async {
    _mockUserId ??= 'mock_anon_user_12345';
    _mockIsAnonymous = true;
    _mockEmail = null;
    _mockDisplayName = null;
    _mockAge = null;
    return true;
  }

  @override
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _mockUserId = 'mock_user_${email.hashCode}';
    _mockEmail = email;
    _mockIsAnonymous = false;
    return true;
  }

  @override
  Future<bool> signUpWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    int? age,
  }) async {
    _mockUserId = 'mock_user_${email.hashCode}';
    _mockEmail = email;
    _mockDisplayName = displayName;
    _mockAge = age;
    _mockIsAnonymous = false;
    return true;
  }

  @override
  Future<bool> linkAnonymousWithEmail(
    String email,
    String password, {
    String? displayName,
    int? age,
  }) async {
    _mockUserId ??= 'mock_user_${email.hashCode}';
    _mockEmail = email;
    _mockDisplayName = displayName;
    _mockAge = age;
    _mockIsAnonymous = false;
    return true;
  }

  @override
  Future<bool> sendPasswordReset(String email) async {
    return true;
  }

  @override
  Future<void> signOut() async {
    _mockUserId = 'mock_anon_new_12345';
    _mockEmail = null;
    _mockDisplayName = null;
    _mockAge = null;
    _mockIsAnonymous = true;
  }

  @override
  String? get currentUserId => _mockUserId;

  @override
  String? get userEmail => _mockEmail;

  @override
  String? get displayName => _mockDisplayName;

  @override
  int? get userAge => _mockAge;

  @override
  bool get isAnonymous => _mockIsAnonymous;

  @override
  bool get isSignedIn => _mockUserId != null;

  @override
  Stream<String?> get authStateChanges =>
      Stream.value(_mockUserId);
}
