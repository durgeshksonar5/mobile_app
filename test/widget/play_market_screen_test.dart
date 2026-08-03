import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:king_wins_mobile_app/app/dependency_injection/providers.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/features/play_market/presentation/screens/play_market_screen.dart';
import 'package:king_wins_mobile_app/features/home/data/repositories/results_repository.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/market_result.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/passbook_item.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/bid_item.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/game_rate.dart';

class FakeResultsRepository implements ResultsRepository {
  @override
  Future<void> fetchAndSyncWhatsAppConfig() async {}
  @override
  Future<List<MarketResult>> getLiveResults() async => [];
  @override
  Future<List<MarketResult>> getSattaHistory(String marketName) async => [];
  @override
  Future<List<PassbookItem>> getPassbookItems() async => [];
  @override
  Future<List<BidItem>> getBids() async => [];
  @override
  Future<List<GameRate>> getGameRates() async => [];
  @override
  Future<void> placeBid({
    required String marketName,
    required String gameType,
    required String session,
    required String selectedNumber,
    required int amount,
  }) async {}
  @override
  Future<void> createDepositRequest(int amount) async {}
  @override
  Future<void> createWithdrawRequest(int amount) async {}
  @override
  Future<void> placeBidsBatch(List<Map<String, dynamic>> bids) async {}
}

void main() {
  setUp(() {
    AppConfig.initialize();
  });

  testWidgets('PlayMarketScreen renders market header and 11 Satta game modes',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resultsRepositoryProvider.overrideWithValue(FakeResultsRepository()),
        ],
        child: const MaterialApp(
          home: PlayMarketScreen(marketName: 'MILAN DAY'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('MILAN DAY'), findsWidgets);
    expect(find.text('Single Ank'), findsOneWidget);
    expect(find.text('Jodi'), findsOneWidget);
    expect(find.text('Single Panna'), findsOneWidget);
    expect(find.text('Double Panna'), findsOneWidget);
    expect(find.text('Triple Panna'), findsOneWidget);
    expect(find.text('(mpsp) SP Motor'), findsOneWidget);
    expect(find.text('(mpdp) DP Motor'), findsOneWidget);
    expect(find.text('SP DP'), findsOneWidget);
    expect(find.text('Family Panel'), findsOneWidget);
    expect(find.text('Half Sangam'), findsOneWidget);
    expect(find.text('Full Sangam'), findsOneWidget);
  });
}
