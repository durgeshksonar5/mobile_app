import '../../domain/entities/device_contact.dart';
import '../../domain/entities/contact_sync_result.dart';
import '../../domain/entities/contact_sync_consent.dart';

enum ContactSyncStep {
  initial,
  disclosureRequired,
  disclosureAccepted,
  disclosureDeclined,
  permissionRequesting,
  permissionGranted,
  permissionDenied,
  permissionPermanentlyDenied,
  permissionRestricted,
  loadingContacts,
  contactsLoaded,
  noContacts,
  awaitingUserConfirmation,
  preparingUpload,
  uploading,
  partialSuccess,
  success,
  failure,
  consentRevoked,
  syncedDataDeletionInProgress,
  syncedDataDeleted,
}

class ContactSyncState {
  final ContactSyncStep step;
  final ContactConsentStatus consentStatus;
  final List<DeviceContact> discoveredContacts;
  final int syncedCount;
  final int totalCount;
  final double uploadProgress;
  final String? errorMessage;
  final ContactSyncResult? lastResult;

  const ContactSyncState({
    this.step = ContactSyncStep.initial,
    this.consentStatus = ContactConsentStatus.notAsked,
    this.discoveredContacts = const [],
    this.syncedCount = 0,
    this.totalCount = 0,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.lastResult,
  });

  ContactSyncState copyWith({
    ContactSyncStep? step,
    ContactConsentStatus? consentStatus,
    List<DeviceContact>? discoveredContacts,
    int? syncedCount,
    int? totalCount,
    double? uploadProgress,
    String? errorMessage,
    ContactSyncResult? lastResult,
    bool clearError = false,
  }) {
    return ContactSyncState(
      step: step ?? this.step,
      consentStatus: consentStatus ?? this.consentStatus,
      discoveredContacts: discoveredContacts ?? this.discoveredContacts,
      syncedCount: syncedCount ?? this.syncedCount,
      totalCount: totalCount ?? this.totalCount,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastResult: lastResult ?? this.lastResult,
    );
  }
}
