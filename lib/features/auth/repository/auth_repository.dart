import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../core/constants/app_constants.dart';

abstract class BaseAuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser> signInAnonymously();
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> registerWithEmailAndPassword(String email, String password, String displayName);
  Future<void> signOut();
}

class FirebaseAuthRepository implements BaseAuthRepository {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  AppUser? _localGuestUser;
  final _localAuthStateController = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> get authStateChanges async* {
    yield currentUser;
    final auth = _auth;
    if (auth != null) {
      yield* auth.authStateChanges().asyncMap((User? firebaseUser) async {
        if (firebaseUser != null) {
          return _mapFirebaseUser(firebaseUser);
        }
        return _localGuestUser;
      }).handleError((_) => _localGuestUser);
    } else {
      yield* _localAuthStateController.stream;
    }
  }

  @override
  AppUser? get currentUser {
    try {
      final firebaseUser = _auth?.currentUser;
      if (firebaseUser != null) {
        return _mapFirebaseUser(firebaseUser);
      }
    } catch (_) {}
    return _localGuestUser;
  }

  AppUser _mapFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName ?? (user.isAnonymous ? 'Guest User' : 'Heads Up User'),
      isAnonymous: user.isAnonymous,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> _syncUserDoc(AppUser appUser) async {
    try {
      final firestore = _firestore;
      if (firestore != null) {
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(appUser.uid)
            .set(appUser.toMap(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore sync user notice: $e');
    }
  }

  @override
  Future<AppUser> signInAnonymously() async {
    try {
      final auth = _auth;
      if (auth != null) {
        final userCredential = await auth.signInAnonymously();
        final user = _mapFirebaseUser(userCredential.user!);
        await _syncUserDoc(user);
        return user;
      }
    } catch (e) {
      debugPrint('Firebase signInAnonymously unavailable, using local guest: $e');
    }

    // Local / Offline Guest Fallback (guaranteed to work for F-Droid & offline)
    final guest = AppUser(
      uid: 'guest_local_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest User (Offline)',
      isAnonymous: true,
      createdAt: DateTime.now(),
    );
    _localGuestUser = guest;
    _localAuthStateController.add(guest);
    return guest;
  }

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Online account service is unavailable in offline/FOSS mode. Please use "Continue as Guest".');
    }
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapFirebaseUser(userCredential.user!);
      await _syncUserDoc(user);
      return user;
    } catch (e) {
      debugPrint('Sign in with email error: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Online account service is unavailable in offline/FOSS mode. Please use "Continue as Guest".');
    }
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = userCredential.user!;
      await firebaseUser.updateDisplayName(displayName.trim());

      final user = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: displayName.trim().isEmpty ? 'User' : displayName.trim(),
        isAnonymous: false,
        createdAt: DateTime.now(),
      );

      await _syncUserDoc(user);
      return user;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (e) {
      debugPrint('Sign out notice: $e');
    }
    _localGuestUser = null;
    _localAuthStateController.add(null);
  }
}
