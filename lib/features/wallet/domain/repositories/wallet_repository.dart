import '../models/wallet_balance.dart';

abstract class WalletRepository {
  Future<WalletBalance> getWalletBalance();
  Future<void> clearCache();
}
