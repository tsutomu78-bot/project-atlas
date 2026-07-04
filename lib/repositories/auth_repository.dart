import 'package:firebase_auth/firebase_auth.dart';
import '../models/result.dart';

/// Minimal identity view the app needs — screens never touch
/// firebase_auth's User directly, same as Firestore types stay behind
/// the repository layer.
class AppUser {
  final String uid;
  final String? displayName;
  final bool isAnonymous;
  const AppUser({required this.uid, this.displayName, required this.isAnonymous});
}

abstract class AuthRepository {
  /// Emits the current user on every sign-in/sign-out, null when signed out.
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<Result<AppUser>> signInAnonymously();
  Future<Result<AppUser>> signInWithGoogle();
  Future<Result<void>> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  FirebaseAuthRepository([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  static AppUser _toAppUser(User u) => AppUser(
        uid: u.uid,
        displayName: u.displayName,
        isAnonymous: u.isAnonymous,
      );

  @override
  Stream<AppUser?> authStateChanges() =>
      _auth.authStateChanges().map((u) => u == null ? null : _toAppUser(u));

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : _toAppUser(u);
  }

  @override
  Future<Result<AppUser>> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      return Success(_toAppUser(cred.user!));
    } catch (e) {
      return _mapError(e);
    }
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    try {
      // Web-only flow for now (Chrome is the dev target). Mobile builds will
      // need the google_sign_in package instead of a popup.
      final cred = await _auth.signInWithPopup(GoogleAuthProvider());
      return Success(_toAppUser(cred.user!));
    } catch (e) {
      return _mapError(e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return _mapError(e);
    }
  }

  Result<T> _mapError<T>(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'network-request-failed':
          return const Offline();
        case 'operation-not-allowed':
        case 'admin-restricted-operation':
          // Provider not enabled in the Firebase console — surfaced honestly
          // so the founder knows the exact console switch to flip.
          return const Failure(
              'This sign-in method is not enabled yet (Firebase console → Authentication → Sign-in method).');
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
          return const Failure('Sign-in was cancelled.');
        default:
          return Failure(e.message ?? e.code);
      }
    }
    return const Offline();
  }
}
