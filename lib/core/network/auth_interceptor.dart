import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../config/app_config.dart';

typedef OnSessionExpired = void Function();

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorage;
  final OnSessionExpired? onSessionExpired;

  bool _isRefreshing = false;
  final List<_RequestCompleter> _failedQueue = [];

  AuthInterceptor({
    required this.secureStorage,
    this.onSessionExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Automatically unpack Django REST Framework paginated results or custom data envelopes
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('results') && map['results'] is List) {
        response.data = map['results'];
      } else if (map.containsKey('success') &&
          map.containsKey('data') &&
          map['data'] is List) {
        response.data = map['data'];
      }
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Prevent infinite loop if refresh token endpoint itself returned 401
      if (requestOptions.path.contains('/auth/token/refresh/') ||
          requestOptions.path.contains('/auth/login/')) {
        handler.next(err);
        return;
      }

      if (_isRefreshing) {
        // Queue this request while token is refreshing
        _failedQueue.add(_RequestCompleter(
          requestOptions: requestOptions,
          handler: handler,
        ));
        return;
      }

      _isRefreshing = true;
      final refreshToken = await secureStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
        await secureStorage.clearTokens();
        onSessionExpired?.call();
        handler.next(err);
        return;
      }

      try {
        final refreshDio = Dio();
        final response = await refreshDio.post(
          '${AppConfig.apiBaseUrl}/auth/token/refresh/',
          data: {'refresh': refreshToken},
        );

        final newAccess = response.data['access'] as String?;
        final newRefresh = response.data['refresh'] as String?;

        if (newAccess != null) {
          await secureStorage.saveAccessToken(newAccess);
          if (newRefresh != null) {
            await secureStorage.saveRefreshToken(newRefresh);
          }

          // Process queued requests
          _processQueue(newAccess);
          _isRefreshing = false;

          // Retry the original failed request with new access token
          requestOptions.headers['Authorization'] = 'Bearer $newAccess';
          final retriedResponse = await Dio().fetch(requestOptions);
          handler.resolve(retriedResponse);
          return;
        }
      } catch (refreshErr) {
        _rejectQueue(err);
        _isRefreshing = false;
        await secureStorage.clearTokens();
        onSessionExpired?.call();
      }
    }

    handler.next(err);
  }

  void _processQueue(String newToken) {
    for (final item in _failedQueue) {
      item.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      Dio().fetch(item.requestOptions).then(
            (res) => item.handler.resolve(res),
            onError: (e) => item.handler.reject(e as DioException),
          );
    }
    _failedQueue.clear();
  }

  void _rejectQueue(DioException err) {
    for (final item in _failedQueue) {
      item.handler.reject(err);
    }
    _failedQueue.clear();
  }
}

class _RequestCompleter {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _RequestCompleter({
    required this.requestOptions,
    required this.handler,
  });
}
