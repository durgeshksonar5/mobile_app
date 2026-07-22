import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/core/utils/panna_generator.dart';

void main() {
  group('PannaGenerator Unit Tests', () {
    test('sortPanna sorts digits in ascending Satta order', () {
      expect(PannaGenerator.sortPanna('321'), equals('123'));
      expect(PannaGenerator.sortPanna('051'), equals('150'));
    });

    test('getFamilyPannas generates 8 unique family pannas for distinct digits',
        () {
      final family = PannaGenerator.getFamilyPannas('123');
      expect(family.length, equals(8));
      expect(family, contains('123'));
    });

    test('generatePannas creates valid single, double, and triple pannas', () {
      final singlePannas = PannaGenerator.generatePannas('single-panna');
      final doublePannas = PannaGenerator.generatePannas('double-panna');
      final triplePannas = PannaGenerator.generatePannas('triple-panna');

      expect(singlePannas.values.expand((e) => e).length, equals(120));
      expect(doublePannas.values.expand((e) => e).length, equals(90));
      expect(triplePannas.values.expand((e) => e).length, equals(10));
    });

    test(
        'getSpMotorFactor and getDpMotorFactor return correct mathematical combination counts',
        () {
      expect(PannaGenerator.getSpMotorFactor(4), equals(4));
      expect(PannaGenerator.getSpMotorFactor(5), equals(10));
      expect(PannaGenerator.getDpMotorFactor(4), equals(12));
    });
  });
}
