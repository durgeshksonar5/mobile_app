import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../home/data/repositories/results_repository.dart';
import '../states/play_market_state.dart';
import '../../../../core/utils/panna_generator.dart';

final playMarketViewModelProvider =
    StateNotifierProvider.family<PlayMarketViewModel, PlayMarketState, String>(
        (ref, marketName) {
  final repository = ref.watch(resultsRepositoryProvider);
  return PlayMarketViewModel(repository, marketName);
});

class PlayMarketViewModel extends StateNotifier<PlayMarketState> {
  final ResultsRepository _repository;
  final String marketName;

  PlayMarketViewModel(this._repository, this.marketName)
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
      state = state.copyWith(error: 'Please enter a valid amount.');
      return false;
    }

    final isMultiSelect = [
      'single',
      'jodi',
      'single-panna',
      'double-panna',
      'triple-panna',
      'sp-dp-tp'
    ].contains(state.activeGame);
    if (isMultiSelect && state.selectedNumbers.isEmpty) {
      state = state.copyWith(error: 'Please select at least one number.');
      return false;
    }

    int factor = 1;
    if (state.activeGame == 'sp-motor') {
      final len = (state.selectedNumber ?? '').length;
      if (len < 4 || len > 10) {
        state = state.copyWith(
            error: 'Please select between 4 and 10 digits for SP Motor.');
        return false;
      }
      factor = PannaGenerator.getSpMotorFactor(len);
    } else if (state.activeGame == 'dp-motor') {
      final len = (state.selectedNumber ?? '').length;
      if (len < 4 || len > 10) {
        state = state.copyWith(
            error: 'Please select between 4 and 10 digits for DP Motor.');
        return false;
      }
      factor = PannaGenerator.getDpMotorFactor(len);
    }

    final totalBet =
        amt * factor * (isMultiSelect ? state.selectedNumbers.length : 1);
    if (totalBet > walletBalance) {
      state = state.copyWith(
          error: 'Insufficient balance! This bet requires ₹$totalBet.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final targets =
          isMultiSelect ? state.selectedNumbers : [state.selectedNumber ?? ''];
      for (final numStr in targets) {
        await _repository.placeBid(
          marketName: marketName,
          gameType: state.activeGame.replaceAll('-', ' ').toUpperCase(),
          session: state.session.toUpperCase(),
          selectedNumber: numStr,
          amount: amt * factor,
        );
      }
      state = state.copyWith(isLoading: false, activeGame: 'list');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
