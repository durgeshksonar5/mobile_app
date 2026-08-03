import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../wallet/presentation/view_models/wallet_view_model.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../../../../core/services/external_link_service.dart';

class AddFundDialog extends ConsumerStatefulWidget {
  const AddFundDialog({super.key});

  @override
  ConsumerState<AddFundDialog> createState() => _AddFundDialogState();
}

class _AddFundDialogState extends ConsumerState<AddFundDialog> {
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitDeposit() async {
    final amt = int.tryParse(_amountController.text.trim());
    if (amt == null || amt < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Minimum deposit amount required is ₹100.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(resultsRepositoryProvider);
      await repo.createDepositRequest(amt);
      ref.read(walletViewModelProvider.notifier).fetchBalance(isRefresh: true);
      final user = ref.read(authViewModelProvider).user;
      final username = user?.name ?? 'Unknown';
      final userPhone = user?.phoneNumber ?? 'Unknown';
      ExternalLinkService.launchWhatsApp(
        target: WhatsAppTarget.deposit,
        customMessage:
            'Deposit Request\nUsername: $username\nAmount: ₹$amt\nPhone Number: $userPhone',
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusGreen,
            content: Text(
                'Add fund request of ₹$amt submitted successfully! Admin will approve it shortly.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusRed,
            content: Text('Failed to submit deposit request: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'ADD FUND REQUEST',
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
              const SizedBox(height: 10),

              const Text(
                'Enter the amount you wish to add to your wallet. We will redirect you to WhatsApp to complete the payment. Admin will approve it instantly.',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.4),
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
                  onPressed: _isSubmitting ? null : _submitDeposit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.textWhite),
                        )
                      : const Text('Submit & Pay via WhatsApp'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
