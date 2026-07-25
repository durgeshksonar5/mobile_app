import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../home/data/repositories/results_repository.dart';
import '../states/play_market_state.dart';
import '../../../../core/utils/panna_generator.dart';

import '../../../wallet/presentation/view_models/wallet_view_model.dart';

final playMarketViewModelProvider =
    StateNotifierProvider.family<PlayMarketViewModel, PlayMarketState, String>(
        (ref, marketName) {
  final repository = ref.watch(resultsRepositoryProvider);
  return PlayMarketViewModel(repository, marketName, ref);
});

class PlayMarketViewModel extends StateNotifier<PlayMarketState> {
  final ResultsRepository _repository;
  final String marketName;
  final Ref _ref;

  PlayMarketViewModel(this._repository, this.marketName, this._ref)
      : super(const PlayMarketState()) {
    checkMarketStatus();
  }

  Future<void> checkMarketStatus() async {
    try {
      final markets = await _repository.getLiveResults();
      final market = markets.firstWhere(
        (m) => m.marketName.toUpperCase() == marketName.toUpperCase(),
        orElse: () => markets.first,
      );

      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final info = market.getDisplayInfo(todayStr, now);

      if (info.statusType == 'running_close' || info.statusType == 'closed') {
        state = state.copyWith(openDisabled: true, session: 'close');
      }
    } catch (_) {}
  }

  void selectGame(String gameId) {
    state = PlayMarketState(
      activeGame: gameId,
      openDisabled: state.openDisabled,
      session: state.openDisabled && gameId != 'jodi' ? 'close' : 'open',
    );
  }

  void setSession(String session) {
    if (state.openDisabled && session == 'open' && state.activeGame != 'jodi') {
      return;
    }
    state = state.copyWith(session: session);
  }

  void toggleSelectedNumber(String numStr) {
    final list = List<String>.from(state.selectedNumbers);
    if (list.contains(numStr)) {
      list.remove(numStr);
    } else {
      list.add(numStr);
    }
    state = state.copyWith(selectedNumbers: list, selectedNumber: numStr);
  }

  void setSelectedNumber(String? numStr) {
    state = state.copyWith(selectedNumber: numStr);
  }

  void toggleMotorDigit(String digit) {
    String current = state.selectedNumber ?? '';
    if (current.contains(digit)) {
      current = current.replaceAll(digit, '');
    } else {
      current = current + digit;
    }
    final sorted = current.split('')..sort();
    final result = sorted.join('');
    state = state.copyWith(selectedNumber: result.isEmpty ? null : result);
  }

  void setAmount(String amt) {
    state = state.copyWith(amount: amt);
  }

  void setSpDpTpAnk(int ank) {
    state = state.copyWith(spDpTpAnk: ank);
  }

  void toggleSpDpTpChoice(String choice) {
    final list = List<String>.from(state.spDpTpChoices);
    if (list.contains(choice)) {
      if (list.length > 1) list.remove(choice);
    } else {
      list.add(choice);
    }
    state = state.copyWith(spDpTpChoices: list);
  }

  void setSelectedAnk(int ank) {
    state = state.copyWith(selectedAnk: ank);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setHalfSangamFields(String panna, String digit, String type) {
    state = state.copyWith(
        halfPanna: panna, halfDigit: digit, halfSangamType: type);
  }

  void setFullSangamFields(String openPanna, String closePanna) {
    state =
        state.copyWith(fullOpenPanna: openPanna, fullClosePanna: closePanna);
  }

  void setFamilyPanna(String panna) {
    state = state.copyWith(familyPanna: panna);
  }

  Future<bool> placeBet({required int walletBalance}) async {
    final amt = int.tryParse(state.amount.trim());
    if (amt == null || amt <= 0) {
      state = state.copyWith(error: 'Please enter a valid points amount.');
      return false;
    }

    final mult = state.multiplier;
    if (mult <= 0) {
      if (state.activeGame == 'sp-motor' || state.activeGame == 'dp-motor') {
        state = state.copyWith(
            error: 'Please select a minimum of 4 unique digits.');
      } else if (state.activeGame == 'family-panel') {
        state = state.copyWith(
            error: 'Please enter a valid 3-digit Panna for Family Panel.');
      } else if (state.activeGame == 'half-sagam' ||
          state.activeGame == 'full-sagam') {
        state = state.copyWith(
            error: 'Please complete all required Panna and Ank fields.');
      } else {
        state = state.copyWith(error: 'Please select at least one number.');
      }
      return false;
    }

    // 40 Pannas Limit check
    if (['single-panna', 'double-panna', 'triple-panna']
            .contains(state.activeGame) &&
        state.selectedNumbers.length > 40) {
      state = state.copyWith(
          error:
              'Maximum limit exceeded! You can select a maximum of 40 pannas per session.');
      return false;
    }

    final totalBet = amt * mult;
    if (totalBet > walletBalance) {
      state = state.copyWith(
          error: 'Insufficient balance! Total bid requires ₹$totalBet.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      List<String> targets = [];
      if (['single', 'jodi', 'single-panna', 'double-panna', 'triple-panna']
          .contains(state.activeGame)) {
        targets = state.selectedNumbers;
      } else if (state.activeGame == 'sp-dp-tp') {
        targets = PannaGenerator.getSpDpTpPannas(
            state.spDpTpAnk, state.spDpTpChoices);
      } else if (state.activeGame == 'family-panel') {
        targets = PannaGenerator.getFamilyPannas(state.familyPanna);
      } else if (state.activeGame == 'sp-motor' ||
          state.activeGame == 'dp-motor') {
        targets = [state.selectedNumber ?? ''];
      } else if (state.activeGame == 'half-sagam') {
        targets = [
          state.halfSangamType == 'open_panna_close_digit'
              ? '${state.halfPanna}-${state.halfDigit}'
              : '${state.halfDigit}-${state.halfPanna}'
        ];
      } else if (state.activeGame == 'full-sagam') {
        targets = ['${state.fullOpenPanna}-${state.fullClosePanna}'];
      }

      for (final numStr in targets) {
        await _repository.placeBid(
          marketName: marketName,
          gameType: state.activeGame.replaceAll('-', ' ').toUpperCase(),
          session: state.session.toUpperCase(),
          selectedNumber: numStr,
          amount: amt,
        );
      }
      _ref.read(walletViewModelProvider.notifier).fetchBalance(isRefresh: true);
      state = state.copyWith(isLoading: false, activeGame: 'list');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
