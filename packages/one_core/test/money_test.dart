import 'package:flutter_test/flutter_test.dart';
import 'package:one_core/one_core.dart';

void main() {
  test('formats whole naira without decimals', () {
    expect(const Money.ngn(1250000).format(), '₦12,500');
  });

  test('keeps kobo when present', () {
    expect(const Money.ngn(1250050).format(), '₦12,500.50');
  });

  test('uses the currency exponent', () {
    expect(const Money(1500, 'USD').format(), r'$15');
    expect(const Money(1500, 'JPY').exponent, 0);
  });

  test('refuses to compare different currencies', () {
    expect(
      () => const Money.ngn(1).compareTo(const Money(1, 'USD')),
      throwsArgumentError,
    );
  });
}
