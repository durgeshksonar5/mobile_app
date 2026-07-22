import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class ContactSyncProgressScreen extends StatelessWidget {
  final double progress;
  final String statusText;
  final VoidCallback? onDone;

  const ContactSyncProgressScreen({
    super.key,
    required this.progress,
    required this.statusText,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= 1.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isComplete)
              const Icon(Icons.check_circle,
                  color: AppColors.statusGreen, size: 64)
            else
              const CircularProgressIndicator(color: AppColors.primaryGold),
            const SizedBox(height: 20),
            Text(
              isComplete ? 'Contact Sync Completed!' : 'Syncing Contacts...',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderLight,
              color: AppColors.primaryGold,
            ),
            if (isComplete && onDone != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onDone,
                  child: const Text('Continue to Dashboard'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
