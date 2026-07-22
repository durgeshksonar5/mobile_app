import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/results_repository.dart';
import '../states/home_state.dart';
import '../../../../app/dependency_injection/providers.dart';

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repository = ref.watch(resultsRepositoryProvider);
  return HomeViewModel(repository);
});

class HomeViewModel extends StateNotifier<HomeState> {
  final ResultsRepository _repository;

  HomeViewModel(this._repository) : super(const HomeState()) {
    fetchMarkets();
  }

  void setActiveTab(String tab) {
    state = state.copyWith(activeTab: tab);
    if (tab == 'home') fetchMarkets();
    if (tab == 'passbook' || tab == 'funds') fetchPassbook();
    if (tab == 'my-bids') fetchBids();
    if (tab == 'game-rate') fetchGameRates();
  }

  Future<void> fetchMarkets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final markets = await _repository.getLiveResults();
      state = state.copyWith(isLoading: false, markets: markets);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchPassbook() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.getPassbookItems();
      state = state.copyWith(isLoading: false, passbookItems: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchBids() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bids = await _repository.getBids();
      state = state.copyWith(isLoading: false, bidsItems: bids);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchGameRates() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rates = await _repository.getGameRates();
      state = state.copyWith(isLoading: false, gameRates: rates);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitDeposit(int amount) async {
    await _repository.createDepositRequest(amount);
    await fetchPassbook();
  }

  Future<void> submitWithdraw(int amount) async {
    await _repository.createWithdrawRequest(amount);
    await fetchPassbook();
  }
}
