import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/features/auth/data/dto/login_request_dto.dart';
import 'package:king_wins_mobile_app/features/auth/data/dto/login_response_dto.dart';

void main() {
  group('Auth DTO Tests', () {
    test('LoginRequestDto serializes to JSON accurately', () {
      const dto = LoginRequestDto(
          phoneNumber: '+919876543210', password: 'password123');
      final json = dto.toJson();

      expect(json['phone_number'], '+919876543210');
      expect(json['password'], 'password123');
    });

    test('LoginResponseDto parses JSON correctly', () {
      final json = {
        'access': 'access_token_abc',
        'refresh': 'refresh_token_xyz',
        'user': {
          'id': 42,
          'phone_number': '9876543210',
          'name': 'Test User',
          'wallet_balance': 5000,
        }
      };

      final dto = LoginResponseDto.fromJson(json);
      expect(dto.access, 'access_token_abc');
      expect(dto.refresh, 'refresh_token_xyz');

      final user = dto.toEntity();
      expect(user, isNotNull);
      expect(user!.id, 42);
      expect(user.phoneNumber, '9876543210');
      expect(user.walletBalance, 5000);
    });
  });
}
