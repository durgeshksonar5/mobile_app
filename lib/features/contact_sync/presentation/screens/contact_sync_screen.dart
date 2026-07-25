import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../view_models/contact_sync_view_model.dart';
import '../states/contact_sync_state.dart';
import 'contact_review_screen.dart';
import 'contact_sync_progress_screen.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactSyncScreen extends ConsumerStatefulWidget {
  const ContactSyncScreen({super.key});

  @override
  ConsumerState<ContactSyncScreen> createState() => _ContactSyncScreenState();
}

class _ContactSyncScreenState extends ConsumerState<ContactSyncScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authViewModelProvider).user;
      final userId = user?.id ?? 0;
      ref
          .read(contactSyncViewModelProvider.notifier)
          .checkConsentAndPermission(userId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(contactSyncViewModelProvider);
    final syncNotifier = ref.read(contactSyncViewModelProvider.notifier);

    switch (syncState.step) {
      case ContactSyncStep.initial:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case ContactSyncStep.disclosureRequired:
      case ContactSyncStep.disclosureAccepted:
      case ContactSyncStep.disclosureDeclined:
      case ContactSyncStep.permissionDenied:
      case ContactSyncStep.permissionPermanentlyDenied:
      case ContactSyncStep.permissionRestricted:
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text(
              'Sync Contacts',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.surfaceWhite,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.p24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGoldBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.contacts_outlined,
                      color: AppColors.primaryGold,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Contact Access Required',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'To find your friends and invite them to Quebix, please enable Contacts access in your device Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      child: const Text('Open Settings'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case ContactSyncStep.loadingContacts:
        return const ContactSyncProgressScreen(
          progress: 0.1,
          statusText: 'Fetching contacts from your device...',
        );

      case ContactSyncStep.awaitingUserConfirmation:
      case ContactSyncStep.contactsLoaded:
        return ContactReviewScreen(
          contacts: syncState.discoveredContacts,
          onToggleSelection: syncNotifier.toggleContactSelection,
          onCancel: () => context.pop(),
          onConfirmSync: () async {
            final success = await syncNotifier.startSync();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Contacts synchronized successfully!'
                      : 'Failed to synchronize contacts: ${syncState.errorMessage ?? "Network error"}'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
        );

      case ContactSyncStep.uploading:
        return ContactSyncProgressScreen(
          progress: syncState.uploadProgress,
          statusText: 'Uploading and synchronizing contacts...',
        );

      case ContactSyncStep.success:
        return ContactSyncProgressScreen(
          progress: 1.0,
          statusText: 'Successfully synced ${syncState.syncedCount} contacts!',
          onDone: () => context.pop(),
        );

      case ContactSyncStep.failure:
        return ContactSyncProgressScreen(
          progress: 0.0,
          statusText:
              'Sync failed: ${syncState.errorMessage ?? "Unknown error occurred"}',
          onDone: () => context.pop(),
        );

      default:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}
