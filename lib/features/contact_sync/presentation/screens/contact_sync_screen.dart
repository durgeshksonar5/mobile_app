import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../view_models/contact_sync_view_model.dart';
import '../states/contact_sync_state.dart';
import 'contact_permission_screen.dart';
import 'contact_review_screen.dart';
import 'contact_sync_progress_screen.dart';

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
      ref.read(contactSyncViewModelProvider.notifier).checkConsentAndPermission(userId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final syncState = ref.watch(contactSyncViewModelProvider);
    final syncNotifier = ref.read(contactSyncViewModelProvider.notifier);
    final userId = authState.user?.id ?? 0;

    switch (syncState.step) {
      case ContactSyncStep.initial:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case ContactSyncStep.disclosureRequired:
      case ContactSyncStep.disclosureDeclined:
      case ContactSyncStep.permissionDenied:
      case ContactSyncStep.permissionPermanentlyDenied:
      case ContactSyncStep.permissionRestricted:
        return ContactPermissionScreen(
          onContinue: () => syncNotifier.acceptDisclosure(userId: userId),
          onNotNow: () {
            syncNotifier.declineDisclosure(userId: userId);
            context.pop();
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
          statusText: 'Sync failed: ${syncState.errorMessage ?? "Unknown error occurred"}',
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
