class ContactPhone {
  final String rawNumber;
  final String normalizedNumber;
  final String? label;

  const ContactPhone({
    required this.rawNumber,
    required this.normalizedNumber,
    this.label,
  });

  static String normalize(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '+91${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+') && cleaned.length == 10) {
      cleaned = '+91$cleaned';
    }
    return cleaned;
  }
}
