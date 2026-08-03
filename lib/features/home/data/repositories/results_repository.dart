import '../../domain/models/market_result.dart';
import '../../domain/models/passbook_item.dart';
import '../../domain/models/bid_item.dart';
import '../../domain/models/game_rate.dart';
import '../services/results_service.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/services/external_link_service.dart';

class ResultsRepository {
  final ResultsService _resultsService;
  final PreferencesService _preferences;

  ResultsRepository(this._resultsService, this._preferences);

  Future<void> fetchAndSyncWhatsAppConfig() async {
    try {
      final config = await _resultsService.getWhatsAppConfig();
      if (config.isNotEmpty) {
        ExternalLinkService.updateWhatsAppConfig(
          support: config['support_whatsapp']?.toString(),
          deposit: config['deposit_whatsapp']?.toString(),
          withdraw: config['withdraw_whatsapp']?.toString(),
        );
      }
    } catch (_) {}
  }

  Future<List<MarketResult>> getLiveResults() async {
    fetchAndSyncWhatsAppConfig();
    final rawList = await _resultsService.getLiveResults();

    return rawList
        .where((item) =>
            item is Map<String, dynamic> && item['market_name'] != null)
        .map((item) => MarketResult.fromJson(item as Map<String, dynamic>))
        .where((m) =>
            !m.marketName.toUpperCase().contains('WHATSAPP') &&
            !m.marketName.toUpperCase().contains('WHATSAAP'))
        .toList();
  }

  Future<List<MarketResult>> getSattaHistory(String marketName) async {
    final rawList =
        await _resultsService.getSattaHistory(marketName: marketName);
    return rawList
        .where((item) =>
            item is Map<String, dynamic> && item['market_name'] != null)
        .map((item) => MarketResult.fromJson(item as Map<String, dynamic>))
        .where((m) =>
            !m.marketName.toUpperCase().contains('WHATSAPP') &&
            !m.marketName.toUpperCase().contains('WHATSAAP'))
        .toList();
  }

  Future<List<PassbookItem>> getPassbookItems() async {
    final deposits = await _resultsService.getDepositRequests();
    final withdraws = await _resultsService.getWithdrawRequests();

    final List<PassbookItem> items = [];

    for (final d in deposits) {
      if (d is Map<String, dynamic>) {
        items.add(PassbookItem.fromDepositJson(d));
      }
    }

    for (final w in withdraws) {
      if (w is Map<String, dynamic>) {
        items.add(PassbookItem.fromWithdrawJson(w));
      }
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Future<void> createDepositRequest(int amount) async {
    await _resultsService.createDepositRequest(amount);
  }

  Future<void> createWithdrawRequest(int amount) async {
    await _resultsService.createWithdrawRequest(amount);
  }

  Future<void> placeBid({
    required String marketName,
    required String gameType,
    required String session,
    required String selectedNumber,
    required int amount,
  }) async {
    await _resultsService.placeBid(
      marketName: marketName,
      gameType: gameType,
      session: session,
      selectedNumber: selectedNumber,
      amount: amount,
    );

    await _preferences.saveLocalBid({
      'id': 'bid_${DateTime.now().millisecondsSinceEpoch}',
      'market_name': marketName,
      'game_type': gameType,
      'session': session,
      'selected_number': selectedNumber,
      'amount': amount,
      'status': 'Active',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> placeBidsBatch(List<Map<String, dynamic>> bids) async {
    await _resultsService.placeBidsBatch(bids: bids);

    for (final bid in bids) {
      await _preferences.saveLocalBid({
        'id': 'bid_${DateTime.now().millisecondsSinceEpoch}_${bid['selected_number']}',
        'market_name': bid['market_name'],
        'game_type': bid['game_type'],
        'session': bid['session'],
        'selected_number': bid['selected_number'],
        'amount': bid['amount'],
        'status': 'Active',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<BidItem>> getBids() async {
    try {
      final rawList = await _resultsService.getBids();
      if (rawList.isNotEmpty) {
        return rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => BidItem.fromJson(item))
            .toList();
      }
    } catch (_) {}

    final localBids = await _preferences.getLocalBids();
    return localBids.map((map) => BidItem.fromJson(map)).toList();
  }

  Future<List<GameRate>> getGameRates() async {
    try {
      final rawList = await _resultsService.getGameRates();
      if (rawList.isNotEmpty) {
        return rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => GameRate.fromJson(item))
            .toList();
      }
    } catch (_) {}

    // Static fallback rates matching web source
    return const [
      GameRate(gameType: 'Single', rate: '9.00'),
      GameRate(gameType: 'Jodi', rate: '90.00'),
      GameRate(gameType: 'Single Panna', rate: '140.00'),
      GameRate(gameType: 'Double Panna', rate: '280.00'),
      GameRate(gameType: 'Triple Panna', rate: '700.00'),
      GameRate(gameType: 'Half Sangam', rate: '1000.00'),
      GameRate(gameType: 'Full Sangam', rate: '10000.00'),
    ];
  }
}
