import '../entities/authenticated_user.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String phoneNumber,
    required String password,
  });

  Future<AuthSession> firebaseLogin({
    required String idToken,
    String? name,
    String? password,
    bool isRegister = false,
  });

  Future<AuthenticatedUser?> getProfile();

  Future<AuthenticatedUser> updateProfile(Map<String, dynamic> data);

  Future<void> logout();

  Future<AuthSession?> getStoredSession();
}
