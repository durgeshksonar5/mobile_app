import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post('/auth/login/', data: {
        'phone_number': phoneNumber,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      if (detail == 'ACCOUNT_BLOCKED') {
        throw const AccountBlockedException();
      }
      String errorMsg = 'Invalid phone number or password.';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          if (data['detail'] is String) {
            errorMsg = data['detail'];
          } else if (data['error'] is String) {
            errorMsg = data['error'];
          } else if (data['message'] is String) {
            errorMsg = data['message'];
          }
        }
      }
      throw ServerException(errorMsg, e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> firebaseLogin({
    required String idToken,
    String? name,
    String? password,
    bool isRegister = false,
  }) async {
    try {
      final response =
          await _apiClient.dio.post('/auth/firebase-login/', data: {
        'id_token': idToken,
        if (name != null) 'name': name,
        if (password != null) 'password': password,
        'is_register': isRegister,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Firebase login failed.',
        e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/me/');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
          'Failed to load user profile', e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/auth/me/', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException('Failed to update profile', e.response?.statusCode);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _apiClient.dio
          .post('/auth/logout/', data: {'refresh': refreshToken});
    } catch (_) {
      // Ignore network errors during logout
    }
  }
}
