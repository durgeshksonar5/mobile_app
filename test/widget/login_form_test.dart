import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/widgets/phone_input.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/widgets/password_input.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/widgets/login_button.dart';

void main() {
  testWidgets('PhoneInput and PasswordInput render and trigger callbacks',
      (WidgetTester tester) async {
    final phoneController = TextEditingController();
    final pwdController = TextEditingController();
    String phoneVal = '';
    String pwdVal = '';
    bool buttonPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PhoneInput(
                controller: phoneController,
                onChanged: (val) => phoneVal = val,
              ),
              PasswordInput(
                controller: pwdController,
                onChanged: (val) => pwdVal = val,
              ),
              LoginButton(
                onPressed: () => buttonPressed = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login Account'), findsOneWidget);

    await tester.enterText(find.byType(PhoneInput), '9876543210');
    expect(phoneVal, '9876543210');

    await tester.enterText(find.byType(PasswordInput), 'secret123');
    expect(pwdVal, 'secret123');

    await tester.tap(find.byType(LoginButton));
    expect(buttonPressed, isTrue);
  });
}
