import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/play_market_view_model.dart';
import '../states/play_market_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/panna_generator.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';

class PlayMarketScreen extends ConsumerWidget {
  final String marketName;

  const PlayMarketScreen({super.key, required this.marketName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decodedName = Uri.decodeComponent(marketName);
    final state = ref.watch(playMarketViewModelProvider(decodedName));
    final notifier =
        ref.read(playMarketViewModelProvider(decodedName).notifier);
    final authState = ref.watch(authViewModelProvider);
    final walletBalance = authState.user?.walletBalance ?? 0;

    final gameTitle = state.activeGame == 'list'
        ? decodedName.toUpperCase()
        : '${state.activeGame.replaceAll('-', ' ').toUpperCase()} BETTING';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (state.activeGame != 'list') {
              notifier.selectGame('list');
            } else {
              context.pop();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gameTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              decodedName.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded,
                color: AppColors.darkGold, size: 24),
            tooltip: 'Bet History',
            onPressed: () => _showHistoryDialog(context, decodedName),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: state.isMarketClosed
            ? _buildMarketClosedView(decodedName)
            : (state.activeGame == 'list'
                ? _buildGameModesGrid(context, decodedName, notifier, state.openDisabled)
                : _buildBettingScreen(context, state, notifier, walletBalance)),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Game Modes Selection Grid
  // ---------------------------------------------------------------------------
  Widget _buildGameModesGrid(
      BuildContext context,
      String marketName,
      PlayMarketViewModel notifier,
      bool openDisabled,
  ) {
    final gameModes = [
      {
        'id': 'single',
        'name': 'Single Ank',
        'icon': Icons.filter_1,
        'color': const Color(0xFF2C1A1D),
        'border': const Color(0xFFF87171),
        'iconColor': const Color(0xFFFCA5A5),
      },
      {
        'id': 'jodi',
        'name': 'Jodi',
        'icon': Icons.grid_view,
        'color': const Color(0xFF271A35),
        'border': const Color(0xFFC084FC),
        'iconColor': const Color(0xFFE9D5FF),
      },
      {
        'id': 'single-panna',
        'name': 'Single Panna',
        'icon': Icons.description,
        'color': const Color(0xFF14243B),
        'border': const Color(0xFF60A5FA),
        'iconColor': const Color(0xFFBFDBFE),
      },
      {
        'id': 'double-panna',
        'name': 'Double Panna',
        'icon': Icons.content_copy,
        'color': const Color(0xFF132B25),
        'border': const Color(0xFF34D399),
        'iconColor': const Color(0xFFA7F3D0),
      },
      {
        'id': 'triple-panna',
        'name': 'Triple Panna',
        'icon': Icons.layers,
        'color': const Color(0xFF332910),
        'border': const Color(0xFFFBBF24),
        'iconColor': const Color(0xFFFDE68A),
      },
      {
        'id': 'sp-motor',
        'name': '(mpsp) SP Motor',
        'icon': Icons.memory,
        'color': const Color(0xFF112A34),
        'border': const Color(0xFF22D3EE),
        'iconColor': const Color(0xFFA5F3FC),
      },
      {
        'id': 'dp-motor',
        'name': '(mpdp) DP Motor',
        'icon': Icons.album,
        'color': const Color(0xFF1B2D1B),
        'border': const Color(0xFF4ADE80),
        'iconColor': const Color(0xFFBBF7D0),
      },
      {
        'id': 'sp-dp-tp',
        'name': 'SP DP TP',
        'icon': Icons.grid_on,
        'color': const Color(0xFF332014),
        'border': const Color(0xFFFB923C),
        'iconColor': const Color(0xFFFFEDD5),
      },
      {
        'id': 'cp',
        'name': 'Cycle Panna',
        'icon': Icons.sync,
        'color': const Color(0xFF1E2833),
        'border': const Color(0xFF64748B),
        'iconColor': const Color(0xFFCBD5E1),
      },
      {
        'id': 'family-jodi',
        'name': 'Family Jodi',
        'icon': Icons.group_work,
        'color': const Color(0xFF2E1A29),
        'border': const Color(0xFFD946EF),
        'iconColor': const Color(0xFFF5D0FE),
      },
      {
        'id': 'family-panel',
        'name': 'Family Panel',
        'icon': Icons.people,
        'color': const Color(0xFF331924),
        'border': const Color(0xFFF472B6),
        'iconColor': const Color(0xFFFBCFE8),
      },
      {
        'id': 'half-sagam',
        'name': 'Half Sangam',
        'icon': Icons.call_split,
        'color': const Color(0xFF1E1F3B),
        'border': const Color(0xFF818CF8),
        'iconColor': const Color(0xFFC7D2FE),
      },
      {
        'id': 'full-sagam',
        'name': 'Full Sangam',
        'icon': Icons.fullscreen,
        'color': const Color(0xFF331730),
        'border': const Color(0xFFE879F9),
        'iconColor': const Color(0xFFF5D0FE),
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Premium Header Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF8D044),
                Color(0xFFE4AA25),
                Color(0xFFC58514),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SELECT GAME MODE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text(marketName.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary)),
                ],
              ),
              const Icon(Icons.casino, size: 40, color: AppColors.textPrimary),
            ],
          ),
        ),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: gameModes.length,
          itemBuilder: (context, index) {
            final mode = gameModes[index];
            final IconData icon = mode['icon'] as IconData;
            final String id = mode['id'] as String;
            final String name = mode['name'] as String;
            final Color color = mode['color'] as Color;
            final Color border = mode['border'] as Color;
            final Color iconColor = mode['iconColor'] as Color;

            final bool isOpenOnlyGame =
                id == 'jodi' || id == 'half-sagam' || id == 'full-sagam';
            final bool isGameDisabled = openDisabled && isOpenOnlyGame;

            return Opacity(
              opacity: isGameDisabled ? 0.4 : 1.0,
              child: InkWell(
                onTap: isGameDisabled
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.statusRed,
                            content: Text(
                                '$name bids can only be placed when the Open session is active.'),
                          ),
                        );
                      }
                    : () => notifier.selectGame(id),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 32, color: iconColor),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Complete Betting Screen Layout
  // ---------------------------------------------------------------------------
  Widget _buildBettingScreen(
    BuildContext context,
    PlayMarketState state,
    PlayMarketViewModel notifier,
    int walletBalance,
  ) {
    return Column(
      children: [
        // 1. Wallet Balance & Session Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.surfaceGold,
          child: Column(
            children: [
              // Wallet Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: AppColors.darkGold, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Wallet Balance:',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '₹${walletBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Session Selector Row (Hidden / Locked for Jodi)
              if (state.activeGame == 'jodi')
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    '🔒 Session Locked: Jodi applies to both Open & Close results',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGold),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Row(
                  children: [
                    const Text(
                      'Choose Session:',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSessionButton(
                              label:
                                  state.openDisabled ? 'OPEN (Closed)' : 'OPEN',
                              isSelected: state.session == 'open',
                              isDisabled: state.openDisabled,
                              onTap: () => notifier.setSession('open'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSessionButton(
                              label: 'CLOSE',
                              isSelected: state.session == 'close',
                              isDisabled: false,
                              onTap: () => notifier.setSession('close'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // 2. Custom Game Mode Input Pad Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildGameInputPad(context, state, notifier),
          ),
        ),

        // 3. Bottom Betting Inputs & Cost Estimator Bar
        _buildBottomBettingBar(context, state, notifier, walletBalance),
      ],
    );
  }

  Widget _buildSessionButton({
    required String label,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : (isDisabled
                  ? AppColors.disabledBackground
                  : AppColors.surface),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : (isDisabled ? Colors.transparent : AppColors.border),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? AppColors.textPrimary
                : (isDisabled ? AppColors.disabledForeground : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Custom Game Input Pads Switcher
  // ---------------------------------------------------------------------------
  Widget _buildGameInputPad(BuildContext context, PlayMarketState state,
      PlayMarketViewModel notifier) {
    switch (state.activeGame) {
      case 'single':
        return _buildSingleAnkPad(state, notifier);
      case 'jodi':
        return _buildJodiPad(state, notifier);
      case 'single-panna':
      case 'double-panna':
      case 'triple-panna':
        return _buildPannaPad(state, notifier);
      case 'sp-motor':
        return _buildMotorPad(state, notifier, isSp: true);
      case 'dp-motor':
        return _buildMotorPad(state, notifier, isSp: false);
      case 'sp-dp-tp':
        return _buildSpDpTpPad(state, notifier);
      case 'cp':
        return _buildCPPad(state, notifier);
      case 'family-jodi':
        return _buildFamilyJodiPad(state, notifier);
      case 'family-panel':
        return _buildFamilyPanelPad(state, notifier);
      case 'half-sagam':
        return _buildHalfSangamPad(state, notifier);
      case 'full-sagam':
        return _buildFullSangamPad(state, notifier);
      default:
        return const SizedBox.shrink();
    }
  }

  // 2.1 Single Ank Pad (0-9 Circular Grid)
  Widget _buildSingleAnkPad(
      PlayMarketState state, PlayMarketViewModel notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Single Digits (0 to 9):',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final digitStr = index.toString();
            final isSelected = state.selectedNumbers.contains(digitStr);
            return GestureDetector(
              onTap: () => notifier.toggleSelectedNumber(digitStr),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.surface,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  digitStr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 2.2 Jodi Pad (00-99 Scrollable 10-column Grid)
  Widget _buildJodiPad(PlayMarketState state, PlayMarketViewModel notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Jodi Numbers (00 to 99):',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: 100,
          itemBuilder: (context, index) {
            final jodiStr = index.toString().padLeft(2, '0');
            final isSelected = state.selectedNumbers.contains(jodiStr);
            return GestureDetector(
              onTap: () => notifier.toggleSelectedNumber(jodiStr),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  jodiStr,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 2.3 Panna Pad (Single / Double / Triple Panna with Ank Sum filter & Search)
  Widget _buildPannaPad(PlayMarketState state, PlayMarketViewModel notifier) {
    final pannasMap = PannaGenerator.generatePannas(state.activeGame);
    List<String> list = state.selectedAnk == -1
        ? pannasMap.values.expand((element) => element).toList()
        : (pannasMap[state.selectedAnk] ?? []);

    if (state.searchQuery.isNotEmpty) {
      list = list.where((p) => p.contains(state.searchQuery)).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Max 40 Pannas Disclaimer Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF78350F), // Dark amber warning
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFFFDE68A), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Every user can play a maximum of 40 pannas combined per session for each market.',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFEF3C7)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Search Bar
        TextField(
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Type 3-digit Panna (e.g. 123)...',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.search,
                color: AppColors.darkGold, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          onChanged: (q) => notifier.setSearchQuery(q),
        ),
        const SizedBox(height: 14),

        // Ank Sum Filter Chips
        const Text(
          'Filter by Ank Sum:',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAnkFilterChip('ALL', -1, state.selectedAnk == -1,
                  () => notifier.setSelectedAnk(-1)),
              ...List.generate(10, (i) => i).map((i) {
                return _buildAnkFilterChip('$i', i, state.selectedAnk == i,
                    () => notifier.setSelectedAnk(i));
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Panna Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.8,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final panna = list[index];
            final isSelected = state.selectedNumbers.contains(panna);
            return GestureDetector(
              onTap: () => notifier.toggleSelectedNumber(panna),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  panna,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnkFilterChip(
      String label, int value, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGold : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryGold : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // 3.1 & 3.2 Motor Pad (SP Motor & DP Motor)
  Widget _buildMotorPad(PlayMarketState state, PlayMarketViewModel notifier,
      {required bool isSp}) {
    final selectedStr = state.selectedNumber ?? '';
    final count = selectedStr.length;
    final factor = isSp
        ? PannaGenerator.getSpMotorFactor(count)
        : PannaGenerator.getDpMotorFactor(count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSp ? 'SP Motor Digit Selection:' : 'DP Motor Digit Selection:',
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Selected Digits: $count (Min 4 required)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: count >= 4 ? AppColors.statusGreen : AppColors.statusRed,
          ),
        ),
        if (count >= 4) ...[
          const SizedBox(height: 4),
          Text(
            'Generated ${isSp ? 'Single' : 'Double'} Pannas: $factor combinations',
            style: const TextStyle(fontSize: 12, color: AppColors.statusGreen),
          ),
        ],
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final digitStr = index.toString();
            final isSelected = selectedStr.contains(digitStr);
            return GestureDetector(
              onTap: () => notifier.toggleMotorDigit(digitStr),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.surface,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  digitStr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 3.3 SP DP TP Pad
  Widget _buildSpDpTpPad(PlayMarketState state, PlayMarketViewModel notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Choose Base Ank (0 to 9):',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final digitStr = index.toString();
            final isSelected = state.selectedNumbers.contains(digitStr);
            return GestureDetector(
              onTap: () => notifier.toggleSelectedNumber(digitStr),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  digitStr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          '2. Select Panna Categories:',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCheckboxChip(
                label: 'SP (12 Pannas)',
                isSelected: state.spDpTpChoices.contains('SP'),
                onTap: () => notifier.toggleSpDpTpChoice('SP'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCheckboxChip(
                label: 'DP (9 Pannas)',
                isSelected: state.spDpTpChoices.contains('DP'),
                onTap: () => notifier.toggleSpDpTpChoice('DP'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCheckboxChip(
                label: 'TP (1 Panna)',
                isSelected: state.spDpTpChoices.contains('TP'),
                onTap: () => notifier.toggleSpDpTpChoice('TP'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // 3.4 Family Panel Pad
  Widget _buildFamilyPanelPad(
      PlayMarketState state, PlayMarketViewModel notifier) {
    final familyList = PannaGenerator.getFamilyPannas(state.familyPanna);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Base 3-Digit Panna:',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        TextField(
          keyboardType: TextInputType.number,
          maxLength: 3,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'e.g. 145',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          onChanged: (val) => notifier.setFamilyPanna(val),
        ),
        if (state.familyPanna.length == 3 &&
            !PannaGenerator.isValidPanna(state.familyPanna))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Invalid Panna! Digits must be in ascending order (where 0 is 10, e.g. 778 instead of 787).',
              style: const TextStyle(
                  color: AppColors.statusRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 16),
        if (familyList.isNotEmpty) ...[
          Text(
            'Generated Family Pannas (${familyList.length} total):',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: familyList.map((panna) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  panna,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // 3.5 Half Sangam Pad
  Widget _buildHalfSangamPad(
      PlayMarketState state, PlayMarketViewModel notifier) {
    final isType1 = state.halfSangamType == 'open_panna_close_digit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Half Sangam Combination Type:',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCheckboxChip(
                label: 'Open Panna + Close Digit',
                isSelected: isType1,
                onTap: () => notifier.setHalfSangamFields(
                    state.halfPanna, state.halfDigit, 'open_panna_close_digit'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCheckboxChip(
                label: 'Open Digit + Close Panna',
                isSelected: !isType1,
                onTap: () => notifier.setHalfSangamFields(
                    state.halfPanna, state.halfDigit, 'open_digit_close_panna'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isType1 ? 'Open 3-Digit Panna:' : 'Open Single Digit:',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    maxLength: isType1 ? 3 : 1,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: isType1 ? '123' : '5',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (val) {
                      if (isType1) {
                        notifier.setHalfSangamFields(
                            val, state.halfDigit, state.halfSangamType);
                      } else {
                        notifier.setHalfSangamFields(
                            state.halfPanna, val, state.halfSangamType);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isType1 ? 'Close Single Digit:' : 'Close 3-Digit Panna:',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    maxLength: isType1 ? 1 : 3,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: isType1 ? '5' : '123',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (val) {
                      if (isType1) {
                        notifier.setHalfSangamFields(
                            state.halfPanna, val, state.halfSangamType);
                      } else {
                        notifier.setHalfSangamFields(
                            val, state.halfDigit, state.halfSangamType);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3.6 Full Sangam Pad
  Widget _buildFullSangamPad(
      PlayMarketState state, PlayMarketViewModel notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Sangam Combination Inputs:',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Open 3-Digit Panna:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'e.g. 123',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (val) =>
                        notifier.setFullSangamFields(val, state.fullClosePanna),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Close 3-Digit Panna:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'e.g. 456',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (val) =>
                        notifier.setFullSangamFields(state.fullOpenPanna, val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Betting Inputs & Live Cost Estimator Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomBettingBar(
    BuildContext context,
    PlayMarketState state,
    PlayMarketViewModel notifier,
    int walletBalance,
  ) {
    final points = int.tryParse(state.amount.trim()) ?? 0;
    final totalCost = points * state.multiplier;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Points Input
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(
                  color: AppColors.darkGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              hintText: 'Enter Points (e.g. 100)',
              hintStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 14),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (val) => notifier.setAmount(val),
          ),
          const SizedBox(height: 10),

          // Live Cost Estimator Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceGold,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Bid Cost:',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '₹$points × ${state.multiplier} = ₹$totalCost',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF8D044),
                    Color(0xFFE4AA25),
                    Color(0xFFC58514),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final ok = await notifier.placeBet(
                            walletBalance: walletBalance);
                        if (context.mounted) {
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF10B981),
                                content: Text('Bet placed successfully!'),
                              ),
                            );
                          } else if (state.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFFEF4444),
                                content: Text(state.error!),
                              ),
                            );
                          }
                        }
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.textPrimary)
                    : const Text(
                        'PLACE BET NOW',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // History Modal Dialog
  // ---------------------------------------------------------------------------
  void _showHistoryDialog(BuildContext context, String marketName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${marketName.toUpperCase()} HISTORY',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 20),
                const Icon(Icons.history_rounded,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 12),
                const Text(
                  'No recent bets placed for this session.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close',
                        style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketClosedView(String marketName) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.statusRed.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.statusRedBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock,
                color: AppColors.statusRed,
                size: 54,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${marketName.toUpperCase()} IS CLOSED',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This market is closed for today. Bidding is disabled until the next session opens. Please try another market or check back tomorrow.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCPPad(PlayMarketState state, PlayMarketViewModel notifier) {
    final cpList = PannaGenerator.getCPPannas(state.selectedNumber ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter 2-Digit Base Number for Cycle Panna (CP):',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        TextField(
          keyboardType: TextInputType.number,
          maxLength: 2,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'e.g. 13',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          onChanged: (val) => notifier.setSelectedNumber(val),
        ),
        const SizedBox(height: 16),
        if (cpList.isNotEmpty) ...[
          Text(
            'Generated CP Pannas (${cpList.length} total):',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cpList.map((panna) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  panna,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFamilyJodiPad(
      PlayMarketState state, PlayMarketViewModel notifier) {
    final familyList = PannaGenerator.getJodiFamilyMembers(state.selectedNumber ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Base 2-Digit Jodi for Family Jodi:',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        TextField(
          keyboardType: TextInputType.number,
          maxLength: 2,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'e.g. 00',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          onChanged: (val) => notifier.setSelectedNumber(val),
        ),
        const SizedBox(height: 16),
        if (familyList.isNotEmpty) ...[
          Text(
            'Generated Family Jodis (${familyList.length} total):',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: familyList.map((jodi) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  jodi,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
