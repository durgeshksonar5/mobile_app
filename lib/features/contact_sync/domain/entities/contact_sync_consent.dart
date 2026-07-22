enum ContactConsentStatus {
  notAsked,
  accepted,
  declined,
  revoked;
}

class ContactSyncConsent {
  final int userId;
  final int consentVersion;
  final DateTime? consentedAt;
  final String purpose;
  final List<String> fieldsApproved;
  final ContactConsentStatus status;
  final DateTime? lastSyncAt;

  const ContactSyncConsent({
    required this.userId,
    this.consentVersion = 1,
    this.consentedAt,
    required this.purpose,
    this.fieldsApproved = const ['display_name', 'normalized_phone'],
    required this.status,
    this.lastSyncAt,
  });

  bool get isAccepted => status == ContactConsentStatus.accepted;
}
