import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/app/dependency_injection/providers.dart';
import 'package:king_wins_mobile_app/features/auth/data/repositories/auth_repository.dart';
import 'package:king_wins_mobile_app/features/auth/domain/models/user_model.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/screens/login_screen.dart';

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
  @override
  Future<String?> getLatestAppVersion() async => null;
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
    expect(find.text('Sign In'), findsNWidgets(2));
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
