import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// An amount of money in integer minor units (kobo for NGN) with its ISO 4217
/// currency, matching the One contracts. Never use `double` for money.
@immutable
class Money implements Comparable<Money> {
  /// Creates an amount of [minor] units of [currency].
  const Money(this.minor, this.currency);

  /// Naira from kobo.
  const Money.ngn(int kobo) : this(kobo, 'NGN');

  /// Amount in minor units.
  final int minor;

  /// ISO 4217 code, upper case.
  final String currency;

  static const Map<String, int> _exponents = {'JPY': 0, 'KWD': 3, 'BHD': 3};

  /// Minor-unit exponent for [currency] (2 for NGN, USD, GBP...).
  int get exponent => _exponents[currency] ?? 2;

  /// Formats for display, e.g. `₦12,500` (whole amounts drop the decimals).
  ///
  /// [locale] defaults to `en_NG`.
  String format({String locale = 'en_NG', bool compactDecimals = true}) {
    final divisor = _pow10(exponent);
    final whole = minor % divisor == 0;
    final format = NumberFormat.currency(
      locale: locale,
      name: currency,
      symbol: _symbol(currency),
      decimalDigits: (compactDecimals && whole) ? 0 : exponent,
    );
    return format.format(minor / divisor);
  }

  static int _pow10(int e) {
    var r = 1;
    for (var i = 0; i < e; i++) {
      r *= 10;
    }
    return r;
  }

  static String _symbol(String currency) => switch (currency) {
    'NGN' => '₦',
    'USD' => r'$',
    'GBP' => '£',
    'EUR' => '€',
    'GHS' => 'GH₵',
    'KES' => 'KSh',
    _ => '$currency ',
  };

  @override
  int compareTo(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Cannot compare $currency with ${other.currency}');
    }
    return minor.compareTo(other.minor);
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  @override
  String toString() => 'Money($minor $currency)';
}
