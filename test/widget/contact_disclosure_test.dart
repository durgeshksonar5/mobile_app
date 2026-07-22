import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/features/contact_sync/presentation/widgets/contact_disclosure.dart';

void main() {
  setUp(() {
    AppConfig.initialize();
  });

  testWidgets('ContactDisclosure renders title, purpose, and buttons',
      (WidgetTester tester) async {
    bool continued = false;
    bool skipped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContactDisclosure(
            onContinue: () => continued = true,
            onNotNow: () => skipped = true,
            onPrivacyPolicy: () {},
          ),
        ),
      ),
    );

    expect(find.text('Sync your contacts?'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.text('View Privacy Policy'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    expect(continued, isTrue);

    await tester.tap(find.text('Not now'));
    expect(skipped, isTrue);
  });
}
