class PlayMarketState {
  final bool isLoading;
  final String
      activeGame; // 'list', 'single', 'jodi', 'single-panna', 'double-panna', 'triple-panna', 'sp-motor', 'dp-motor', 'sp-dp-tp', 'half-sagam', 'full-sagam', 'family-panel'
  final String session; // 'open' or 'close'
  final bool openDisabled;
  final String? selectedNumber;
  final List<String> selectedNumbers;
  final String amount;
  final int selectedAnk; // 0-9 or -1 for 'All'
  final String searchQuery;
  final List<String> spDpTpChoices;
  final String halfSangamType;
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
    this.selectedNumber,
    this.selectedNumbers = const [],
    this.amount = '',
    this.selectedAnk = -1,
    this.searchQuery = '',
    this.spDpTpChoices = const ['SP'],
    this.halfSangamType = 'open_panna_close_digit',
    this.halfPanna = '',
    this.halfDigit = '',
    this.fullOpenPanna = '',
    this.fullClosePanna = '',
    this.familyPanna = '',
    this.error,
  });

  PlayMarketState copyWith({
    bool? isLoading,
    String? activeGame,
    String? session,
    bool? openDisabled,
    String? selectedNumber,
    List<String>? selectedNumbers,
    String? amount,
    int? selectedAnk,
    String? searchQuery,
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
      selectedNumber: selectedNumber ?? this.selectedNumber,
      selectedNumbers: selectedNumbers ?? this.selectedNumbers,
      amount: amount ?? this.amount,
      selectedAnk: selectedAnk ?? this.selectedAnk,
      searchQuery: searchQuery ?? this.searchQuery,
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
