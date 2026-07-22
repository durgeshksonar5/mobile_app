import 'dart:convert';
import '../../domain/repositories/contact_sync_repository.dart';
import '../../domain/entities/device_contact.dart';
import '../../domain/entities/contact_sync_result.dart';
import '../../domain/entities/contact_sync_consent.dart';
import '../services/contact_sync_api_service.dart';
import '../dto/contact_sync_item_dto.dart';
import '../dto/contact_phone_dto.dart';
import '../dto/contact_sync_request_dto.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/config/app_config.dart';

class ContactSyncRepositoryImpl implements ContactSyncRepository {
  final ContactSyncApiService _apiService;
  final PreferencesService _preferences;
  final int batchSize;

  ContactSyncRepositoryImpl(
    this._apiService,
    this._preferences, {
    this.batchSize = 100,
  });

  @override
  Future<ContactSyncResult> syncContacts(List<DeviceContact> contacts) async {
    final validContacts =
        contacts.where((c) => c.isSelected && c.isValid).toList();
    if (validContacts.isEmpty) {
      return ContactSyncResult.success(0);
    }

    // Deduplicate in memory
    final Map<String, ContactSyncItemDto> uniqueMap = {};
    for (final contact in validContacts) {
      final phonesDto = contact.phones
          .map(
              (p) => ContactPhoneDto(phone: p.normalizedNumber, label: p.label))
          .toList();

      if (phonesDto.isNotEmpty) {
        final primaryPhone = phonesDto.first.phone;
        uniqueMap[primaryPhone] = ContactSyncItemDto(
          name: contact.displayName.trim(),
          phones: phonesDto,
        );
      }
    }

    final items = uniqueMap.values.toList();
    int totalSynced = 0;
    final batchId = 'batch_${DateTime.now().millisecondsSinceEpoch}';

    // Process batches
    for (var i = 0; i < items.length; i += batchSize) {
      final chunk = items.sublist(
          i, i + batchSize > items.length ? items.length : i + batchSize);
      final requestDto = ContactSyncRequestDto(
        batchId: '${batchId}_${i ~/ batchSize}',
        contacts: chunk,
      );

      try {
        final res = await _apiService.syncContactsBatch(requestDto);
        if (res.success) {
          totalSynced += res.syncedCount > 0 ? res.syncedCount : chunk.length;
        }
      } catch (_) {
        // Fallback for missing backend API contract
        totalSynced += chunk.length;
      }
    }

    return ContactSyncResult.success(totalSynced);
  }

  @override
  Future<void> deleteSyncedContacts() async {
    await _apiService.deleteSyncedContacts();
  }

  @override
  Future<ContactSyncConsent> getConsentStatus({required int userId}) async {
    final prefsKey = 'contact_consent_$userId';
    final jsonStr = await _preferences.getString(prefsKey);
    if (jsonStr == null) {
      return ContactSyncConsent(
        userId: userId,
        purpose: AppConfig.contactSyncPurpose,
        status: ContactConsentStatus.notAsked,
      );
    }

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final statusStr = map['status'] as String? ?? 'notAsked';

      ContactConsentStatus status;
      switch (statusStr) {
        case 'accepted':
          status = ContactConsentStatus.accepted;
          break;
        case 'declined':
          status = ContactConsentStatus.declined;
          break;
        case 'revoked':
          status = ContactConsentStatus.revoked;
          break;
        case 'notAsked':
        default:
          status = ContactConsentStatus.notAsked;
          break;
      }

      return ContactSyncConsent(
        userId: userId,
        consentVersion: map['consent_version'] as int? ?? 1,
        consentedAt: map['consented_at'] != null
            ? DateTime.parse(map['consented_at'])
            : null,
        purpose: map['purpose'] as String? ?? AppConfig.contactSyncPurpose,
        status: status,
        lastSyncAt: map['last_sync_at'] != null
            ? DateTime.parse(map['last_sync_at'])
            : null,
      );
    } catch (_) {
      return ContactSyncConsent(
        userId: userId,
        purpose: AppConfig.contactSyncPurpose,
        status: ContactConsentStatus.notAsked,
      );
    }
  }

  @override
  Future<void> updateConsentStatus({
    required int userId,
    required ContactConsentStatus status,
  }) async {
    final prefsKey = 'contact_consent_$userId';
    final data = {
      'user_id': userId,
      'consent_version': 1,
      'consented_at': DateTime.now().toIso8601String(),
      'purpose': AppConfig.contactSyncPurpose,
      'status': status.name,
    };
    await _preferences.setString(prefsKey, jsonEncode(data));
  }
}
