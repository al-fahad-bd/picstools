import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  Future<bool> signInWithGoogle();
  Future<bool> sendPasswordReset(String email);
  Future<void> signOut();
  String? get currentUserId;
  String? get userEmail;
  String? get displayName;
  String? get photoUrl;
  int? get userAge;
  bool get isAnonymous;
  bool get isSignedIn;
  Stream<String?> get authStateChanges;
}

class FirebaseAuthServiceImpl implements AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore? firestore;
  int? _cachedAge;
  String? _cachedName;
  bool _googleSignInInitialized = false;

  FirebaseAuthServiceImpl({
    FirebaseAuth? auth,
    this.firestore,
  })  : _auth = auth ?? FirebaseAuth.instance;

  FirebaseFirestore? get _db {
    if (firestore != null) return firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('⚠️ [PicsTools Auth] FirebaseFirestore not available: $e');
      return null;
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      try {
        await GoogleSignIn.instance.initialize();
        _googleSignInInitialized = true;
      } catch (e) {
        debugPrint('⚠️ [PicsTools Auth] GoogleSignIn initialize error: $e');
      }
    }
  }

  Future<void> _saveUserProfileToFirestore(
    User user, {
    String? displayName,
    int? age,
  }) async {
    try {
      final db = _db;
      if (db == null) return;

      final data = <String, dynamic>{
        'uid': user.uid,
        'email': ?user.email,
        if (displayName != null && displayName.trim().isNotEmpty)
          'displayName': displayName.trim(),
        'age': ?age,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await db
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      debugPrint(
        '💾 [PicsTools Auth] Saved profile to Firestore: /users/${user.uid} (name: $displayName, age: $age)',
      );
    } catch (e) {
      debugPrint('⚠️ [PicsTools Auth] Could not save profile to Firestore: $e');
    }
  }

  Future<void> _loadUserProfileFromFirestore(String uid) async {
    try {
      final db = _db;
      if (db == null) return;

      final doc = await db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          if (data['age'] != null) {
            _cachedAge = (data['age'] as num?)?.toInt();
          }
          if (data['displayName'] != null) {
            _cachedName ??= data['displayName'] as String?;
          }
          debugPrint(
            '📖 [PicsTools Auth] Loaded profile from Firestore: name=$_cachedName, age=$_cachedAge',
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PicsTools Auth] Could not load profile from Firestore: $e');
    }
  }

  @override
  Future<void> initialize() async {
    await _ensureGoogleSignInInitialized();
    final user = _auth.currentUser;
    if (user != null) {
      debugPrint(
        '🔑 [PicsTools Auth] User session active | UID: ${user.uid} (isAnonymous: ${user.isAnonymous}, Email: ${user.email}, Name: ${user.displayName})',
      );
      if (!user.isAnonymous) {
        await _loadUserProfileFromFirestore(user.uid);
      }
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
      final user = result.user;
      if (user != null) {
        await _loadUserProfileFromFirestore(user.uid);
      }
      return user != null;
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
          await _saveUserProfileToFirestore(
            user,
            displayName: displayName,
            age: age,
          );
        }
        return user != null;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [PicsTools Auth] Sign up failed: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PicsTools Auth] Unexpected sign-up error: $e');
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
        await _saveUserProfileToFirestore(
          user,
          displayName: displayName,
          age: age,
        );
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
  Future<bool> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      debugPrint('🔑 [PicsTools Auth] Initiating Google Sign-In...');
      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      final current = _auth.currentUser;
      User? user;
      if (current != null && current.isAnonymous) {
        try {
          debugPrint('🔑 [PicsTools Auth] Linking anonymous user with Google credential...');
          final result = await current.linkWithCredential(credential);
          user = result.user;
          debugPrint('🎉 [PicsTools Auth] Successfully linked anonymous session to Google: ${user?.email}');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            debugPrint('ℹ️ [PicsTools Auth] Credential already in use; signing in directly with Google...');
            final result = await _auth.signInWithCredential(credential);
            user = result.user;
          } else {
            rethrow;
          }
        }
      } else {
        final result = await _auth.signInWithCredential(credential);
        user = result.user;
      }

      if (user != null) {
        _cachedName = user.displayName;
        await _loadUserProfileFromFirestore(user.uid);
        await _saveUserProfileToFirestore(
          user,
          displayName: user.displayName,
          age: _cachedAge,
        );
        debugPrint('🎉 [PicsTools Auth] Google Sign-In SUCCESS! | UID: ${user.uid} | Email: ${user.email}');
        return true;
      }
      return false;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('ℹ️ [PicsTools Auth] Google Sign-In canceled by user.');
        return false;
      }
      debugPrint('❌ [PicsTools Auth] Google Sign-In failed: ${e.code} - ${e.description}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PicsTools Auth] Google Sign-In unexpected error: $e');
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
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('⚠️ [PicsTools Auth] Google sign out error: $e');
      }
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
  String? get photoUrl => _auth.currentUser?.photoURL;

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
  String? _mockPhotoUrl;
  int? _mockAge;
  bool _mockIsAnonymous;

  MockAuthServiceImpl({
    String? initialUserId,
    String? initialEmail,
    String? initialDisplayName,
    String? initialPhotoUrl,
    int? initialAge,
    bool isAnonymous = true,
  })  : _mockUserId = initialUserId,
        _mockEmail = initialEmail,
        _mockDisplayName = initialDisplayName,
        _mockPhotoUrl = initialPhotoUrl,
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
    _mockPhotoUrl = null;
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
  Future<bool> signInWithGoogle() async {
    _mockUserId = 'mock_google_user_999';
    _mockEmail = 'user@gmail.com';
    _mockDisplayName = 'Google User';
    _mockPhotoUrl = 'https://lh3.googleusercontent.com/a/mock';
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
    _mockPhotoUrl = null;
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
  String? get photoUrl => _mockPhotoUrl;

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
