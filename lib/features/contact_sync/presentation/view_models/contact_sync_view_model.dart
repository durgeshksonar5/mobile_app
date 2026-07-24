import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/contact_sync_repository.dart';
import '../../domain/repositories/device_contacts_repository.dart';
import '../../domain/entities/contact_sync_consent.dart';
import '../states/contact_sync_state.dart';
import '../../../../app/dependency_injection/providers.dart';

final contactSyncViewModelProvider =
    StateNotifierProvider<ContactSyncViewModel, ContactSyncState>((ref) {
  final deviceContactsRepo = ref.watch(deviceContactsRepositoryProvider);
  final contactSyncRepo = ref.watch(contactSyncRepositoryProvider);
  return ContactSyncViewModel(deviceContactsRepo, contactSyncRepo);
});

class ContactSyncViewModel extends StateNotifier<ContactSyncState> {
  final DeviceContactsRepository _deviceContactsRepository;
  final ContactSyncRepository _contactSyncRepository;

  ContactSyncViewModel(
    this._deviceContactsRepository,
    this._contactSyncRepository,
  ) : super(const ContactSyncState());

  Future<void> checkConsentAndPermission({required int userId}) async {
    final consent =
        await _contactSyncRepository.getConsentStatus(userId: userId);
    final permission = await _deviceContactsRepository.getPermissionStatus();

    if (permission == ContactPermissionStatus.granted) {
      if (consent.status != ContactConsentStatus.accepted) {
        await _contactSyncRepository.updateConsentStatus(
          userId: userId,
          status: ContactConsentStatus.accepted,
        );
      }
      state = state.copyWith(
        step: ContactSyncStep.permissionGranted,
        consentStatus: ContactConsentStatus.accepted,
      );
      await loadContacts();
    } else {
      state = state.copyWith(
        step: ContactSyncStep.permissionDenied,
        consentStatus: consent.status,
      );
    }
  }

  Future<void> acceptDisclosure({required int userId}) async {
    await _contactSyncRepository.updateConsentStatus(
      userId: userId,
      status: ContactConsentStatus.accepted,
    );

    state = state.copyWith(
      step: ContactSyncStep.permissionRequesting,
      consentStatus: ContactConsentStatus.accepted,
    );

    final status = await _deviceContactsRepository.requestPermission();
    if (status == ContactPermissionStatus.granted) {
      state = state.copyWith(step: ContactSyncStep.permissionGranted);
      await loadContacts();
    } else if (status == ContactPermissionStatus.permanentlyDenied) {
      state = state.copyWith(step: ContactSyncStep.permissionPermanentlyDenied);
    } else {
      state = state.copyWith(step: ContactSyncStep.permissionDenied);
    }
  }

  Future<void> declineDisclosure({required int userId}) async {
    await _contactSyncRepository.updateConsentStatus(
      userId: userId,
      status: ContactConsentStatus.declined,
    );
    state = state.copyWith(
      step: ContactSyncStep.disclosureDeclined,
      consentStatus: ContactConsentStatus.declined,
    );
  }

  Future<void> loadContacts() async {
    state = state.copyWith(step: ContactSyncStep.loadingContacts);
    final contacts = await _deviceContactsRepository.loadAuthorizedContacts();

    if (contacts.isEmpty) {
      state = state.copyWith(
        step: ContactSyncStep.noContacts,
        discoveredContacts: [],
        totalCount: 0,
      );
    } else {
      state = state.copyWith(
        step: ContactSyncStep.awaitingUserConfirmation,
        discoveredContacts: contacts,
        totalCount: contacts.length,
      );
    }
  }

  void toggleContactSelection(String contactId) {
    final updated = state.discoveredContacts.map((c) {
      if (c.id == contactId) {
        return c.copyWith(isSelected: !c.isSelected);
      }
      return c;
    }).toList();

    state = state.copyWith(discoveredContacts: updated);
  }

  Future<bool> startSync() async {
    state = state.copyWith(
      step: ContactSyncStep.uploading,
      uploadProgress: 0.2,
    );

    final selected =
        state.discoveredContacts.where((c) => c.isSelected).toList();
    final result = await _contactSyncRepository.syncContacts(selected);

    if (result.isSuccess) {
      state = state.copyWith(
        step: ContactSyncStep.success,
        uploadProgress: 1.0,
        syncedCount: result.syncedCount,
        lastResult: result,
      );
      return true;
    } else {
      state = state.copyWith(
        step: ContactSyncStep.failure,
        errorMessage: result.errorMessage,
        lastResult: result,
      );
      return false;
    }
  }

  Future<void> deleteSyncedContacts({required int userId}) async {
    state = state.copyWith(step: ContactSyncStep.syncedDataDeletionInProgress);
    await _contactSyncRepository.deleteSyncedContacts();
    await _contactSyncRepository.updateConsentStatus(
      userId: userId,
      status: ContactConsentStatus.revoked,
    );
    state = state.copyWith(
      step: ContactSyncStep.syncedDataDeleted,
      consentStatus: ContactConsentStatus.revoked,
      syncedCount: 0,
    );
  }
}
