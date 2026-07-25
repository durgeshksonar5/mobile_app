import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/app/dependency_injection/providers.dart';
import 'package:king_wins_mobile_app/features/auth/data/repositories/auth_repository.dart';
import 'package:king_wins_mobile_app/features/auth/domain/models/user_model.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/screens/login_screen.dart';
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

  testWidgets('LoginScreen renders KING WIN brand title and form elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          firebaseAuthServiceProvider.overrideWithValue(FakeFirebaseAuthService()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);
    final imageWidget = tester.widget<Image>(imageFinder);
    expect((imageWidget.image as AssetImage).assetName,
        'assets/images/king-win-logo-transferent-crop.png');
    expect(find.text('Trusted Satta Matka Experience'), findsOneWidget);
    expect(find.text('Sign In with Phone'), findsOneWidget);
    expect(find.text('Get OTP Verification'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
