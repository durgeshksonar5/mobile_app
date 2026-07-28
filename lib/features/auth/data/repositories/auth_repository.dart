import '../../domain/models/user_model.dart';
import '../services/auth_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AuthService _authService;
  final SecureStorageService _secureStorage;
  final PreferencesService _preferences;

  AuthRepository(this._authService, this._secureStorage, this._preferences);

  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final res = await _authService.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    final access = res['access'] as String?;
    final refresh = res['refresh'] as String?;
    final userJson = res['user'] as Map<String, dynamic>?;

    if (access != null) {
      await _secureStorage.saveAccessToken(access);
      if (refresh != null) await _secureStorage.saveRefreshToken(refresh);
    }

    if (userJson != null) {
      final user = UserModel.fromJson(userJson);
      await _preferences.saveUser(user.toJson());
      return user;
    }
    throw Exception('Invalid login response payload.');
  }

  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    final res = await _authService.register(
      phoneNumber: phoneNumber,
      password: password,
      name: name,
    );
    final access = res['access'] as String?;
    final refresh = res['refresh'] as String?;
    final userJson = res['user'] as Map<String, dynamic>?;

    if (access != null) {
      await _secureStorage.saveAccessToken(access);
      if (refresh != null) await _secureStorage.saveRefreshToken(refresh);
    }
    if (userJson != null) {
      final user = UserModel.fromJson(userJson);
      await _preferences.saveUser(user.toJson());
    }
    return res;
  }

  Future<UserModel> firebaseLogin({
    required String idToken,
    String? name,
    String? password,
    bool isRegister = false,
  }) async {
    final res = await _authService.firebaseLogin(
      idToken: idToken,
      name: name,
      password: password,
      isRegister: isRegister,
    );
    final access = res['access'] as String?;
    final refresh = res['refresh'] as String?;
    final userJson = res['user'] as Map<String, dynamic>?;

    if (access != null) {
      await _secureStorage.saveAccessToken(access);
      if (refresh != null) await _secureStorage.saveRefreshToken(refresh);
    }

    if (userJson != null) {
      final user = UserModel.fromJson(userJson);
      await _preferences.saveUser(user.toJson());
      return user;
    }
    throw Exception('Invalid firebase login response payload.');
  }

  Future<UserModel?> getProfile() async {
    try {
      final res = await _authService.getProfile();
      if (res['success'] == true && res['data'] != null) {
        final user = UserModel.fromJson(res['data'] as Map<String, dynamic>);
        await _preferences.saveUser(user.toJson());
        return user;
      }
    } catch (_) {}
    // Fallback to cached local profile
    final cached = await _preferences.getUser();
    if (cached != null) return UserModel.fromJson(cached);
    return null;
  }

  Future<String?> getLatestAppVersion() async {
    try {
      final res = await _authService.getNotificationSettings();
      if (res['success'] == true && res['data'] != null) {
        return res['data']['app_version'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final res = await _authService.updateProfile(data);
    if (res['success'] == true && res['data'] != null) {
      final user = UserModel.fromJson(res['data'] as Map<String, dynamic>);
      await _preferences.saveUser(user.toJson());
      return user;
    }
    throw Exception('Failed to update profile.');
  }

  Future<void> logout() async {
    final refresh = await _secureStorage.getRefreshToken();
    if (refresh != null) {
      await _authService.logout(refresh);
    }
    await _secureStorage.clearTokens();
    await _preferences.clearAll();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  }
}
