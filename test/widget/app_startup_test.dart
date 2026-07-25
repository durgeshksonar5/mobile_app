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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:king_wins_mobile_app/features/auth/data/services/firebase_auth_service.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/controllers/auth_controller.dart';

class FakeAuthRepository implements AuthRepository {
  static const dummyUser = UserModel(
    id: 1,
    phoneNumber: '+918767467998',
    name: 'Test User',
    walletBalance: 1000,
  );

  @override
  Future<UserModel> login(String phone, String password) async => dummyUser;
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

class FakeFirebaseAuthService implements FirebaseAuthService {
  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException exception) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onAutoRetrievalTimeout,
  }) async {}

  @override
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getCurrentIdToken() async => null;

  @override
  Future<void> signOut() async {}
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
          firebaseAuthServiceProvider
              .overrideWithValue(FakeFirebaseAuthService()),
        ],
        child: const KingWinApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(KingWinApp), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
