/// Pure Dart Satta Matka Panna & Motor combinations engine matching web logic.
class PannaGenerator {
  static const List<int> digitsVal = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  static int displayDigit(int val) => val == 10 ? 0 : val;

  static String sortPanna(String panna) {
    if (panna.length != 3) return panna;
    final digits =
        panna.split('').map((d) => d == '0' ? 10 : int.parse(d)).toList();
    digits.sort();
    return digits.map((d) => d == 10 ? '0' : d.toString()).join('');
  }

  static List<String> getFamilyPannas(String panna) {
    if (panna.length != 3 || int.tryParse(panna) == null) return [];
    final digits = panna.split('').map((d) => int.parse(d)).toList();
    final options = digits.map((d) => [d, (d + 5) % 10]).toList();
    final Set<String> unique = {};

    for (final d1 in options[0]) {
      for (final d2 in options[1]) {
        for (final d3 in options[2]) {
          final sorted = [d1, d2, d3].map((x) => x == 0 ? 10 : x).toList()
            ..sort();
          unique.add(sorted.map((x) => x == 10 ? '0' : x.toString()).join(''));
        }
      }
    }
    final result = unique.toList()..sort();
    return result;
  }

  static Map<int, List<String>> generatePannas(String type) {
    final Map<int, List<String>> result = {for (int i = 0; i < 10; i++) i: []};

    for (int i = 0; i < 10; i++) {
      for (int j = i; j < 10; j++) {
        for (int k = j; k < 10; k++) {
          final x = digitsVal[i];
          final y = digitsVal[j];
          final z = digitsVal[k];

          final sum = x + y + z;
          final singleDigit = sum % 10;

          final pannaStr =
              '${displayDigit(x)}${displayDigit(y)}${displayDigit(z)}';

          final isTriple = (x == y && y == z);
          final isDouble = !isTriple && (x == y || y == z || x == z);
          final isSingle = !isTriple && !isDouble;

          if (type == 'single-panna' && isSingle) {
            result[singleDigit]!.add(pannaStr);
          } else if (type == 'double-panna' && isDouble) {
            result[singleDigit]!.add(pannaStr);
          } else if (type == 'triple-panna' && isTriple) {
            result[singleDigit]!.add(pannaStr);
          }
        }
      }
    }
    return result;
  }

  static int getSpMotorFactor(int uniqueDigitsCount) {
    const factors = {4: 4, 5: 10, 6: 20, 7: 35, 8: 56, 9: 84, 10: 120};
    return factors[uniqueDigitsCount] ?? 1;
  }

  static int getDpMotorFactor(int uniqueDigitsCount) {
    const factors = {4: 12, 5: 20, 6: 30, 7: 42, 8: 56, 9: 72, 10: 90};
    return factors[uniqueDigitsCount] ?? 1;
  }

  static List<String> getSpDpTpPannas(int ank, List<String> categories) {
    final List<String> pannas = [];
    if (categories.contains('SP')) {
      final spMap = generatePannas('single-panna');
      pannas.addAll(spMap[ank] ?? []);
    }
    if (categories.contains('DP')) {
      final dpMap = generatePannas('double-panna');
      pannas.addAll(dpMap[ank] ?? []);
    }
    if (categories.contains('TP')) {
      final tpMap = generatePannas('triple-panna');
      pannas.addAll(tpMap[ank] ?? []);
    }
    return pannas;
  }
}
