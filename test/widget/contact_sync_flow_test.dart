import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/core/config/app_config.dart';
import 'package:king_wins_mobile_app/features/contact_sync/presentation/widgets/contact_disclosure.dart';
import 'package:king_wins_mobile_app/features/contact_sync/domain/entities/device_contact.dart';
import 'package:king_wins_mobile_app/features/contact_sync/domain/entities/contact_phone.dart';
import 'package:king_wins_mobile_app/features/contact_sync/domain/entities/contact_sync_result.dart';
import 'package:king_wins_mobile_app/features/contact_sync/domain/entities/contact_sync_consent.dart';
import 'package:king_wins_mobile_app/features/contact_sync/domain/repositories/contact_sync_repository.dart';

class MockContactSyncRepository implements ContactSyncRepository {
  final bool shouldFailUpload;

  MockContactSyncRepository({
    this.shouldFailUpload = false,
  });

  @override
  Future<ContactSyncResult> syncContacts(List<DeviceContact> contacts) async {
    if (shouldFailUpload) {
      throw Exception(
          'Contact upload backend service is currently not available.');
    }
    return ContactSyncResult.success(contacts.length);
  }

  @override
  Future<void> deleteSyncedContacts() async {}

  @override
  Future<ContactSyncConsent> getConsentStatus({required int userId}) async {
    return ContactSyncConsent(
      userId: userId,
      purpose: 'Contact sync',
      status: ContactConsentStatus.accepted,
    );
  }

  @override
  Future<void> updateConsentStatus({
    required int userId,
    required ContactConsentStatus status,
  }) async {}
}

void main() {
  setUpAll(() {
    AppConfig.initialize();
  });

  testWidgets(
      'Contact disclosure handles Continue, Not now, and Privacy clicks',
      (WidgetTester tester) async {
    bool continued = false;
    bool skipped = false;
    bool privacyClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ContactDisclosure(
              onContinue: () => continued = true,
              onNotNow: () => skipped = true,
              onPrivacyPolicy: () => privacyClicked = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sync your contacts?'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.text('View Privacy Policy'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    expect(continued, isTrue);

    await tester.tap(find.text('Not now'));
    expect(skipped, isTrue);

    await tester.tap(find.text('View Privacy Policy'));
    expect(privacyClicked, isTrue);
  });

  testWidgets('Mock ContactSyncRepository processes sync successfully',
      (WidgetTester tester) async {
    final repo = MockContactSyncRepository();
    final contacts = [
      const DeviceContact(
        id: '1',
        displayName: 'Alice Test',
        phones: [
          ContactPhone(
              rawNumber: '+919876543210', normalizedNumber: '+919876543210')
        ],
      ),
    ];
    final result = await repo.syncContacts(contacts);
    expect(result.syncedCount, 1);
    expect(result.isSuccess, isTrue);
  });

  testWidgets('Mock ContactSyncRepository handles upload failure gracefully',
      (WidgetTester tester) async {
    final repo = MockContactSyncRepository(shouldFailUpload: true);
    final contacts = [
      const DeviceContact(
        id: '1',
        displayName: 'Alice Test',
        phones: [
          ContactPhone(
              rawNumber: '+919876543210', normalizedNumber: '+919876543210')
        ],
      ),
    ];
    expect(() => repo.syncContacts(contacts), throwsException);
  });
}
