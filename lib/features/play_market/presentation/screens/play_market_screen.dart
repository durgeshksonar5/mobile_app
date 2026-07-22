import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/play_market_view_model.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () {
            if (state.activeGame != 'list') {
              notifier.selectGame('list');
            } else {
              context.pop();
            }
          },
        ),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 1,
        title: Text(
          decodedName.toUpperCase(),
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark),
        ),
      ),
      body: SafeArea(
        child: state.activeGame == 'list'
            ? _buildGameModesGrid(context, decodedName, notifier)
            : _buildBettingForm(context, state, notifier, walletBalance),
      ),
    );
  }

  Widget _buildGameModesGrid(
      BuildContext context, String marketName, PlayMarketViewModel notifier) {
    final gameModes = [
      {
        'id': 'single',
        'name': 'Single',
        'color': const Color(0xFFFEF2F2),
        'border': const Color(0xFFFECACA),
        'icon': Icons.crop_square
      },
      {
        'id': 'jodi',
        'name': 'Jodi',
        'color': const Color(0xFFFAF5FF),
        'border': const Color(0xFFE9D5FF),
        'icon': Icons.grid_view
      },
      {
        'id': 'single-panna',
        'name': 'Single Panna',
        'color': const Color(0xFFEFF6FF),
        'border': const Color(0xFFBFDBFE),
        'icon': Icons.description
      },
      {
        'id': 'double-panna',
        'name': 'Double Panna',
        'color': const Color(0xFFECFDF5),
        'border': const Color(0xFFA7F3D0),
        'icon': Icons.content_copy
      },
      {
        'id': 'triple-panna',
        'name': 'Triple Panna',
        'color': const Color(0xFFFFFBEB),
        'border': const Color(0xFFFDE68A),
        'icon': Icons.layers
      },
      {
        'id': 'sp-motor',
        'name': 'SP Motor',
        'color': const Color(0xFFECFEFF),
        'border': const Color(0xFFA5F3FC),
        'icon': Icons.memory
      },
      {
        'id': 'dp-motor',
        'name': 'DP Motor',
        'color': const Color(0xFFF0FDF4),
        'border': const Color(0xFFBBF7D0),
        'icon': Icons.album
      },
      {
        'id': 'sp-dp-tp',
        'name': 'SP DP TP',
        'color': const Color(0xFFFFF7ED),
        'border': const Color(0xFFFFEDD5),
        'icon': Icons.grid_on
      },
      {
        'id': 'family-panel',
        'name': 'Family Panel',
        'color': const Color(0xFFFFF1F2),
        'border': const Color(0xFFFECDD3),
        'icon': Icons.people
      },
      {
        'id': 'half-sagam',
        'name': 'Half Sangam',
        'color': const Color(0xFFEEF2FF),
        'border': const Color(0xFFC7D2FE),
        'icon': Icons.call_split
      },
      {
        'id': 'full-sagam',
        'name': 'Full Sangam',
        'color': const Color(0xFFFDF2F8),
        'border': const Color(0xFFFBCFE8),
        'icon': Icons.fullscreen
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      children: [
        // Header Banner Card
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
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SELECT GAME MODE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(marketName.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: gameModes.length,
          itemBuilder: (context, index) {
            final mode = gameModes[index];
            final Color color = mode['color'] as Color;
            final Color border = mode['border'] as Color;
            final IconData icon = mode['icon'] as IconData;
            final String id = mode['id'] as String;
            final String name = mode['name'] as String;

            return InkWell(
              onTap: () => notifier.selectGame(id),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 30, color: AppColors.primaryGold),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBettingForm(
    BuildContext context,
    state,
    PlayMarketViewModel notifier,
    int walletBalance,
  ) {
    return Column(
      children: [
        // Subheader Game Title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.surfaceWhite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.activeGame.replaceAll('-', ' ').toUpperCase(),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark),
              ),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('OPEN'),
                    selected: state.session == 'open',
                    onSelected: state.openDisabled
                        ? null
                        : (_) => notifier.setSession('open'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('CLOSE'),
                    selected: state.session == 'close',
                    onSelected: (_) => notifier.setSession('close'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Number Grid / Input Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: _buildNumberSelectionArea(state, notifier),
          ),
        ),

        // Amount Input & Place Bet Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: 'Enter bet amount per item',
                ),
                onChanged: (val) => notifier.setAmount(val),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final ok = await notifier.placeBet(
                              walletBalance: walletBalance);
                          if (context.mounted && ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bet placed successfully!')),
                            );
                          }
                        },
                  child: state.isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.textPrimary)
                      : const Text('PLACE BET NOW',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberSelectionArea(state, PlayMarketViewModel notifier) {
    if (state.activeGame == 'single') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          final str = index.toString();
          final isSelected = state.selectedNumbers.contains(str);
          return InkWell(
            onTap: () => notifier.toggleSelectedNumber(str),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primaryGold : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.borderLight),
              ),
              alignment: Alignment.center,
              child: Text(
                str,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
            ),
          );
        },
      );
    } else if (state.activeGame == 'jodi') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          final str = index.toString().padLeft(2, '0');
          final isSelected = state.selectedNumbers.contains(str);
          return InkWell(
            onTap: () => notifier.toggleSelectedNumber(str),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primaryGold : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.borderLight),
              ),
              alignment: Alignment.center,
              child: Text(
                str,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.textPrimary : AppColors.textDark,
                ),
              ),
            ),
          );
        },
      );
    } else if (state.activeGame == 'single-panna' ||
        state.activeGame == 'double-panna' ||
        state.activeGame == 'triple-panna') {
      final pannasMap = PannaGenerator.generatePannas(state.activeGame);
      final List<String> list = state.selectedAnk == -1
          ? pannasMap.values.expand((element) => element).toList()
          : (pannasMap[state.selectedAnk] ?? []);

      return Column(
        children: [
          // Ank Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('ALL'),
                  selected: state.selectedAnk == -1,
                  onSelected: (_) => notifier.setSelectedAnk(-1),
                ),
                ...List.generate(10, (i) => i).map((i) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: ChoiceChip(
                      label: Text('$i'),
                      selected: state.selectedAnk == i,
                      onSelected: (_) => notifier.setSelectedAnk(i),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
              return InkWell(
                onTap: () => notifier.toggleSelectedNumber(panna),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGold
                            : AppColors.borderLight),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    panna,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? AppColors.textPrimary : AppColors.textDark,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        final str = index.toString();
        final isSelected = (state.selectedNumber ?? '').contains(str);
        return InkWell(
          onTap: () => notifier.toggleMotorDigit(str),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.primaryGold : AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.borderLight),
            ),
            alignment: Alignment.center,
            child: Text(
              str,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
          ),
        );
      },
    );
  }
}
