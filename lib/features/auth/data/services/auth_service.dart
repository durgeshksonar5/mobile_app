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
      final errorMsg = _parseError(e.response?.data, 'Invalid phone number or password.');
      throw ServerException(errorMsg, e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiClient.dio.post('/auth/agent/register/', data: {
        'phone_number': phoneNumber,
        'password': password,
        'name': name,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMsg = _parseError(e.response?.data, 'Registration failed.');
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

  String _parseError(dynamic data, String defaultMsg) {
    if (data is Map<String, dynamic>) {
      if (data['detail'] is String) return data['detail'];
      if (data['error'] is String) return data['error'];
      if (data['message'] is String) return data['message'];
      if (data['non_field_errors'] is List) {
        return (data['non_field_errors'] as List).join(', ');
      }
      if (data['non_field_errors'] is String) return data['non_field_errors'];

      final errorList = <String>[];
      data.forEach((key, val) {
        String cleanKey = key;
        if (key == 'phone_number') cleanKey = 'Phone number';
        if (key == 'first_name') cleanKey = 'First name';
        if (key == 'last_name') cleanKey = 'Last name';
        if (key == 'name') cleanKey = 'Name';
        if (key == 'email') cleanKey = 'Email';
        if (key == 'password') cleanKey = 'Password';

        if (cleanKey == key && key.isNotEmpty) {
          cleanKey = key[0].toUpperCase() + key.substring(1).replaceAll('_', ' ');
        }

        String valStr = '';
        if (val is List) {
          valStr = val.join(", ");
        } else {
          valStr = val.toString();
        }

        if (valStr.toLowerCase().contains(cleanKey.toLowerCase())) {
          errorList.add(valStr);
        } else {
          errorList.add('$cleanKey: $valStr');
        }
      });
      if (errorList.isNotEmpty) {
        return errorList.join('\n');
      }
    }
    if (data is String) return data;
    return defaultMsg;
  }
}
