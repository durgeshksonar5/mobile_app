import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class ContactSyncSummary extends StatelessWidget {
  final int discoveredCount;
  final int eligibleCount;
  final int excludedCount;

  const ContactSyncSummary({
    super.key,
    required this.discoveredCount,
    required this.eligibleCount,
    required this.excludedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem('Discovered', discoveredCount.toString()),
          _buildItem('Selected', eligibleCount.toString(),
              color: AppColors.statusGreen),
          _buildItem('Excluded', excludedCount.toString(),
              color: AppColors.statusRed),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color ?? AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted),
        ),
      ],
    );
  }
}
