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

      final openDisabled = info.statusType == 'running_close' || info.statusType == 'closed';
      final isMarketClosed = info.statusType == 'closed';

      state = state.copyWith(
        openDisabled: openDisabled,
        isMarketClosed: isMarketClosed,
        session: openDisabled ? 'close' : 'open',
      );
    } catch (_) {}
  }

  void selectGame(String gameId) {
    String initialSession = 'open';
    if (state.openDisabled && gameId != 'jodi' && gameId != 'family-jodi') {
      initialSession = 'close';
    }
    state = PlayMarketState(
      activeGame: gameId,
      openDisabled: state.openDisabled,
      session: initialSession,
    );
  }

  void setSession(String session) {
    if (state.openDisabled && session == 'open' && state.activeGame != 'jodi' && state.activeGame != 'family-jodi') {
      return;
    }
    if (state.activeGame == 'family-jodi' && session == 'close') {
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

  void setSpDpAnk(int ank) {
    state = state.copyWith(spDpAnk: ank);
  }

  void toggleSpDpChoice(String choice) {
    final list = List<String>.from(state.spDpChoices);
    if (list.contains(choice)) {
      if (list.length > 1) list.remove(choice);
    } else {
      list.add(choice);
    }
    state = state.copyWith(spDpChoices: list);
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

    if (state.openDisabled &&
        (state.activeGame == 'jodi' ||
            state.activeGame == 'family-jodi' ||
            state.activeGame == 'half-sagam' ||
            state.activeGame == 'full-sagam')) {
      state = state.copyWith(
          error:
              'Jodi, Family Jodi, Half Sangam, and Full Sangam bids are not allowed when the Open session is closed.');
      return false;
    }

    if (state.session.toLowerCase() == 'close' && state.activeGame == 'family-jodi') {
      state = state.copyWith(
          error: 'Family Jodi bids are only allowed in the Open session.');
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
      } else if (state.activeGame == 'cp' || state.activeGame == 'family-jodi') {
        state = state.copyWith(
            error: 'Please enter a valid 2-digit number.');
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
      final List<_BidToPlace> bids = [];

      if (['single', 'jodi', 'single-panna', 'double-panna', 'triple-panna']
          .contains(state.activeGame)) {
        for (final numStr in state.selectedNumbers) {
          bids.add(_BidToPlace(numStr, amt));
        }
      } else if (state.activeGame == 'sp-dp') {
        for (final numStr in state.selectedNumbers) {
          for (final choice in state.spDpChoices) {
            final choiceFactor = choice == 'SP' ? 12 : 9;
            bids.add(_BidToPlace('$numStr-$choice', amt * choiceFactor));
          }
        }
      } else if (state.activeGame == 'family-panel') {
        if (!PannaGenerator.isValidPanna(state.familyPanna)) {
          state = state.copyWith(
              isLoading: false,
              error: 'Invalid Panna! Digits must be in ascending order (where 0 is 10, e.g. 778 instead of 787).');
          return false;
        }
        final sorted = PannaGenerator.sortPanna(state.familyPanna);
        final factor = PannaGenerator.getFamilyPannas(state.familyPanna).length;
        bids.add(_BidToPlace(sorted, amt * factor));
      } else if (state.activeGame == 'cp') {
        final num = state.selectedNumber ?? '';
        if (num.length != 2 || int.tryParse(num) == null) {
          state = state.copyWith(
              isLoading: false,
              error: 'Please enter a valid 2-digit number for CP.');
          return false;
        }
        bids.add(_BidToPlace(num, amt * 10));
      } else if (state.activeGame == 'family-jodi') {
        final num = state.selectedNumber ?? '';
        if (num.length != 2 || int.tryParse(num) == null) {
          state = state.copyWith(
              isLoading: false,
              error: 'Please enter a valid 2-digit number for Family Jodi.');
          return false;
        }
        final factor = PannaGenerator.getJodiFamilyMembers(num).length;
        bids.add(_BidToPlace(num, amt * factor));
      } else if (state.activeGame == 'sp-motor' ||
          state.activeGame == 'dp-motor') {
        final len = (state.selectedNumber ?? '').length;
        final factor = state.activeGame == 'sp-motor'
            ? PannaGenerator.getSpMotorFactor(len)
            : PannaGenerator.getDpMotorFactor(len);
        bids.add(_BidToPlace(state.selectedNumber ?? '', amt * factor));
      } else if (state.activeGame == 'half-sagam') {
        final sortedHalf = PannaGenerator.sortPanna(state.halfPanna);
        final numStr = state.halfSangamType == 'open_panna_close_digit'
            ? '$sortedHalf${state.halfDigit}'
            : '${state.halfDigit}$sortedHalf';
        bids.add(_BidToPlace(numStr, amt));
      } else if (state.activeGame == 'full-sagam') {
        final sortedOpen = PannaGenerator.sortPanna(state.fullOpenPanna);
        final sortedClose = PannaGenerator.sortPanna(state.fullClosePanna);
        final numStr = '$sortedOpen$sortedClose';
        bids.add(_BidToPlace(numStr, amt));
      }

      final List<Map<String, dynamic>> bidsPayload = bids.map((bid) => {
        'market_name': marketName,
        'game_type': state.activeGame.replaceAll('-', ' ').toUpperCase(),
        'session': state.session.toUpperCase(),
        'selected_number': bid.selectedNumber,
        'amount': bid.amount,
      }).toList();

      await _repository.placeBidsBatch(bidsPayload);
      _ref.read(walletViewModelProvider.notifier).fetchBalance(isRefresh: true);
      state = state.copyWith(isLoading: false, activeGame: 'list');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

class _BidToPlace {
  final String selectedNumber;
  final int amount;
  _BidToPlace(this.selectedNumber, this.amount);
}
