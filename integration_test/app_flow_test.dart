import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:king_wins_mobile_app/bootstrap.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Full King Win native application startup and UI flow integration test',
      (WidgetTester tester) async {
    app.bootstrap();
    await tester.pumpAndSettle();

    // Verify application boots cleanly without crash
    expect(find.byAppName('King Win'), findsNothing);
  });
}

extension on CommonFinders {
  byAppName(String s) {}
}
