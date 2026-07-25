import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../../domain/entities/device_contact.dart';
import '../../domain/entities/contact_phone.dart';
import '../../domain/repositories/device_contacts_repository.dart';

class DeviceContactsService implements DeviceContactsRepository {
  @override
  Future<ContactPermissionStatus> getPermissionStatus() async {
    // In flutter_contacts 1.1.9, we check if permission is granted by calling
    // requestPermission(readonly: true) which returns true immediately if already granted.
    final granted = await fc.FlutterContacts.requestPermission(readonly: true);
    return granted
        ? ContactPermissionStatus.granted
        : ContactPermissionStatus.denied;
  }

  @override
  Future<ContactPermissionStatus> requestPermission() async {
    final granted = await fc.FlutterContacts.requestPermission(readonly: true);
    return granted
        ? ContactPermissionStatus.granted
        : ContactPermissionStatus.denied;
  }

  @override
  Future<List<DeviceContact>> loadAuthorizedContacts() async {
    final granted = await fc.FlutterContacts.requestPermission(readonly: true);
    if (!granted) {
      return [];
    }

    try {
      final List<fc.Contact> fcContacts = await fc.FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      return fcContacts
          .map((c) {
            final phones = c.phones
                .map((p) {
                  final raw = p.number;
                  final normalized = ContactPhone.normalize(raw);
                  return ContactPhone(
                    rawNumber: raw,
                    normalizedNumber: normalized,
                    label: p.label.name,
                  );
                })
                .where((p) => p.normalizedNumber.isNotEmpty)
                .toList();

            final name = c.displayName.trim().isNotEmpty
                ? c.displayName.trim()
                : '${c.name.first} ${c.name.last}'.trim();

            return DeviceContact(
              id: c.id,
              displayName: name.isNotEmpty ? name : 'Unknown Contact',
              phones: phones,
            );
          })
          .where((dc) => dc.isValid)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
