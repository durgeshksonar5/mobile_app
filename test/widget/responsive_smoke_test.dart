import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:king_wins_mobile_app/features/auth/data/services/firebase_auth_service.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:king_wins_mobile_app/features/home/presentation/screens/home_screen.dart';
import 'package:king_wins_mobile_app/app/dependency_injection/providers.dart';
import 'package:king_wins_mobile_app/features/auth/data/repositories/auth_repository.dart';
import 'package:king_wins_mobile_app/features/auth/domain/models/user_model.dart';
import 'package:king_wins_mobile_app/features/home/data/repositories/results_repository.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/market_result.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/passbook_item.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/bid_item.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/game_rate.dart';
import 'package:king_wins_mobile_app/features/wallet/domain/models/wallet_balance.dart';
import 'package:king_wins_mobile_app/features/wallet/domain/repositories/wallet_repository.dart';

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

class FakeResultsRepository implements ResultsRepository {
  @override
  Future<List<MarketResult>> getLiveResults() async => [];
  @override
  Future<List<MarketResult>> getSattaHistory(String marketName) async => [];
  @override
  Future<List<PassbookItem>> getPassbookItems() async => [];
  @override
  Future<List<BidItem>> getBids() async => [];
  @override
  Future<List<GameRate>> getGameRates() async => [];
  @override
  Future<void> placeBid({
    required String marketName,
    required String gameType,
    required String session,
    required String selectedNumber,
    required int amount,
  }) async {}
  @override
  Future<void> createDepositRequest(int amount) async {}
  @override
  Future<void> createWithdrawRequest(int amount) async {}
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

  final testSizes = [
    const Size(320, 568),
    const Size(360, 800),
    const Size(412, 915),
    const Size(600, 960),
  ];

  for (final size in testSizes) {
    testWidgets(
        'LoginScreen renders without overflow at size ${size.width}x${size.height}',
        (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
            firebaseAuthServiceProvider.overrideWithValue(FakeFirebaseAuthService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'HomeScreen renders without overflow at size ${size.width}x${size.height}',
        (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
            resultsRepositoryProvider
                .overrideWithValue(FakeResultsRepository()),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  }
}
