import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/entities/auth_session.dart';
import '../services/auth_api_service.dart';
import '../dto/login_request_dto.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/preferences_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _secureStorage;
  final PreferencesService _preferences;

  AuthRepositoryImpl(
    this._apiService,
    this._secureStorage,
    this._preferences,
  );

  @override
  Future<AuthSession> login({
    required String phoneNumber,
    required String password,
  }) async {
    final dto = LoginRequestDto(
      phoneNumber: phoneNumber,
      password: password,
    );

    final res = await _apiService.login(dto);
    await _secureStorage.saveTokens(access: res.access, refresh: res.refresh);

    AuthenticatedUser? user = res.toEntity();
    if (user == null) {
      try {
        user = await _apiService.getProfile();
      } catch (_) {}
    }

    if (user != null) {
      await _preferences.saveUserProfile(user.toJson());
    }

    return AuthSession(
      accessToken: res.access,
      refreshToken: res.refresh,
      user: user,
    );
  }

  @override
  Future<AuthSession> firebaseLogin({
    required String idToken,
    String? name,
    String? password,
    bool isRegister = false,
  }) async {
    final res = await _apiService.firebaseLogin(
      idToken: idToken,
      name: name,
      password: password,
      isRegister: isRegister,
    );

    await _secureStorage.saveTokens(access: res.access, refresh: res.refresh);

    AuthenticatedUser? user = res.toEntity();
    if (user == null) {
      try {
        user = await _apiService.getProfile();
      } catch (_) {}
    }

    if (user != null) {
      await _preferences.saveUserProfile(user.toJson());
    }

    return AuthSession(
      accessToken: res.access,
      refreshToken: res.refresh,
      user: user,
    );
  }

  @override
  Future<AuthenticatedUser?> getProfile() async {
    try {
      final user = await _apiService.getProfile();
      await _preferences.saveUserProfile(user.toJson());
      return user;
    } catch (e) {
      final cached = await _preferences.getUserProfile();
      if (cached != null) {
        return AuthenticatedUser.fromJson(cached);
      }
      rethrow;
    }
  }

  @override
  Future<AuthenticatedUser> updateProfile(Map<String, dynamic> data) async {
    final updated = await _apiService.updateProfile(data);
    await _preferences.saveUserProfile(updated.toJson());
    return updated;
  }

  @override
  Future<void> logout() async {
    final refresh = await _secureStorage.getRefreshToken();
    if (refresh != null) {
      await _apiService.logout(refresh);
    }
    await _secureStorage.clearTokens();
    await _preferences.clearUserProfile();
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    final access = await _secureStorage.getAccessToken();
    final refresh = await _secureStorage.getRefreshToken();

    if (access == null || refresh == null) {
      return null;
    }

    AuthenticatedUser? user;
    final cachedJson = await _preferences.getUserProfile();
    if (cachedJson != null) {
      user = AuthenticatedUser.fromJson(cachedJson);
    }

    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      user: user,
    );
  }
}
