class ContactEmailDto {
  final String email;

  const ContactEmailDto({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
