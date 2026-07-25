import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/screens/login_screen.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:king_wins_mobile_app/features/auth/data/services/firebase_auth_service.dart';

class FakeFailingFirebaseAuthService implements FirebaseAuthService {
  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException exception) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    onVerificationFailed(
      FirebaseAuthException(
        code: 'invalid-phone-number',
        message: 'The provided phone number is not valid.',
      ),
    );
  }

  @override
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    throw FirebaseAuthException(
      code: 'invalid-verification-code',
      message: 'OTP verification failed.',
    );
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

  testWidgets('Login form validation triggers on invalid phone/password',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthServiceProvider.overrideWithValue(FakeFailingFirebaseAuthService()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final button = find.byType(ElevatedButton).first;
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Please fill in all fields.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Login error state shows controlled error message on failure',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthServiceProvider.overrideWithValue(FakeFailingFirebaseAuthService()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final phoneFinder = find.byType(TextField).first;
    await tester.enterText(phoneFinder, '9876543210');
    await tester.pump(const Duration(milliseconds: 100));

    final button = find.byType(ElevatedButton).first;
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('The provided phone number is not valid.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
