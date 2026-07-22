import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/features/contact_sync/domain/entities/contact_phone.dart';

void main() {
  group('ContactPhone Normalization Tests', () {
    test('normalizes 10 digit Indian number with +91', () {
      expect(ContactPhone.normalize('9876543210'), '+919876543210');
    });

    test('normalizes 11 digit Indian number starting with 0', () {
      expect(ContactPhone.normalize('09876543210'), '+919876543210');
    });

    test('preserves existing E.164 country code', () {
      expect(ContactPhone.normalize('+919876543210'), '+919876543210');
    });

    test('strips spaces and hyphens', () {
      expect(ContactPhone.normalize('98765-43210'), '+919876543210');
      expect(ContactPhone.normalize('+91 98765 43210'), '+919876543210');
    });
  });
}
