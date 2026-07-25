/// Typed domain entity for user wallet balance.
class WalletBalance {
  final int availableBalance;
  final String currencyCode;
  final int lockedBalance;
  final int bonusBalance;

  const WalletBalance({
    required this.availableBalance,
    this.currencyCode = 'INR',
    this.lockedBalance = 0,
    this.bonusBalance = 0,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    int parseNum(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) {
        return double.tryParse(val)?.toInt() ?? int.tryParse(val) ?? 0;
      }
      return 0;
    }

    final balance = parseNum(
      json['wallet_balance'] ??
          json['available_balance'] ??
          json['points'] ??
          json['balance'],
    );
    final locked = parseNum(json['locked_balance'] ?? 0);
    final bonus = parseNum(json['bonus_balance'] ?? 0);

    return WalletBalance(
      availableBalance: balance,
      currencyCode:
          (json['currency'] ?? json['currency_code'] ?? 'INR').toString(),
      lockedBalance: locked,
      bonusBalance: bonus,
    );
  }

  String get formattedBalance => availableBalance.toString();

  Map<String, dynamic> toJson() {
    return {
      'available_balance': availableBalance,
      'currency_code': currencyCode,
      'locked_balance': lockedBalance,
      'bonus_balance': bonusBalance,
    };
  }
}
