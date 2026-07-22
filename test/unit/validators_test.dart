import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/core/validation/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('formatPhoneNumber formats 10-digit phone with +91 prefix', () {
      expect(
          Validators.formatPhoneNumber('8767467998'), equals('+918767467998'));
      expect(
          Validators.formatPhoneNumber('08767467998'), equals('+918767467998'));
      expect(Validators.formatPhoneNumber('+918767467998'),
          equals('+918767467998'));
    });

    test(
        'validatePhone returns null for valid phone and error for invalid phone',
        () {
      expect(Validators.validatePhone('8767467998'), isNull);
      expect(Validators.validatePhone('123'),
          equals('Please enter a valid phone number.'));
      expect(
          Validators.validatePhone(''), equals('Please fill in all fields.'));
    });

    test('validatePassword validates minimum character length', () {
      expect(Validators.validatePassword('123456', minLength: 6), isNull);
      expect(Validators.validatePassword('123', minLength: 6),
          equals('Password must be at least 6 characters long.'));
      expect(Validators.validatePassword(''),
          equals('Please fill in all fields.'));
    });

    test('validateOtp validates 6-digit OTP code', () {
      expect(Validators.validateOtp('123456'), isNull);
      expect(
          Validators.validateOtp('1234'), equals('OTP code must be 6 digits.'));
      expect(Validators.validateOtp(''),
          equals('Please enter the OTP verification code.'));
    });

    test('validateAmount validates positive integer amounts and max balance',
        () {
      expect(Validators.validateAmount('500'), isNull);
      expect(Validators.validateAmount('-10'),
          equals('Please enter a valid amount.'));
      expect(Validators.validateAmount('0'),
          equals('Please enter a valid amount.'));
      expect(Validators.validateAmount('1500', maxBalance: 1000),
          equals('Insufficient balance!'));
    });
  });
}
