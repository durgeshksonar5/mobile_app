import 'contact_phone_dto.dart';
import 'contact_email_dto.dart';

class ContactSyncItemDto {
  final String name;
  final List<ContactPhoneDto> phones;
  final List<ContactEmailDto> emails;

  const ContactSyncItemDto({
    required this.name,
    required this.phones,
    this.emails = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phones': phones.map((p) => p.toJson()).toList(),
      if (emails.isNotEmpty) 'emails': emails.map((e) => e.toJson()).toList(),
    };
  }
}
