import 'package:dio/dio.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';
import '../dto/refresh_token_request_dto.dart';
import '../dto/refresh_token_response_dto.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../../../core/errors/app_exception.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<LoginResponseDto> login(LoginRequestDto dto) async {
    try {
      final response = await _dio.post('/auth/login/', data: dto.toJson());
      return LoginResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<LoginResponseDto> firebaseLogin({
    required String idToken,
    String? name,
    String? password,
    bool isRegister = false,
  }) async {
    try {
      final data = {
        'id_token': idToken,
        if (name != null) 'name': name,
        if (password != null) 'password': password,
        'is_register': isRegister,
      };
      final response = await _dio.post('/auth/firebase-login/', data: data);
      return LoginResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<RefreshTokenResponseDto> refreshToken(
      RefreshTokenRequestDto dto) async {
    try {
      final response =
          await _dio.post('/auth/token/refresh/', data: dto.toJson());
      return RefreshTokenResponseDto.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthenticatedUser> getProfile() async {
    try {
      final response = await _dio.get('/auth/me/');
      return AuthenticatedUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthenticatedUser> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/auth/me/', data: data);
      return AuthenticatedUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout/', data: {'refresh': refreshToken});
    } on DioException catch (_) {
      // Ignore logout errors if token already invalidated
    }
  }

  AppException _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final message = e.response?.data is Map &&
            (e.response?.data as Map).containsKey('detail')
        ? e.response?.data['detail']
        : e.response?.data is Map &&
                (e.response?.data as Map).containsKey('message')
            ? e.response?.data['message']
            : e.message;

    if (status == 401) {
      return UnauthorizedException(
          message?.toString() ?? 'Invalid credentials or session expired.');
    } else if (status == 403) {
      return AccountBlockedException(
          message?.toString() ?? 'Account disabled or unauthorized access.');
    } else if (status == 422 || status == 400) {
      return ValidationException(
          message?.toString() ?? 'Invalid request parameters.');
    } else if (status == 429) {
      return ServerException(
          'Too many login attempts. Please wait a few minutes.');
    } else if (status != null && status >= 500) {
      return ServerException(
          'Server error occurred ($status). Please try again later.');
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
          'Request timed out. Please check your internet connection.');
    }

    return NetworkException(
        message?.toString() ?? 'Unable to connect to server.');
  }
}
