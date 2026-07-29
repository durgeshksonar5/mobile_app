import '../../../../core/utils/panna_generator.dart';

/// Bid / Bet record item model.
class BidItem {
  final dynamic id;
  final String marketName;
  final String gameType;
  final String session;
  final String selectedNumber;
  final int amount;
  final String status; // 'Active', 'WON', 'LOST'
  final int winAmount;
  final dynamic createdAt;

  int get baseAmount {
    final gType = gameType.toUpperCase();
    if (gType == 'SP MOTOR') {
      final digits = selectedNumber.split('').toSet().length;
      final factors = {4: 4, 5: 10, 6: 20, 7: 35, 8: 56, 9: 84, 10: 120};
      final factor = factors[digits] ?? 1;
      return (amount / factor).round();
    } else if (gType == 'DP MOTOR') {
      final digits = selectedNumber.split('').toSet().length;
      final factors = {4: 12, 5: 20, 6: 30, 7: 42, 8: 56, 9: 72, 10: 90};
      final factor = factors[digits] ?? 1;
      return (amount / factor).round();
    } else if (gType == 'FAMILY PANEL') {
      final digits = selectedNumber.split('').toSet().length;
      final factor = digits == 3 ? 8 : (digits == 2 ? 6 : 4);
      return (amount / factor).round();
    } else if (gType == 'SP DP TP') {
      final parts = selectedNumber.split('-');
      if (parts.length == 2) {
        final choice = parts[1].toUpperCase();
        final factor = choice == 'SP' ? 12 : (choice == 'DP' ? 9 : 10);
        return (amount / factor).round();
      }
    } else if (gType == 'CP') {
      return (amount / 10).round();
    } else if (gType == 'FAMILY JODI') {
      final members = PannaGenerator.getJodiFamilyMembers(selectedNumber);
      final factor = members.isNotEmpty ? members.length : 1;
      return (amount / factor).round();
    }
    return amount;
  }

  const BidItem({
    required this.id,
    required this.marketName,
    required this.gameType,
    required this.session,
    required this.selectedNumber,
    required this.amount,
    this.status = 'Active',
    this.winAmount = 0,
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
      winAmount: json['win_amount'] != null
          ? (num.tryParse(json['win_amount'].toString()) ?? 0).toInt()
          : 0,
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
      'win_amount': winAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
