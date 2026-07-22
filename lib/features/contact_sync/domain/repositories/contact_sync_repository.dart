import '../entities/device_contact.dart';
import '../entities/contact_sync_result.dart';
import '../entities/contact_sync_consent.dart';

abstract interface class ContactSyncRepository {
  Future<ContactSyncResult> syncContacts(List<DeviceContact> contacts);

  Future<void> deleteSyncedContacts();

  Future<ContactSyncConsent> getConsentStatus({required int userId});

  Future<void> updateConsentStatus({
    required int userId,
    required ContactConsentStatus status,
  });
}
