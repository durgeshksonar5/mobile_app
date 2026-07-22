/// Bid / Bet record item model.
class BidItem {
  final dynamic id;
  final String marketName;
  final String gameType;
  final String session;
  final String selectedNumber;
  final int amount;
  final String status; // 'Active', 'WON', 'LOST'
  final DateTime createdAt;

  const BidItem({
    required this.id,
    required this.marketName,
    required this.gameType,
    required this.session,
    required this.selectedNumber,
    required this.amount,
    this.status = 'Active',
    required this.createdAt,
  });

  factory BidItem.fromJson(Map<String, dynamic> json) {
    num amt = json['amount'] is num
        ? json['amount']
        : num.tryParse(json['amount']?.toString() ?? '') ?? 0;
    return BidItem(
      id: json['id'] ?? 0,
      marketName: (json['market_name'] ?? '').toString(),
      gameType: (json['game_type'] ?? '').toString(),
      session: (json['session'] ?? 'OPEN').toString(),
      selectedNumber: (json['selected_number'] ?? '').toString(),
      amount: amt.toInt(),
      status: (json['status'] ?? 'Active').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'market_name': marketName,
      'game_type': gameType,
      'session': session,
      'selected_number': selectedNumber,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
