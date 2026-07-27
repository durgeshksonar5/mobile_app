import '../../../../core/utils/panna_generator.dart';

class PlayMarketState {
  final bool isLoading;
  final String
      activeGame; // 'list', 'single', 'jodi', 'single-panna', 'double-panna', 'triple-panna', 'sp-motor', 'dp-motor', 'sp-dp-tp', 'half-sagam', 'full-sagam', 'family-panel'
  final String session; // 'open' or 'close'
  final bool openDisabled;
  final bool isMarketClosed;
  final String? selectedNumber;
  final List<String> selectedNumbers;
  final String amount;
  final int selectedAnk; // 0-9 or -1 for 'All'
  final String searchQuery;
  final int spDpTpAnk; // 0-9 base digit for SP DP TP
  final List<String> spDpTpChoices;
  final String
      halfSangamType; // 'open_panna_close_digit' or 'open_digit_close_panna'
  final String halfPanna;
  final String halfDigit;
  final String fullOpenPanna;
  final String fullClosePanna;
  final String familyPanna;
  final String? error;

  const PlayMarketState({
    this.isLoading = false,
    this.activeGame = 'list',
    this.session = 'open',
    this.openDisabled = false,
    this.isMarketClosed = false,
    this.selectedNumber,
    this.selectedNumbers = const [],
    this.amount = '',
    this.selectedAnk = -1,
    this.searchQuery = '',
    this.spDpTpAnk = 0,
    this.spDpTpChoices = const ['SP'],
    this.halfSangamType = 'open_panna_close_digit',
    this.halfPanna = '',
    this.halfDigit = '',
    this.fullOpenPanna = '',
    this.fullClosePanna = '',
    this.familyPanna = '',
    this.error,
  });

  int get multiplier {
    if (activeGame == 'single' ||
        activeGame == 'jodi' ||
        activeGame == 'single-panna' ||
        activeGame == 'double-panna' ||
        activeGame == 'triple-panna') {
      return selectedNumbers.length;
    } else if (activeGame == 'sp-motor') {
      final len = (selectedNumber ?? '').length;
      if (len < 4) return 0;
      return PannaGenerator.getSpMotorFactor(len);
    } else if (activeGame == 'dp-motor') {
      final len = (selectedNumber ?? '').length;
      if (len < 4) return 0;
      return PannaGenerator.getDpMotorFactor(len);
    } else if (activeGame == 'sp-dp-tp') {
      int factor = 0;
      for (final choice in spDpTpChoices) {
        if (choice == 'SP') factor += 12;
        if (choice == 'DP') factor += 9;
        if (choice == 'TP') factor += 10;
      }
      return selectedNumbers.length * factor;
    } else if (activeGame == 'family-panel') {
      if (!PannaGenerator.isValidPanna(familyPanna)) return 0;
      return PannaGenerator.getFamilyPannas(familyPanna).length;
    } else if (activeGame == 'half-sagam') {
      if (halfPanna.length == 3 && halfDigit.length == 1) return 1;
      return 0;
    } else if (activeGame == 'full-sagam') {
      if (fullOpenPanna.length == 3 && fullClosePanna.length == 3) return 1;
      return 0;
    }
    return 0;
  }

  PlayMarketState copyWith({
    bool? isLoading,
    String? activeGame,
    String? session,
    bool? openDisabled,
    bool? isMarketClosed,
    String? selectedNumber,
    List<String>? selectedNumbers,
    String? amount,
    int? selectedAnk,
    String? searchQuery,
    int? spDpTpAnk,
    List<String>? spDpTpChoices,
    String? halfSangamType,
    String? halfPanna,
    String? halfDigit,
    String? fullOpenPanna,
    String? fullClosePanna,
    String? familyPanna,
    String? error,
    bool clearError = false,
  }) {
    return PlayMarketState(
      isLoading: isLoading ?? this.isLoading,
      activeGame: activeGame ?? this.activeGame,
      session: session ?? this.session,
      openDisabled: openDisabled ?? this.openDisabled,
      isMarketClosed: isMarketClosed ?? this.isMarketClosed,
      selectedNumber: selectedNumber ?? this.selectedNumber,
      selectedNumbers: selectedNumbers ?? this.selectedNumbers,
      amount: amount ?? this.amount,
      selectedAnk: selectedAnk ?? this.selectedAnk,
      searchQuery: searchQuery ?? this.searchQuery,
      spDpTpAnk: spDpTpAnk ?? this.spDpTpAnk,
      spDpTpChoices: spDpTpChoices ?? this.spDpTpChoices,
      halfSangamType: halfSangamType ?? this.halfSangamType,
      halfPanna: halfPanna ?? this.halfPanna,
      halfDigit: halfDigit ?? this.halfDigit,
      fullOpenPanna: fullOpenPanna ?? this.fullOpenPanna,
      fullClosePanna: fullClosePanna ?? this.fullClosePanna,
      familyPanna: familyPanna ?? this.familyPanna,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
