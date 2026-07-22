class ContactSyncItemDto {
  final String name;
  final String phone;

  const ContactSyncItemDto({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}
