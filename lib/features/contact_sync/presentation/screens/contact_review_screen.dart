import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../widgets/contact_sync_summary.dart';
import '../../domain/entities/device_contact.dart';

class ContactReviewScreen extends StatelessWidget {
  final List<DeviceContact> contacts;
  final ValueChanged<String> onToggleSelection;
  final VoidCallback onCancel;
  final VoidCallback onConfirmSync;

  const ContactReviewScreen({
    super.key,
    required this.contacts,
    required this.onToggleSelection,
    required this.onCancel,
    required this.onConfirmSync,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCount = contacts.where((c) => c.isSelected).length;
    final excludedCount = contacts.length - selectedCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Review Contacts to Sync',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: onCancel,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.p16),
              child: ContactSyncSummary(
                discoveredCount: contacts.length,
                eligibleCount: selectedCount,
                excludedCount: excludedCount,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: contacts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final phoneStr = contact.phones.isNotEmpty
                      ? contact.phones.first.normalizedNumber
                      : 'No Phone';
                  return CheckboxListTile(
                    activeColor: AppColors.primaryGold,
                    value: contact.isSelected,
                    onChanged: (_) => onToggleSelection(contact.id),
                    title: Text(contact.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(phoneStr,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceWhite,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedCount > 0 ? onConfirmSync : null,
                      child: Text('Sync ($selectedCount)'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
