import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';

class ResultsService {
  final ApiClient _apiClient;

  ResultsService(this._apiClient);

  Future<List<dynamic>> getLiveResults() async {
    try {
      final response = await _apiClient.dio.get('/results/live/');
      if (response.data is List) {
        return response.data as List;
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
          'Failed to load live results', e.response?.statusCode);
    }
  }

  Future<List<dynamic>> getSattaHistory(
      {required String marketName, int pageSize = 100}) async {
    try {
      final response = await _apiClient.dio.get(
        '/results/history/',
        queryParameters: {
          'market_name': marketName,
          'page_size': pageSize,
        },
      );
      if (response.data is List) {
        return response.data as List;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createDepositRequest(int amount) async {
    try {
      final response = await _apiClient.dio
          .post('/deposit-requests/', data: {'amount': amount});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ??
            'Failed to submit deposit request.',
        e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> createWithdrawRequest(int amount) async {
    try {
      final response = await _apiClient.dio
          .post('/withdraw-requests/', data: {'amount': amount});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ??
            'Failed to submit withdrawal request.',
        e.response?.statusCode,
      );
    }
  }

  Future<List<dynamic>> getDepositRequests() async {
    try {
      final response = await _apiClient.dio.get('/deposit-requests/');
      if (response.data is List) return response.data as List;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getWithdrawRequests() async {
    try {
      final response = await _apiClient.dio.get('/withdraw-requests/');
      if (response.data is List) return response.data as List;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> placeBid({
    required String marketName,
    required String gameType,
    required String session,
    required String selectedNumber,
    required int amount,
  }) async {
    try {
      final response = await _apiClient.dio.post('/bets/', data: {
        'market_name': marketName,
        'game_type': gameType,
        'session': session,
        'selected_number': selectedNumber,
        'amount': amount,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['error']?.toString() ?? 'Failed to place bet.',
        e.response?.statusCode,
      );
    }
  }

  Future<List<dynamic>> getBids() async {
    try {
      final response = await _apiClient.dio.get('/bets/');
      if (response.data is List) return response.data as List;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getGameRates() async {
    try {
      final response = await _apiClient.dio.get('/game-rates/');
      if (response.data is List) return response.data as List;
      return [];
    } catch (_) {
      return [];
    }
  }
}
