import 'package:project_atlas/models/result.dart';
import 'package:project_atlas/repositories/auth_repository.dart';

/// In-memory AuthRepository so widget tests never touch FirebaseAuth.
class FakeAuthRepository implements AuthRepository {
  AppUser? user;
  Result<AppUser>? nextSignInResult;
  FakeAuthRepository([this.user]);

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(user);

  @override
  AppUser? get currentUser => user;

  Future<Result<AppUser>> _signIn(AppUser fallback) async {
    final result = nextSignInResult ?? Success(fallback);
    if (result is Success<AppUser>) user = result.value;
    return result;
  }

  @override
  Future<Result<AppUser>> signInAnonymously() =>
      _signIn(const AppUser(uid: 'anon-uid', isAnonymous: true));

  @override
  Future<Result<AppUser>> signInWithGoogle() =>
      _signIn(const AppUser(uid: 'google-uid', displayName: 'Test User', isAnonymous: false));

  @override
  Future<Result<void>> signOut() async {
    user = null;
    return const Success(null);
  }
}
