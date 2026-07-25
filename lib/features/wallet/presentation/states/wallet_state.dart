import '../../domain/models/wallet_balance.dart';

enum WalletStatus {
  initial,
  loading,
  loaded,
  refreshing,
  error,
  offline,
  unauthorized
}

class WalletState {
  final WalletStatus status;
  final WalletBalance? balance;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.balance,
    this.errorMessage,
  });

  bool get isLoading => status == WalletStatus.loading;
  bool get isRefreshing => status == WalletStatus.refreshing;
  bool get isLoaded =>
      status == WalletStatus.loaded || status == WalletStatus.refreshing;
  int get displayBalance => balance?.availableBalance ?? 0;
  String get formattedBalance => balance?.formattedBalance ?? '0';

  WalletState copyWith({
    WalletStatus? status,
    WalletBalance? balance,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
