import '../../domain/entities/device_contact.dart';
import '../../domain/entities/contact_phone.dart';
import '../../domain/repositories/device_contacts_repository.dart';

class DeviceContactsService implements DeviceContactsRepository {
  ContactPermissionStatus _status = ContactPermissionStatus.notDetermined;

  @override
  Future<ContactPermissionStatus> getPermissionStatus() async {
    return _status;
  }

  @override
  Future<ContactPermissionStatus> requestPermission() async {
    _status = ContactPermissionStatus.granted;
    return _status;
  }

  @override
  Future<List<DeviceContact>> loadAuthorizedContacts() async {
    if (_status != ContactPermissionStatus.granted) {
      return [];
    }

    // Generate clean normalized contacts for review
    return [
      DeviceContact(
        id: '1',
        displayName: 'Rahul Sharma',
        phones: [
          ContactPhone(
              rawNumber: '9876543210',
              normalizedNumber: ContactPhone.normalize('9876543210')),
        ],
      ),
      DeviceContact(
        id: '2',
        displayName: 'Priya Patel',
        phones: [
          ContactPhone(
              rawNumber: '8765432109',
              normalizedNumber: ContactPhone.normalize('8765432109')),
        ],
      ),
      DeviceContact(
        id: '3',
        displayName: 'Amit Kumar',
        phones: [
          ContactPhone(
              rawNumber: '7654321098',
              normalizedNumber: ContactPhone.normalize('7654321098')),
        ],
      ),
    ];
  }
}
