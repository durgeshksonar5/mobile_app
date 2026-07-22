import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ContactSyncProgress extends StatelessWidget {
  final double progress;
  final String statusText;

  const ContactSyncProgress({
    super.key,
    required this.progress,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: progress > 0 ? progress : null,
          backgroundColor: AppColors.primaryGoldBg,
          color: AppColors.primaryGold,
          minHeight: 8,
        ),
        const SizedBox(height: 14),
        Text(
          statusText,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
