import '../../domain/models/wallet_balance.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../services/wallet_api_service.dart';
import '../../../../core/storage/preferences_service.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletApiService _apiService;
  final PreferencesService _preferences;
  WalletBalance? _cachedBalance;

  WalletRepositoryImpl(this._apiService, this._preferences);

  @override
  Future<WalletBalance> getWalletBalance() async {
    try {
      final balance = await _apiService.fetchWalletBalance();
      _cachedBalance = balance;
      final cachedUser = await _preferences.getUser();
      if (cachedUser != null) {
        cachedUser['wallet_balance'] = balance.availableBalance;
        await _preferences.saveUser(cachedUser);
      }
      return balance;
    } catch (e) {
      if (_cachedBalance != null) {
        return _cachedBalance!;
      }
      final cachedUser = await _preferences.getUser();
      if (cachedUser != null) {
        return WalletBalance.fromJson(cachedUser);
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    _cachedBalance = null;
  }
}
