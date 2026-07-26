/// Form and field validation utilities reproducing the frontend web rules exactly.
class Validators {
  /// Sanitize and format phone number for backend matching
  static String formatPhoneNumber(String phone) {
    String clean = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (!clean.startsWith('+')) {
      clean = clean.replaceFirst(RegExp(r'^0+'), '');
    }
    if (!clean.startsWith('+')) {
      if (clean.length == 10) {
        return '+91$clean';
      } else {
        return '+$clean';
      }
    }
    return clean;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please fill in all fields.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please fill in all fields.';
    }
    final formatted = formatPhoneNumber(value);
    if (formatted.length < 12) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  static String? validatePassword(String? value, {int minLength = 1}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please fill in all fields.';
    }
    if (value.trim().length < minLength) {
      return 'Password must be at least $minLength characters long.';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the OTP verification code.';
    }
    if (value.trim().length != 6) {
      return 'OTP code must be 6 digits.';
    }
    return null;
  }

  static String? validateAmount(String? value, {int? maxBalance}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a valid amount.';
    }
    final amt = int.tryParse(value.trim());
    if (amt == null || amt <= 0) {
      return 'Please enter a valid amount.';
    }
    if (maxBalance != null && amt > maxBalance) {
      return 'Insufficient balance!';
    }
    return null;
  }
}
