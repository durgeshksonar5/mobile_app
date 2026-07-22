/// Passbook item model for deposit/withdraw request history.
class PassbookItem {
  final int id;
  final String type; // 'deposit' or 'withdraw'
  final int amount; // Integer rupees
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final DateTime date;

  const PassbookItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory PassbookItem.fromDepositJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    num amt = json['amount'] is num
        ? json['amount']
        : num.tryParse(json['amount']?.toString() ?? '') ?? 0;
    return PassbookItem(
      id: parseId(json['id']),
      type: 'deposit',
      amount: amt.toInt(),
      status: (json['status'] ?? 'PENDING').toString(),
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory PassbookItem.fromWithdrawJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    num amt = json['amount'] is num
        ? json['amount']
        : num.tryParse(json['amount']?.toString() ?? '') ?? 0;
    return PassbookItem(
      id: parseId(json['id']),
      type: 'withdraw',
      amount: amt.toInt(),
      status: (json['status'] ?? 'PENDING').toString(),
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
