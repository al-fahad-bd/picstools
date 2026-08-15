import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthService {
  Future<void> initialize();
  Future<bool> signInAnonymously();
  String? get currentUserId;
  bool get isSignedIn;
  Stream<String?> get authStateChanges;
}

class FirebaseAuthServiceImpl implements AuthService {
  final FirebaseAuth _auth;

  FirebaseAuthServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint(
        '🔑 [PicsTools Auth] User session active | UID: ${user.uid} (isAnonymous: ${user.isAnonymous})',
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
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().map((user) => user?.uid);
}

class MockAuthServiceImpl implements AuthService {
  String? _mockUserId;

  MockAuthServiceImpl({String? initialUserId}) : _mockUserId = initialUserId;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> signInAnonymously() async {
    _mockUserId ??= 'mock_anon_user_12345';
    return true;
  }

  @override
  String? get currentUserId => _mockUserId;

  @override
  bool get isSignedIn => _mockUserId != null;

  @override
  Stream<String?> get authStateChanges =>
      Stream.value(_mockUserId);
}
