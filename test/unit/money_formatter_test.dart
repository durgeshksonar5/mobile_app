import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/core/utils/money_formatter.dart';

void main() {
  group('MoneyFormatter Unit Tests', () {
    test('toPaise converts rupees correctly without float rounding errors', () {
      expect(MoneyFormatter.toPaise(100), equals(10000));
      expect(MoneyFormatter.toPaise(50.5), equals(5050));
      expect(MoneyFormatter.toPaise('500'), equals(50000));
    });

    test('formatRupees formats integer values into Indian currency string', () {
      expect(MoneyFormatter.formatRupees(1000), equals('₹1,000'));
      expect(MoneyFormatter.formatRupees(500, includeSymbol: false),
          equals('500'));
    });
  });
}
