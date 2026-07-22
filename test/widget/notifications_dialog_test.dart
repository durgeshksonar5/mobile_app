import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/app_notification.dart';
import 'package:king_wins_mobile_app/features/home/presentation/widgets/notifications_dialog.dart';

void main() {
  setUpAll(() {
    AppConfig.initialize();
  });

  testWidgets(
      'NotificationsDialog renders title, category chips and notification items',
      (WidgetTester tester) async {
    final sampleNotifications = AppNotification.getInitialSampleNotifications();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationsDialog(
            notifications: sampleNotifications,
            onNotificationsUpdated: (list) {},
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify header and new badge
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.textContaining('NEW'), findsOneWidget);

    // Verify notification sample items
    expect(find.text('Welcome to King Win App! 👑'), findsOneWidget);
    expect(find.text('KALYAN BAZAR Result Declared 🎯'), findsOneWidget);

    // Verify category chips
    expect(find.textContaining('All ('), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('System Alerts'), findsOneWidget);
  });

  testWidgets(
      'NotificationsDialog Mark Read and Clear All buttons function correctly',
      (WidgetTester tester) async {
    final sampleNotifications = AppNotification.getInitialSampleNotifications();
    List<AppNotification> updatedNotifications = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationsDialog(
            notifications: sampleNotifications,
            onNotificationsUpdated: (list) {
              updatedNotifications = list;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    // Tap Mark Read
    final markReadButton = find.text('Mark Read');
    expect(markReadButton, findsOneWidget);
    await tester.tap(markReadButton);
    await tester.pump();

    expect(updatedNotifications.every((n) => n.isRead), isTrue);

    // Tap Clear All
    final clearAllButton = find.text('Clear All');
    expect(clearAllButton, findsOneWidget);
    await tester.tap(clearAllButton);
    await tester.pump();

    expect(find.text('No notifications found'), findsOneWidget);
    expect(updatedNotifications.isEmpty, isTrue);
  });
}
