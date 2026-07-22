/// User domain entity representing authenticated profile data.
class UserModel {
  final int? id;
  final String name;
  final String phoneNumber;
  final int
      walletBalance; // Stored in integer rupees for clean money representation
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String? upiNumber;
  final bool isBlocked;

  const UserModel({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.walletBalance = 0,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
    this.upiNumber,
    this.isBlocked = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
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

    return UserModel(
      id: parseId(json['id']),
      name: (json['name'] ?? json['first_name'] ?? 'User').toString(),
      phoneNumber: (json['phone_number'] ?? json['phone'] ?? '').toString(),
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
      'name': name,
      'phone_number': phoneNumber,
      'wallet_balance': walletBalance,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'upi_id': upiId,
      'upi_number': upiNumber,
      'is_blocked': isBlocked,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    int? walletBalance,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? upiId,
    String? upiNumber,
    bool? isBlocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      walletBalance: walletBalance ?? this.walletBalance,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      upiId: upiId ?? this.upiId,
      upiNumber: upiNumber ?? this.upiNumber,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
