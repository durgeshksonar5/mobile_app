import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/features/auth/presentation/screens/login_screen.dart';
import 'package:king_wins_mobile_app/features/home/presentation/screens/home_screen.dart';

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
        const ProviderScope(
          child: MaterialApp(
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
        const ProviderScope(
          child: MaterialApp(
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
