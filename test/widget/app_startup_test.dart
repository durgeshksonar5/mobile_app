import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/app/app.dart';

import 'package:king_wins_mobile_app/app/dependency_injection/providers.dart';
import 'package:king_wins_mobile_app/features/auth/data/repositories/auth_repository.dart';
import 'package:king_wins_mobile_app/features/auth/domain/models/user_model.dart';
import 'package:king_wins_mobile_app/features/wallet/domain/models/wallet_balance.dart';
import 'package:king_wins_mobile_app/features/wallet/domain/repositories/wallet_repository.dart';

import 'package:king_wins_mobile_app/features/notifications/data/services/notification_service.dart';
import 'package:king_wins_mobile_app/features/notifications/presentation/providers/notification_providers.dart';

class FakeAuthRepository implements AuthRepository {
  static const dummyUser = UserModel(
    id: 1,
    phoneNumber: '+918767467998',
    name: 'Test User',
    walletBalance: 1000,
  );

  @override
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async => dummyUser;

  @override
  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String password,
    required String name,
  }) async => {
    'success': true,
    'message': 'Agent registered successfully.',
    'user': {
      'id': '1',
      'email': '',
      'phone_number': phoneNumber,
      'name': name,
      'role': 'Agent',
      'is_active': true,
    }
  };

  @override
  Future<UserModel> firebaseLogin(
          {required String idToken,
          String? name,
          String? password,
          bool isRegister = false}) async =>
      dummyUser;
  @override
  Future<UserModel?> getProfile() async => dummyUser;
  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async => dummyUser;
  @override
  Future<void> logout() async {}
}

class FakeWalletRepository implements WalletRepository {
  @override
  Future<WalletBalance> getWalletBalance() async =>
      const WalletBalance(availableBalance: 1000);
  @override
  Future<void> clearCache() async {}
}

class FakeNotificationService implements NotificationService {
  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> requestPermissionsAndRegister() async {}
}

void main() {
  setUpAll(() {
    AppConfig.initialize();
  });

  testWidgets('App startup renders KingWinApp without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
          notificationServiceProvider
              .overrideWithValue(FakeNotificationService()),
        ],
        child: const KingWinApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(KingWinApp), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
