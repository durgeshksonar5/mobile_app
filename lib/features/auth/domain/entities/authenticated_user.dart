class AuthenticatedUser {
  final int id;
  final String phoneNumber;
  final String? name;
  final int walletBalance;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String? upiNumber;
  final bool isBlocked;

  const AuthenticatedUser({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.walletBalance = 0,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
    this.upiNumber,
    this.isBlocked = false,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    int parseNum(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) {
        return double.tryParse(val)?.toInt() ?? int.tryParse(val) ?? 0;
      }
      return 0;
    }

    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      if (val is num) return val != 0;
      return false;
    }

    return AuthenticatedUser(
      id: parseId(json['id']),
      phoneNumber: (json['phone_number'] ?? json['phone'] ?? '').toString(),
      name: json['name']?.toString() ?? json['first_name']?.toString(),
      walletBalance:
          parseNum(json['wallet_balance'] ?? json['points'] ?? json['balance']),
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      upiId: json['upi_id']?.toString(),
      upiNumber: json['upi_number']?.toString(),
      isBlocked: parseBool(json['is_blocked'] ?? json['blocked']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'wallet_balance': walletBalance,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'upi_id': upiId,
      'upi_number': upiNumber,
      'is_blocked': isBlocked,
    };
  }
}
