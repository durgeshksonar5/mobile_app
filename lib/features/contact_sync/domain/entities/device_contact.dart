import 'contact_phone.dart';
import 'contact_email.dart';

class DeviceContact {
  final String id;
  final String displayName;
  final List<ContactPhone> phones;
  final List<ContactEmail> emails;
  final bool isSelected;

  const DeviceContact({
    required this.id,
    required this.displayName,
    required this.phones,
    this.emails = const [],
    this.isSelected = true,
  });

  DeviceContact copyWith({
    bool? isSelected,
  }) {
    return DeviceContact(
      id: id,
      displayName: displayName,
      phones: phones,
      emails: emails,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  bool get isValid => displayName.trim().isNotEmpty && phones.isNotEmpty;
}
