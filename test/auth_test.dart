import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('should not be initialized to begin with', () {
      expect(provider._isInitialized, false);
    });
    test('cannot log out if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });
    test('Should be able to initialized', () async {
      await provider.initialize();
      expect(provider._isInitialized, true);
    });
    test('user should be null after initialzation', () {
      expect(provider.currentUser, null);
    });
    test(
      'Should be able to initialze in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider._isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('create user should delegate to login function', () async {
      final badEmailUser =
          provider.createUser(email: 'siddu@gmail.com', password: '123');
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPasswordUser =
          provider.createUser(email: 'sid@gmail.com', password: '123');
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = await provider.createUser(email: 'sid', password: '34');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test('login user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('should be able to log out and log in ', () async {
      await provider.logOut();
      await provider.logIn(email: 'sid', password: 'asdf');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();

    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'siddu@gmail.com') throw UserNotFoundAuthException();
    if (password == "123") throw WrongPasswordAuthException();
    const user = AuthUser(id:"my_id",isEmailVerified: false, email: 's@gmail.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser =
        AuthUser(id: "my_id", isEmailVerified: true, email: 's@gmail.com');
    _user = newUser;
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) {

    throw UnimplementedError();
  }
}
