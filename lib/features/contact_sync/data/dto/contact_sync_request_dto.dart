import 'contact_sync_item_dto.dart';

class ContactSyncRequestDto {
  final String batchId;
  final List<ContactSyncItemDto> contacts;

  const ContactSyncRequestDto({
    required this.batchId,
    required this.contacts,
  });

  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'contacts': contacts.map((c) => c.toJson()).toList(),
    };
  }
}
