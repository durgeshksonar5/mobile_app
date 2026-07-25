import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/wallet_balance.dart';

class WalletApiService {
  final ApiClient _apiClient;

  WalletApiService(this._apiClient);

  Future<WalletBalance> fetchWalletBalance() async {
    try {
      final response = await _apiClient.dio.get('/auth/me/');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final userObj =
            data.containsKey('data') && data['data'] is Map<String, dynamic>
                ? data['data'] as Map<String, dynamic>
                : data;
        return WalletBalance.fromJson(userObj);
      }
      throw const ServerException(
          'Invalid response format for wallet balance.');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        throw const UnauthorizedException('Session expired.');
      } else if (status == 403) {
        throw const AccountBlockedException('Account unauthorized.');
      }
      throw ServerException('Failed to fetch wallet balance.', status);
    }
  }
}
