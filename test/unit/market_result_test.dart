import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/features/home/domain/models/market_result.dart';

void main() {
  group('MarketResult Unit Tests', () {
    test(
        'isValueDeclared returns true for valid declared numbers and false for coming result',
        () {
      expect(MarketResult.isValueDeclared('123-45-678'), isTrue);
      expect(MarketResult.isValueDeclared('COMING OPEN'), isFalse);
      expect(MarketResult.isValueDeclared('***-**-***'), isFalse);
    });

    test('formatResultDisplay normalizes Satta Matka output strings', () {
      expect(
          MarketResult.formatResultDisplay('123-45-678'), equals('123-45-678'));
      expect(MarketResult.formatResultDisplay('123-4'), equals('123-4*-***'));
      expect(MarketResult.formatResultDisplay('COMING OPEN'),
          equals('***-**-***'));
    });

    test('getDisplayInfo accurately identifies running vs closed markets', () {
      final market = MarketResult(
        id: 1,
        marketName: 'KALYAN NIGHT',
        resultValue: '***-**-***',
        resultDate: '2026-07-21',
        openTime: '09:00 AM',
        closeTime: '11:00 PM',
      );

      final now = DateTime(2026, 7, 21, 10, 0); // 10:00 AM
      final info = market.getDisplayInfo('2026-07-21', now);

      expect(info.statusType, equals('running_close'));
      expect(info.canPlay, isTrue);
    });
  });
}
