import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/features/wallet/domain/models/wallet_balance.dart';
import 'package:king_wins_mobile_app/features/wallet/presentation/states/wallet_state.dart';

void main() {
  group('WalletBalance Model & Parsing Tests', () {
    test('parses integer balance correctly', () {
      final json = {'wallet_balance': 58850, 'currency': 'INR'};
      final balance = WalletBalance.fromJson(json);

      expect(balance.availableBalance, equals(58850));
      expect(balance.formattedBalance, equals('58850'));
      expect(balance.currencyCode, equals('INR'));
    });

    test('parses decimal string balance safely without double inaccuracies',
        () {
      final json = {'points': '1250.75'};
      final balance = WalletBalance.fromJson(json);

      expect(balance.availableBalance, equals(1250));
      expect(balance.formattedBalance, equals('1250'));
    });

    test('handles zero and missing balance fields gracefully', () {
      final balance = WalletBalance.fromJson({});

      expect(balance.availableBalance, equals(0));
      expect(balance.formattedBalance, equals('0'));
    });

    test('handles null and malformed balance fields without crashing', () {
      final json = {'balance': null, 'locked_balance': 'abc'};
      final balance = WalletBalance.fromJson(json);

      expect(balance.availableBalance, equals(0));
      expect(balance.lockedBalance, equals(0));
    });
  });

  group('WalletState Tests', () {
    test('initial state defaults to 0 balance', () {
      const state = WalletState();
      expect(state.status, equals(WalletStatus.initial));
      expect(state.displayBalance, equals(0));
      expect(state.formattedBalance, equals('0'));
      expect(state.isLoading, isFalse);
    });

    test('loaded state displays dynamic balance correctly', () {
      const balance = WalletBalance(availableBalance: 25000);
      final state = const WalletState().copyWith(
        status: WalletStatus.loaded,
        balance: balance,
      );

      expect(state.isLoaded, isTrue);
      expect(state.displayBalance, equals(25000));
      expect(state.formattedBalance, equals('25000'));
    });

    test('retains previous balance during error state', () {
      const initialBalance = WalletBalance(availableBalance: 1000);
      final state = WalletState(
        status: WalletStatus.error,
        balance: initialBalance,
        errorMessage: 'Network timeout',
      );

      expect(state.displayBalance, equals(1000));
      expect(state.errorMessage, equals('Network timeout'));
    });
  });
}
