import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/app/dependency_injection/providers.dart';
import 'package:king_wins_mobile_app/features/auth/data/repositories/auth_repository.dart';
import 'package:king_wins_mobile_app/features/auth/domain/models/user_model.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/screens/login_screen.dart';
import 'package:king_wins_mobile_app/core/errors/app_exception.dart';

class FakeFailingAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    throw const ServerException('Invalid phone number or password.', 401);
  }

  @override
  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String password,
    required String name,
  }) async {
    return {'success': false, 'message': 'Registration failed.'};
  }

  @override
  Future<UserModel> firebaseLogin({
    required String idToken,
    String? name,
    String? password,
    bool isRegister = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getProfile() async => null;

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }

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
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeFailingAuthRepository()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final button = find.byType(ElevatedButton).first;
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Please fill in all fields.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Login error state shows controlled error message on failure',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeFailingAuthRepository()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Fill in Phone
    final loginFinder = find.byType(TextField).first;
    await tester.enterText(loginFinder, '9876543210');
    await tester.pump(const Duration(milliseconds: 100));

    // Fill in Password
    final passFinder = find.byType(TextField).last;
    await tester.enterText(passFinder, 'WrongPassword123');
    await tester.pump(const Duration(milliseconds: 100));

    final button = find.byType(ElevatedButton).first;
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Invalid phone number or password.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
