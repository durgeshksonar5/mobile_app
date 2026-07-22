import '../../domain/models/market_result.dart';
import '../../domain/models/passbook_item.dart';
import '../../domain/models/bid_item.dart';
import '../../domain/models/game_rate.dart';

class HomeState {
  final bool isLoading;
  final String
      activeTab; // 'home', 'passbook', 'my-bids', 'funds', 'game-rate', 'charts', 'settings'
  final List<MarketResult> markets;
  final List<PassbookItem> passbookItems;
  final List<BidItem> bidsItems;
  final List<GameRate> gameRates;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.activeTab = 'home',
    this.markets = const [],
    this.passbookItems = const [],
    this.bidsItems = const [],
    this.gameRates = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    String? activeTab,
    List<MarketResult>? markets,
    List<PassbookItem>? passbookItems,
    List<BidItem>? bidsItems,
    List<GameRate>? gameRates,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      activeTab: activeTab ?? this.activeTab,
      markets: markets ?? this.markets,
      passbookItems: passbookItems ?? this.passbookItems,
      bidsItems: bidsItems ?? this.bidsItems,
      gameRates: gameRates ?? this.gameRates,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
