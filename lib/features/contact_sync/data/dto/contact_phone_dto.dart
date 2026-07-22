class ContactPhoneDto {
  final String phone;
  final String? label;

  const ContactPhoneDto({
    required this.phone,
    this.label,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      if (label != null) 'label': label,
    };
  }
}
