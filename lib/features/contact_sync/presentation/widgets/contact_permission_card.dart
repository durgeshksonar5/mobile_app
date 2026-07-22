import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class ContactPermissionCard extends StatelessWidget {
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;
  final bool isPermanentlyDenied;

  const ContactPermissionCard({
    super.key,
    required this.onRequestPermission,
    required this.onOpenSettings,
    this.isPermanentlyDenied = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: AppColors.statusAmber, size: 22),
              SizedBox(width: 10),
              Text(
                'Contact Access Needed',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPermanentlyDenied
                ? 'Contact permission has been permanently denied. Please open your device Settings to grant access if you wish to sync contacts.'
                : 'Grant contact access to discover your friends and verify accounts on Quebix.',
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isPermanentlyDenied ? onOpenSettings : onRequestPermission,
              child: Text(
                  isPermanentlyDenied ? 'Open Settings' : 'Grant Permission'),
            ),
          ),
        ],
      ),
    );
  }
}
