/// Game rate payout entity model.
class GameRate {
  final String gameType;
  final String rate;

  const GameRate({
    required this.gameType,
    required this.rate,
  });

  factory GameRate.fromJson(Map<String, dynamic> json) {
    return GameRate(
      gameType: (json['game_type'] ?? '').toString(),
      rate: json['rate']?.toString() ?? '0.00',
    );
  }
}
