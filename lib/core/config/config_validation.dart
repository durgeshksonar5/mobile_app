import 'app_environment.dart';

class ConfigValidationException implements Exception {
  final String message;
  ConfigValidationException(this.message);

  @override
  String toString() => 'ConfigValidationException: $message';
}

class ConfigValidation {
  static void validate({
    required String apiBaseUrl,
    required String whatsappLink,
    required AppEnvironment environment,
    required String contactSyncPurpose,
  }) {
    if (apiBaseUrl.trim().isEmpty) {
      throw ConfigValidationException(
          'API_BASE_URL compile-time variable is missing or empty.');
    }

    final uri = Uri.tryParse(apiBaseUrl.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        (!uri.isScheme('http') && !uri.isScheme('https'))) {
      throw ConfigValidationException(
          'API_BASE_URL "$apiBaseUrl" is malformed. Must be a valid HTTP/HTTPS URL.');
    }

    if (environment.isProduction && !uri.isScheme('https')) {
      throw ConfigValidationException(
          'Production API_BASE_URL must use secure HTTPS scheme. Received: "$apiBaseUrl"');
    }

    if (whatsappLink.trim().isNotEmpty) {
      final waUri = Uri.tryParse(whatsappLink.trim());
      if (waUri == null || !waUri.hasAuthority) {
        throw ConfigValidationException(
            'WHATSAPP_LINK "$whatsappLink" is malformed.');
      }
    }

    if (environment.isProduction) {
      if (contactSyncPurpose.trim().isEmpty ||
          contactSyncPurpose.contains('<APPROVED')) {
        throw ConfigValidationException(
            'CONTACT_SYNC_PURPOSE configuration is missing or contains placeholder text in production.');
      }
    }
  }
}
