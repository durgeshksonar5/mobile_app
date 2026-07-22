import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/home_view_model.dart';
import '../states/home_state.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/marquee_ticker.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/market_card.dart';
import '../widgets/chart_modal_dialog.dart';
import '../widgets/add_fund_dialog.dart';
import '../widgets/withdraw_dialog.dart';
import '../widgets/notifications_dialog.dart';
import '../../domain/models/app_notification.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _passbookFilter = 'all'; // 'all', 'deposit', 'withdraw'
  List<AppNotification> _notifications =
      AppNotification.getInitialSampleNotifications();

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final homeNotifier = ref.read(homeViewModelProvider.notifier);

    final DateTime now = DateTime.now();
    final String todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundLight,
      drawer: SidebarDrawer(
        user: user,
        activeTab: homeState.activeTab,
        onTabSelected: (tab) => homeNotifier.setActiveTab(tab),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'King Win',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          // Wallet Balance Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceGold,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    size: 16, color: AppColors.darkGold),
                const SizedBox(width: 6),
                Text(
                  '${user?.walletBalance ?? 0}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Refresh Button
          IconButton(
            icon:
                const Icon(Icons.refresh, size: 20),
            onPressed: () {
              homeNotifier.fetchMarkets();
              ref.read(authViewModelProvider.notifier).checkInitialSession();
            },
          ),

          // Bell Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => NotificationsDialog(
                      notifications: _notifications,
                      onNotificationsUpdated: (updated) {
                        setState(() {
                          _notifications = updated;
                        });
                      },
                    ),
                  );
                },
              ),
              if (_notifications.any((n) => !n.isRead))
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.statusRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // Scrolling Announcement Ticker
          Container(
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            alignment: Alignment.center,
            child: const MarqueeTicker(
              text:
                  'Trusted Matka Experience Since 2019 to 2026 — Daily Live Results & Auto Withdrawals. Contact Support for assistance!',
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.statusRed,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // 4-Action Grid Bar (Deposit, Withdraw, Bid History, Support)
          Container(
            color: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Add Fund',
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => const AddFundDialog(),
                  ),
                ),
                _buildActionButton(
                  icon: Icons.arrow_circle_down,
                  label: 'Withdraw',
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => WithdrawDialog(user: user),
                  ),
                ),
                _buildActionButton(
                  icon: Icons.history,
                  label: 'Bid History',
                  onTap: () => homeNotifier.setActiveTab('my-bids'),
                ),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Whatsapp',
                  onTap: () => ExternalLinkService.launchWhatsApp(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Main View Content Area
          Expanded(
            child: _buildTabContent(
                context, homeState, homeNotifier, user, todayStr, now),
          ),
        ],
      ),

      // Fixed Bottom Navigation Bar with Floating Center Home Button
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: EdgeInsets.zero,
        color: AppColors.surfaceWhite,
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.gavel,
              label: 'My Bids',
              isActive: homeState.activeTab == 'my-bids',
              onTap: () => homeNotifier.setActiveTab('my-bids'),
            ),
            _buildNavItem(
              icon: Icons.menu_book,
              label: 'Passbook',
              isActive: homeState.activeTab == 'passbook',
              onTap: () => homeNotifier.setActiveTab('passbook'),
            ),

            // Floating Home Center Button
            Transform.translate(
              offset: const Offset(0, -14),
              child: FloatingActionButton(
                elevation: 4,
                backgroundColor: AppColors.primaryGold,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.surfaceWhite, width: 4),
                ),
                onPressed: () => homeNotifier.setActiveTab('home'),
                child: const Icon(Icons.home,
                    color: AppColors.textWhite, size: 26),
              ),
            ),

            _buildNavItem(
              icon: Icons.monetization_on_outlined,
              label: 'Funds',
              isActive: homeState.activeTab == 'funds',
              onTap: () => homeNotifier.setActiveTab('funds'),
            ),
            _buildNavItem(
              icon: Icons.headset_mic_outlined,
              label: 'Support',
              isActive: false,
              onTap: () => ExternalLinkService.launchWhatsApp(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryGoldBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: AppColors.primaryGold),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primaryGold : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? AppColors.primaryGold
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    HomeState state,
    HomeViewModel notifier,
    user,
    String todayStr,
    DateTime now,
  ) {
    if (state.isLoading) {
      return const AppLoading(message: 'Loading details...');
    }

    switch (state.activeTab) {
      case 'passbook':
        return _buildPassbookView(context, state, user);
      case 'my-bids':
        return _buildMyBidsView(context, state);
      case 'funds':
        return _buildFundsView(context, state, user);
      case 'game-rate':
        return _buildGameRatesView(context, state);
      case 'charts':
        return _buildChartsView(context, state);
      case 'settings':
        return _buildSettingsView(context, user);
      case 'home':
      default:
        return _buildHomeMarketsView(context, state, todayStr, now);
    }
  }

  Widget _buildHomeMarketsView(
    BuildContext context,
    HomeState state,
    String todayStr,
    DateTime now,
  ) {
    if (state.markets.isEmpty) {
      return const AppEmptyView(
        title: 'No Satta markets active',
        message: 'Please check back later or refresh.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.p16),
      itemCount: state.markets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final market = state.markets[index];
        return MarketCard(
          market: market,
          todayStr: todayStr,
          referenceDate: now,
          onChartTap: () => showDialog(
            context: context,
            builder: (context) =>
                ChartModalDialog(marketName: market.marketName),
          ),
          onPlayTap: () {
            context.push('/play/${Uri.encodeComponent(market.marketName)}');
          },
        );
      },
    );
  }

  Widget _buildPassbookView(BuildContext context, HomeState state, user) {
    final filteredItems = state.passbookItems.where((item) {
      if (_passbookFilter == 'all') return true;
      return item.type == _passbookFilter;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      children: [
        // Balance Header Card
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
              const Text('PASSBOOK BALANCE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('₹${user?.walletBalance ?? 0}',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Filter chips
        Row(
          children: ['all', 'deposit', 'withdraw'].map((filter) {
            final isActive = _passbookFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(filter.toUpperCase()),
                selected: isActive,
                onSelected: (_) => setState(() => _passbookFilter = filter),
                selectedColor: AppColors.textDark,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color:
                      isActive ? AppColors.textWhite : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        if (filteredItems.isEmpty)
          const AppEmptyView(title: 'No transaction history found.')
        else
          ...filteredItems.map((item) {
            final isDeposit = item.type == 'deposit';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isDeposit
                            ? AppColors.statusGreenBg
                            : AppColors.statusRedBg,
                        child: Text(
                          isDeposit ? '+' : '-',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDeposit
                                ? AppColors.statusGreen
                                : AppColors.statusRed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDeposit
                                ? 'Deposit Request'
                                : 'Withdrawal Request',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark),
                          ),
                          Text(
                            item.date.toLocal().toString().split('.')[0],
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isDeposit ? '+' : '-'} ₹${item.amount}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDeposit
                              ? AppColors.statusGreen
                              : AppColors.statusRed,
                        ),
                      ),
                      Text(
                        item.status,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMyBidsView(BuildContext context, HomeState state) {
    if (state.bidsItems.isEmpty) {
      return const AppEmptyView(
        title: 'No bids placed yet',
        message: 'Go to any Satta market to start placing bets.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.p16),
      itemCount: state.bidsItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final bid = state.bidsItems[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGoldBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bid.selectedNumber,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bid.marketName} - ${bid.gameType}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark),
                      ),
                      Text(
                        'Session: ${bid.session} | Number: ${bid.selectedNumber}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${bid.amount}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.statusGreenBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      bid.status,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusGreen),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundsView(BuildContext context, HomeState state, user) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      children: [
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
              const Text('AVAILABLE BALANCE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('₹${user?.walletBalance ?? 0}',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                icon: const Icon(Icons.add_circle_outline, size: 22),
                label: const Text('Deposit Points'),
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const AddFundDialog()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.arrow_circle_down, size: 22),
                label: const Text('Withdraw Points'),
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => WithdrawDialog(user: user)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameRatesView(BuildContext context, HomeState state) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      children: state.gameRates.map((rate) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rate.gameType.toUpperCase(),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGoldBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '1 : ${rate.rate}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartsView(BuildContext context, HomeState state) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.p16),
      itemCount: state.markets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final market = state.markets[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                market.marketName.toUpperCase(),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            ChartModalDialog(marketName: market.marketName),
                      ),
                      child: const Text('Jodi Chart'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceDark),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            ChartModalDialog(marketName: market.marketName),
                      ),
                      child: const Text('Panel Chart'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsView(BuildContext context, user) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SETTINGS & PROFILE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Full Name'),
                subtitle: Text(user?.name ?? 'User'),
              ),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Phone Number'),
                subtitle: Text(user?.phoneNumber ?? 'No Phone'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('Bank Name'),
                subtitle: Text(user?.bankName ?? 'Not Configured'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
