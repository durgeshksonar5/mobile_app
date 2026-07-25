import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../wallet/presentation/view_models/wallet_view_model.dart';
import '../view_models/home_view_model.dart';

import '../../../../core/services/external_link_service.dart';

class WithdrawDialog extends ConsumerStatefulWidget {
  final UserModel? user;

  const WithdrawDialog({super.key, required this.user});

  @override
  ConsumerState<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends ConsumerState<WithdrawDialog> {
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitWithdraw() async {
    final user = widget.user;
    final hasBankDetails =
        (user?.bankName != null && user!.bankName!.isNotEmpty) &&
            (user.accountNumber != null && user.accountNumber!.isNotEmpty) &&
            (user.ifscCode != null && user.ifscCode!.isNotEmpty);
    final hasUpiDetails = (user?.upiId != null && user!.upiId!.isNotEmpty) ||
        (user?.upiNumber != null && user!.upiNumber!.isNotEmpty);

    if (user == null || (!hasBankDetails && !hasUpiDetails)) {
      Navigator.pop(context);
      ref.read(homeViewModelProvider.notifier).setActiveTab('settings');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please fill your Bank or UPI details in Settings before placing a withdrawal request.'),
        ),
      );
      return;
    }

    final amt = int.tryParse(_amountController.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid withdrawal amount.')),
      );
      return;
    }

    if (amt > user.walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Insufficient balance! Your current wallet balance is ₹${user.walletBalance}.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(resultsRepositoryProvider);
      await repo.createWithdrawRequest(amt);
      ref.read(walletViewModelProvider.notifier).fetchBalance(isRefresh: true);
      ExternalLinkService.launchWhatsApp(
        customMessage:
            'Hi Admin, I have submitted a withdrawal request of ₹$amt on King Win app.',
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusGreen,
            content: Text(
                'Withdrawal request of ₹$amt submitted successfully! Admin will approve it shortly.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusRed,
            content: Text('Failed to submit withdrawal request: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.user?.walletBalance ?? 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.p24),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'WITHDRAW REQUEST',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Text(
                'Enter the amount you wish to withdraw. Your request will go to the admin for verification.',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  const Text('Available Balance: ',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text('₹$balance',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGold)),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Chips
              Row(
                children: [100, 500, 1000, 5000].map((amt) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                        onPressed: () => setState(
                            () => _amountController.text = amt.toString()),
                        child: Text('₹$amt',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Amount Input
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  hintText: 'Enter custom amount',
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitWithdraw,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.textPrimary),
                        )
                      : const Text('Submit & Notify on WhatsApp'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
