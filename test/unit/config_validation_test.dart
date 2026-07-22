import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/core/config/app_environment.dart';
import 'package:king_wins_mobile_app/core/config/config_validation.dart';

void main() {
  group('ConfigValidation Tests', () {
    test('validates successful configuration in development', () {
      expect(
        () => ConfigValidation.validate(
          apiBaseUrl: 'https://api.quebix.in/api/v1',
          whatsappLink: 'https://wa.link/ctw7uq',
          environment: AppEnvironment.development,
          contactSyncPurpose: 'Testing purpose',
        ),
        returnsNormally,
      );
    });

    test('throws exception if apiBaseUrl is empty', () {
      expect(
        () => ConfigValidation.validate(
          apiBaseUrl: '   ',
          whatsappLink: 'https://wa.link/ctw7uq',
          environment: AppEnvironment.development,
          contactSyncPurpose: 'Testing purpose',
        ),
        throwsA(isA<ConfigValidationException>()),
      );
    });

    test('throws exception if production apiBaseUrl is not https', () {
      expect(
        () => ConfigValidation.validate(
          apiBaseUrl: 'http://api.quebix.in/api/v1',
          whatsappLink: 'https://wa.link/ctw7uq',
          environment: AppEnvironment.production,
          contactSyncPurpose: 'Production purpose approved',
        ),
        throwsA(isA<ConfigValidationException>()),
      );
    });
  });
}
