import '../entities/device_contact.dart';

enum ContactPermissionStatus {
  notDetermined,
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

abstract interface class DeviceContactsRepository {
  Future<ContactPermissionStatus> getPermissionStatus();

  Future<ContactPermissionStatus> requestPermission();

  Future<List<DeviceContact>> loadAuthorizedContacts();
}
