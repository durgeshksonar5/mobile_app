import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../view_models/home_view_model.dart';

class SidebarDrawer extends ConsumerStatefulWidget {
  final UserModel? user;
  final String activeTab;
  final Function(String) onTabSelected;

  const SidebarDrawer({
    super.key,
    required this.user,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  ConsumerState<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends ConsumerState<SidebarDrawer> {
  bool _bankExpanded = false;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accNumController;
  late final TextEditingController _ifscController;
  late final TextEditingController _upiIdController;
  late final TextEditingController _upiNumController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bankNameController =
        TextEditingController(text: widget.user?.bankName ?? '');
    _accNumController =
        TextEditingController(text: widget.user?.accountNumber ?? '');
    _ifscController = TextEditingController(text: widget.user?.ifscCode ?? '');
    _upiIdController = TextEditingController(text: widget.user?.upiId ?? '');
    _upiNumController =
        TextEditingController(text: widget.user?.upiNumber ?? '');
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accNumController.dispose();
    _ifscController.dispose();
    _upiIdController.dispose();
    _upiNumController.dispose();
    super.dispose();
  }

  void _saveBankDetails() async {
    setState(() => _isSaving = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.updateProfile({
        'bank_name': _bankNameController.text.trim(),
        'account_number': _accNumController.text.trim(),
        'ifsc_code': _ifscController.text.trim().toUpperCase(),
        'upi_id': _upiIdController.text.trim(),
        'upi_number': _upiNumController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bank & UPI details updated successfully!')),
        );
        setState(() {
          _bankExpanded = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'id': 'home', 'label': 'Home', 'icon': Icons.home},
      {'id': 'my-bids', 'label': 'My Bids', 'icon': Icons.history},
      {'id': 'passbook', 'label': 'Passbook', 'icon': Icons.menu_book},
      {'id': 'funds', 'label': 'Funds', 'icon': Icons.account_balance},
      {'id': 'game-rate', 'label': 'Game Rate', 'icon': Icons.star},
      {'id': 'charts', 'label': 'Charts', 'icon': Icons.bar_chart},
      {'id': 'contacts-sync', 'label': 'Sync Contacts', 'icon': Icons.contacts},
      {'id': 'settings', 'label': 'Settings', 'icon': Icons.settings},
      {'id': 'share', 'label': 'Share Now', 'icon': Icons.share},
    ];

    return Drawer(
      backgroundColor: AppColors.surfaceWhite,
      child: SafeArea(
        child: Column(
          children: [
            // User Header Profile Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.p20),
              color: AppColors.surfaceGold,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.softGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.person,
                        size: 32, color: AppColors.darkGold),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user?.name ?? 'Guest User',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.user?.phoneNumber ?? 'No Phone',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),

            // Scrollable Menu List
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                children: [
                  ...menuItems.map((item) {
                    final String id = item['id'] as String;
                    final String label = item['label'] as String;
                    final IconData icon = item['icon'] as IconData;
                    final bool isActive = widget.activeTab == id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        tileColor: isActive
                            ? AppColors.softGold
                            : Colors.transparent,
                        leading: Icon(
                          icon,
                          size: 20,
                          color: isActive
                              ? AppColors.darkGold
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive
                                ? AppColors.darkGold
                                : AppColors.textPrimary,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          if (id == 'share') {
                            ExternalLinkService.launchWhatsApp(
                              customMessage:
                                  'Play trusted Satta Matka games on King Win app! Fast results & instant withdrawal.',
                            );
                          } else if (id == 'contacts-sync') {
                            context.push('/contacts-sync');
                          } else {
                            widget.onTabSelected(id);
                          }
                        },
                      ),
                    );
                  }),

                  // Collapsible Bank & UPI Details
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      initiallyExpanded: _bankExpanded,
                      onExpansionChanged: (expanded) =>
                          setState(() => _bankExpanded = expanded),
                      leading: const Icon(Icons.account_balance,
                          size: 20, color: AppColors.textSecondary),
                      title: const Text(
                        'Bank & UPI Details',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _bankNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Bank Name',
                                    hintText: 'SBI, HDFC etc.'),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _accNumController,
                                decoration: const InputDecoration(
                                    labelText: 'Account Number',
                                    hintText: 'Bank Account Number'),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _ifscController,
                                decoration: const InputDecoration(
                                    labelText: 'IFSC Code',
                                    hintText: 'SBIN0012345'),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _upiIdController,
                                decoration: const InputDecoration(
                                    labelText: 'UPI ID',
                                    hintText: 'username@okaxis'),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _upiNumController,
                                decoration: const InputDecoration(
                                    labelText: 'UPI Phone Number',
                                    hintText: '10-digit phone'),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _isSaving ? null : _saveBankDetails,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.textWhite),
                                      )
                                    : const Text('Save Bank Details'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Logout Action
            const Divider(height: 1, color: AppColors.borderLight),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.statusRed),
              title: const Text(
                'Logout Account',
                style: TextStyle(
                  color: AppColors.statusRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authViewModelProvider.notifier).logout();
                ref.read(homeViewModelProvider.notifier).setActiveTab('home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
