import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/wallet_balance.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../states/wallet_state.dart';
import '../../../../app/dependency_injection/providers.dart';

final walletViewModelProvider =
    StateNotifierProvider<WalletViewModel, WalletState>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletViewModel(repository);
});

class WalletViewModel extends StateNotifier<WalletState> {
  final WalletRepository _repository;
  DateTime? _lastFetchTime;

  WalletViewModel(this._repository) : super(const WalletState());

  Future<void> fetchBalance({bool isRefresh = false}) async {
    if (!isRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMilliseconds < 1000 &&
        state.isLoaded) {
      return;
    }

    if (state.isLoaded) {
      state = state.copyWith(status: WalletStatus.refreshing);
    } else {
      state = state.copyWith(status: WalletStatus.loading);
    }

    try {
      final balance = await _repository.getWalletBalance();
      _lastFetchTime = DateTime.now();
      state = state.copyWith(
        status: WalletStatus.loaded,
        balance: balance,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status:
            state.balance != null ? WalletStatus.loaded : WalletStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void updateBalanceLocally(int newBalance) {
    if (state.balance != null) {
      final updated = WalletBalance(
        availableBalance: newBalance,
        currencyCode: state.balance!.currencyCode,
        lockedBalance: state.balance!.lockedBalance,
        bonusBalance: state.balance!.bonusBalance,
      );
      state = state.copyWith(balance: updated);
    }
  }

  void reset() {
    _repository.clearCache();
    _lastFetchTime = null;
    state = const WalletState();
  }
}
