import 'app_environment.dart';
import 'config_validation.dart';

class AppConfig {
  static const String _envStr =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');
  static const String _apiUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://api.kingwins.pro/api/v1');
  static const String _whatsapp = String.fromEnvironment('WHATSAPP_LINK',
      defaultValue: 'https://wa.me/919226591996');
  static const String _syncPurpose = String.fromEnvironment(
    'CONTACT_SYNC_PURPOSE',
    defaultValue:
        'Account verification, referral invite matching, and peer wallet transfers on Quebix backend.',
  );

  static late final AppEnvironment environment;
  static late final String apiBaseUrl;
  static late final String whatsappLink;
  static late final String contactSyncPurpose;
  static const int networkTimeoutMs = 30000;
  static const String appVersion = '1.0.8';
  static const String updateUrl = 'https://download.kingwins.pro/apk-kingwins';

  static void initialize() {
    environment = AppEnvironment.fromString(_envStr);
    apiBaseUrl = _apiUrl;
    whatsappLink = _whatsapp;
    contactSyncPurpose = _syncPurpose;

    ConfigValidation.validate(
      apiBaseUrl: apiBaseUrl,
      whatsappLink: whatsappLink,
      environment: environment,
      contactSyncPurpose: contactSyncPurpose,
    );
  }
}
