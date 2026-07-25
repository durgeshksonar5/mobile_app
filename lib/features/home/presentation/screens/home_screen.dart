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
import '../../domain/models/market_result.dart';
import '../../domain/models/bid_item.dart';
import '../../domain/models/passbook_item.dart';
import '../widgets/add_fund_dialog.dart';
import '../widgets/withdraw_dialog.dart';
import '../widgets/notifications_dialog.dart';
import '../../domain/models/app_notification.dart';
import '../../../contact_sync/presentation/widgets/contact_disclosure.dart';
import '../../../wallet/presentation/view_models/wallet_view_model.dart';
import '../../../../app/dependency_injection/providers.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool initialPermissionSkipped;
  const HomeScreen({super.key, this.initialPermissionSkipped = false});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _passbookFilter = 'all'; // 'all', 'deposit', 'withdraw'
  int _passbookCurrentPage = 1;
  String _bidsFilter = 'all'; // 'all', 'win', 'loss', 'active'
  int _bidsCurrentPage = 1;
  String _fundsPassbookFilter = 'all';
  int _fundsPassbookCurrentPage = 1;
  List<AppNotification> _notifications =
      AppNotification.getInitialSampleNotifications();
  PermissionStatus? _permissionStatus;
  late bool _isPermissionSkipped;
  bool _isSyncing = false;

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accNumController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _upiNumController = TextEditingController();
  bool _isSavingSettings = false;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _isPermissionSkipped = widget.initialPermissionSkipped;
    if (_isPermissionSkipped) {
      _permissionStatus = PermissionStatus.granted;
    }
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermission();
      ref.read(walletViewModelProvider.notifier).fetchBalance();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bankNameController.dispose();
    _accNumController.dispose();
    _ifscController.dispose();
    _upiIdController.dispose();
    _upiNumController.dispose();
    super.dispose();
  }

  void _syncSettingsControllers(dynamic user) {
    if (user != null && !_controllersInitialized) {
      _bankNameController.text = user.bankName ?? '';
      _accNumController.text = user.accountNumber ?? '';
      _ifscController.text = user.ifscCode ?? '';
      _upiIdController.text = user.upiId ?? '';
      _upiNumController.text = user.upiNumber ?? '';
      _controllersInitialized = true;
    }
  }

  void _saveSettingsFromView() async {
    setState(() => _isSavingSettings = true);
    try {
      final success =
          await ref.read(authViewModelProvider.notifier).updateProfile({
        'bank_name': _bankNameController.text.trim(),
        'account_number': _accNumController.text.trim(),
        'ifsc_code': _ifscController.text.trim().toUpperCase(),
        'upi_id': _upiIdController.text.trim(),
        'upi_number': _upiNumController.text.trim(),
      });
      if (mounted) {
        setState(() => _isSavingSettings = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.statusGreen,
              content: Text('Settings & banking details saved successfully!'),
            ),
          );
        } else {
          final err = ref.read(authViewModelProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.statusRed,
              content: Text(err ?? 'Failed to save settings.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingSettings = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndRequestPermission(isResume: true);
      ref.read(walletViewModelProvider.notifier).fetchBalance(isRefresh: true);
    }
  }

  Future<void> _checkAndRequestPermission({bool isResume = false}) async {
    try {
      final status = await Permission.contacts.status;
      debugPrint(
          'Contacts permission status checked: $status (isResume: $isResume)');

      if (status.isGranted || status.isLimited) {
        setState(() {
          _permissionStatus = status;
        });
        await _syncContactsIfNeeded();
        return;
      }

      if (isResume) {
        // Silent check on app resume, don't trigger native request dialog
        setState(() {
          _permissionStatus = status;
        });
        return;
      }

      setState(() {
        _permissionStatus = status;
      });

      if (status.isDenied) {
        // Present Google Play compliant prominent disclosure dialog before native system dialog
        if (mounted && !_isPermissionSkipped) {
          _showDisclosureDialog();
        }
      }
    } catch (e) {
      debugPrint('Error checking/requesting contacts permission: $e');
      setState(() {
        _permissionStatus = PermissionStatus.granted;
      });
    }
  }

  void _showDisclosureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ContactDisclosure(
          onContinue: () async {
            Navigator.pop(dialogContext);
            final requestResult = await Permission.contacts.request();
            debugPrint('Contacts permission request result: $requestResult');
            if (mounted) {
              setState(() {
                _permissionStatus = requestResult;
              });
              if (requestResult.isGranted || requestResult.isLimited) {
                await _syncContactsIfNeeded();
              }
            }
          },
          onNotNow: () {
            Navigator.pop(dialogContext);
            if (mounted) {
              setState(() {
                _permissionStatus = PermissionStatus.denied;
                _isPermissionSkipped = true;
              });
            }
          },
          onPrivacyPolicy: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Privacy Policy'),
                content: const Text(
                  'We take your privacy seriously. Your contacts data is encrypted and transferred over HTTPS to our secure servers solely for account verification, invite matching, and peer wallet transfers. We never share or sell your contact list.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _syncContactsIfNeeded() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      debugPrint('Starting automatic background contacts synchronization...');
      final deviceContactsRepo = ref.read(deviceContactsRepositoryProvider);
      final contactSyncRepo = ref.read(contactSyncRepositoryProvider);

      final contacts = await deviceContactsRepo.loadAuthorizedContacts();
      if (contacts.isEmpty) {
        debugPrint('No contacts found on device.');
        _isSyncing = false;
        return;
      }

      final selectedContacts =
          contacts.map((c) => c.copyWith(isSelected: true)).toList();
      final result = await contactSyncRepo.syncContacts(selectedContacts);
      debugPrint(
          'Automatic contacts sync finished: success=${result.isSuccess}, count=${result.syncedCount}');
    } catch (e) {
      debugPrint('Error during automatic contacts sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Widget _buildPermissionBlockingScreen() {
    final isPermanentlyDenied =
        _permissionStatus == PermissionStatus.permanentlyDenied ||
            _permissionStatus == PermissionStatus.restricted;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p24, vertical: AppSpacing.p32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.p24),
                    decoration: BoxDecoration(
                      color: isPermanentlyDenied
                          ? AppColors.statusRedBg
                          : AppColors.primaryGoldBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPermanentlyDenied ? Icons.gpp_maybe : Icons.contacts,
                      color: isPermanentlyDenied
                          ? AppColors.statusRed
                          : AppColors.primaryGold,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Contacts Access Required',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPermanentlyDenied
                        ? 'Contacts permission has been permanently denied. Please open Settings and enable Contacts access to continue using King Wins.'
                        : 'King Wins requires contacts access to help you connect with friends, verify accounts, and perform wallet transfers. Please allow access to proceed.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (isPermanentlyDenied) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await openAppSettings();
                        },
                        child: const Text(
                          'Open Settings',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => _checkAndRequestPermission(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: const Text(
                          'Retry Check',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _checkAndRequestPermission(),
                        child: const Text(
                          'Grant Permission',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(authViewModelProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout,
                        color: AppColors.statusRed, size: 18),
                    label: const Text(
                      'Switch Account / Logout',
                      style: TextStyle(
                        color: AppColors.statusRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        // ── Skip button ── top-right corner
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: TextButton(
            onPressed: () {
              setState(() {
                _isPermissionSkipped = true;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionStatus == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    if (!_isPermissionSkipped &&
        _permissionStatus != PermissionStatus.granted &&
        _permissionStatus != PermissionStatus.limited) {
      return _buildPermissionBlockingScreen();
    }

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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Wallet Balance Pill
          Consumer(
            builder: (context, ref, child) {
              final walletState = ref.watch(walletViewModelProvider);
              final user = ref.watch(authViewModelProvider).user;
              final balanceVal = walletState.isLoaded
                  ? walletState.displayBalance
                  : (user?.walletBalance ?? 0);

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      '$balanceVal',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              homeNotifier.fetchMarkets();
              ref.read(authViewModelProvider.notifier).checkInitialSession();
              ref
                  .read(walletViewModelProvider.notifier)
                  .fetchBalance(isRefresh: true);
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

    final sortedMarkets = List<MarketResult>.from(state.markets)..sort((a, b) {
      final aInfo = a.getDisplayInfo(todayStr, now);
      final bInfo = b.getDisplayInfo(todayStr, now);

      final aClosed = aInfo.statusType == 'closed';
      final bClosed = bInfo.statusType == 'closed';

      if (aClosed != bClosed) {
        return aClosed ? 1 : -1;
      }
      return a.getOpenTimeMinutes().compareTo(b.getOpenTimeMinutes());
    });

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.p16),
      itemCount: sortedMarkets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final market = sortedMarkets[index];
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

    // Sort by date descending
    final sortedItems = List<PassbookItem>.from(filteredItems)
      ..sort((a, b) => b.date.compareTo(a.date));

    final int itemsPerPage = 10;
    final int totalItems = sortedItems.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();
    final int safeTotalPages = totalPages == 0 ? 1 : totalPages;

    if (_passbookCurrentPage > safeTotalPages) {
      _passbookCurrentPage = safeTotalPages;
    }

    final int startIndex = (_passbookCurrentPage - 1) * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage < totalItems)
        ? startIndex + itemsPerPage
        : totalItems;

    final paginatedItems = sortedItems.sublist(startIndex, endIndex);

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
                onSelected: (_) => setState(() {
                  _passbookFilter = filter;
                  _passbookCurrentPage = 1;
                }),
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

        if (paginatedItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No transactions found.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          )
        else ...[
          ...paginatedItems.map((item) {
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
          _buildPagination(
            currentPage: _passbookCurrentPage,
            totalPages: safeTotalPages,
            onPageChanged: (page) => setState(() => _passbookCurrentPage = page),
          ),
        ],
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

    final filteredBids = state.bidsItems.where((bid) {
      if (_bidsFilter == 'all') return true;
      final statusLower = bid.status.toLowerCase();
      if (_bidsFilter == 'win') return statusLower == 'won';
      if (_bidsFilter == 'loss') return statusLower == 'lost';
      if (_bidsFilter == 'active') return statusLower == 'active';
      return true;
    }).toList();

    // Sort by createdAt descending
    final sortedBids = List<BidItem>.from(filteredBids)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final int itemsPerPage = 10;
    final int totalItems = sortedBids.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();
    final int safeTotalPages = totalPages == 0 ? 1 : totalPages;

    if (_bidsCurrentPage > safeTotalPages) {
      _bidsCurrentPage = safeTotalPages;
    }

    final int startIndex = (_bidsCurrentPage - 1) * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage < totalItems)
        ? startIndex + itemsPerPage
        : totalItems;

    final paginatedBids = sortedBids.sublist(startIndex, endIndex);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      children: [
        // Bids Filter Chips
        Row(
          children: ['all', 'win', 'loss', 'active'].map((filter) {
            final isActive = _bidsFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(filter.toUpperCase()),
                selected: isActive,
                onSelected: (_) => setState(() {
                  _bidsFilter = filter;
                  _bidsCurrentPage = 1;
                }),
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

        if (paginatedBids.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No bids found for this filter.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          )
        else ...[
          ...paginatedBids.map((bid) {
            final statusLower = bid.status.toLowerCase();
            final isWon = statusLower == 'won';
            final isLost = statusLower == 'lost';
            final Color statusColor = isWon
                ? AppColors.statusGreen
                : (isLost ? AppColors.statusRed : AppColors.textSecondary);
            final Color statusBgColor = isWon
                ? AppColors.statusGreenBg
                : (isLost ? AppColors.statusRedBg : AppColors.borderLight);

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
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          bid.status,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          _buildPagination(
            currentPage: _bidsCurrentPage,
            totalPages: safeTotalPages,
            onPageChanged: (page) => setState(() => _bidsCurrentPage = page),
          ),
        ],
      ],
    );
  }

  Widget _buildFundsView(BuildContext context, HomeState state, user) {
    final filteredItems = state.passbookItems.where((item) {
      if (_fundsPassbookFilter == 'all') return true;
      return item.type == _fundsPassbookFilter;
    }).toList();

    // Sort by date descending
    final sortedItems = List<PassbookItem>.from(filteredItems)
      ..sort((a, b) => b.date.compareTo(a.date));

    final int itemsPerPage = 10;
    final int totalItems = sortedItems.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();
    final int safeTotalPages = totalPages == 0 ? 1 : totalPages;

    if (_fundsPassbookCurrentPage > safeTotalPages) {
      _fundsPassbookCurrentPage = safeTotalPages;
    }

    final int startIndex = (_fundsPassbookCurrentPage - 1) * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage < totalItems)
        ? startIndex + itemsPerPage
        : totalItems;

    final paginatedItems = sortedItems.sublist(startIndex, endIndex);

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
        const SizedBox(height: 24),
        const Divider(color: AppColors.borderLight, height: 1),
        const SizedBox(height: 20),

        // Section Title: Transaction History
        const Text(
          'TRANSACTION HISTORY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        // Passbook Filter Chips for Funds
        Row(
          children: ['all', 'deposit', 'withdraw'].map((filter) {
            final isActive = _fundsPassbookFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(filter.toUpperCase()),
                selected: isActive,
                onSelected: (_) => setState(() {
                  _fundsPassbookFilter = filter;
                  _fundsPassbookCurrentPage = 1;
                }),
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

        // Paginated Transaction List
        if (paginatedItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No transactions found.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          )
        else ...[
          ...paginatedItems.map((item) {
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
                            isDeposit ? 'Deposit Request' : 'Withdrawal Request',
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
          _buildPagination(
            currentPage: _fundsPassbookCurrentPage,
            totalPages: safeTotalPages,
            onPageChanged: (page) => setState(() => _fundsPassbookCurrentPage = page),
          ),
        ],
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
    final DateTime now = DateTime.now();
    final String todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final sortedMarkets = List<MarketResult>.from(state.markets)..sort((a, b) {
      final aInfo = a.getDisplayInfo(todayStr, now);
      final bInfo = b.getDisplayInfo(todayStr, now);

      final aClosed = aInfo.statusType == 'closed';
      final bClosed = bInfo.statusType == 'closed';

      if (aClosed != bClosed) {
        return aClosed ? 1 : -1;
      }
      return a.getOpenTimeMinutes().compareTo(b.getOpenTimeMinutes());
    });

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.p16),
      itemCount: sortedMarkets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final market = sortedMarkets[index];
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

  Widget _buildSettingsView(BuildContext context, dynamic user) {
    _syncSettingsControllers(user);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.p16),
      children: [
        // Header Section Title Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings & Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Update your profile, banking details, and UPI accounts',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card Container Form
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FULL NAME
              const Text(
                'FULL NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  (user?.name != null && (user.name as String).isNotEmpty)
                      ? (user.name as String).toUpperCase()
                      : 'DURGESH KISHOR SONAR',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // Bank Account Information Header
              const Text(
                'Bank Account Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),

              // Row 1: BANK NAME & IFSC CODE
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BANK NAME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _bankNameController,
                          decoration: InputDecoration(
                            hintText: 'SBI, HDFC etc.',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryGold),
                            ),
                          ),
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
                          'IFSC CODE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _ifscController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'SBIN0012345',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryGold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ACCOUNT NUMBER
              const Text(
                'ACCOUNT NUMBER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _accNumController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter bank account number',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primaryGold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // UPI Account Information Header
              const Text(
                'UPI Account Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),

              // Row 2: UPI ID (VPA) & UPI PHONE NUMBER
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UPI ID (VPA)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _upiIdController,
                          decoration: InputDecoration(
                            hintText: 'username@okaxis',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryGold),
                            ),
                          ),
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
                          'UPI PHONE NUMBER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _upiNumController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '10-digit UPI phone',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryGold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save Settings Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2433),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSavingSettings ? null : _saveSettingsFromView,
                  child: _isSavingSettings
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Settings',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Sync Contacts Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryGoldBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sync,
                  color: AppColors.primaryGold, size: 20),
            ),
            title: const Text(
              'Sync Contacts',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
            subtitle: const Text(
              'Synchronize contacts with backend API',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSecondary),
            onTap: () {
              context.push('/contacts-sync');
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPagination({
    required int currentPage,
    required int totalPages,
    required ValueChanged<int> onPageChanged,
  }) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final List<Widget> pageButtons = [];

    // Previous Button
    pageButtons.add(
      _buildPageItem(
        label: '«',
        isActive: false,
        isEnabled: currentPage > 1,
        onTap: () => onPageChanged(currentPage - 1),
      ),
    );

    // Page Number Buttons
    for (int i = 1; i <= totalPages; i++) {
      pageButtons.add(
        _buildPageItem(
          label: '$i',
          isActive: i == currentPage,
          isEnabled: true,
          onTap: () => onPageChanged(i),
        ),
      );
    }

    // Next Button
    pageButtons.add(
      _buildPageItem(
        label: '»',
        isActive: false,
        isEnabled: currentPage < totalPages,
        onTap: () => onPageChanged(currentPage + 1),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pageButtons,
      ),
    );
  }

  Widget _buildPageItem({
    required String label,
    required bool isActive,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final Color bgColor = isActive
        ? AppColors.primaryGold
        : (isEnabled ? AppColors.surfaceWhite : AppColors.background);
    final Color textColor = isActive
        ? AppColors.textWhite
        : (isEnabled ? AppColors.textDark : AppColors.textMuted);
    final BorderSide borderSide = BorderSide(
      color: isActive ? AppColors.primaryGold : AppColors.borderLight,
      width: 1,
    );

    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.fromBorderSide(borderSide),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
