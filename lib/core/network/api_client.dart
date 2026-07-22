import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Centralized Dio HTTP ApiClient instance.
class ApiClient {
  late final Dio dio;

  ApiClient({
    required SecureStorageService secureStorage,
    OnSessionExpired? onSessionExpired,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConfig.networkTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConfig.networkTimeoutMs),
        sendTimeout: const Duration(milliseconds: AppConfig.networkTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        secureStorage: secureStorage,
        onSessionExpired: onSessionExpired,
      ),
    );
  }
}
