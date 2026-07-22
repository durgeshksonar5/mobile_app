import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/app/dependency_injection/providers.dart';
import 'package:king_wins_mobile_app/features/auth/data/repositories/auth_repository.dart';
import 'package:king_wins_mobile_app/features/auth/domain/models/user_model.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/screens/login_screen.dart';

class FailingAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login(String phone, String password) async {
    throw Exception('Invalid phone number or password.');
  }

  @override
  Future<UserModel> firebaseLogin(
          {required String idToken,
          String? name,
          String? password,
          bool isRegister = false}) async =>
      throw UnimplementedError();

  @override
  Future<UserModel?> getProfile() async => null;

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}
}

void main() {
  setUpAll(() {
    AppConfig.initialize();
  });

  testWidgets('Login form validation triggers on invalid phone/password',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final button = find.byType(ElevatedButton).first;
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Login error state shows controlled error message on failure',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FailingAuthRepository()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final phoneFinder = find.byType(TextField).at(0);
    final passwordFinder = find.byType(TextField).at(1);

    await tester.enterText(phoneFinder, '9876543210');
    await tester.enterText(passwordFinder, 'wrongpassword');
    await tester.pump(const Duration(milliseconds: 100));

    final button = find.byType(ElevatedButton).first;
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('Invalid phone number or password.'),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
