import 'package:flutter_test/flutter_test.dart';
import 'package:one_core/one_core.dart';

void main() {
  test('isExpiring respects the margin under a fixed clock', () {
    final now = DateTime.utc(2026, 9, 26, 12);
    withClock(Clock.fixed(now), () {
      expect(OneTime.nowUtc(), now);
      expect(OneTime.isExpiring(now.add(const Duration(seconds: 30))), isTrue);
      expect(OneTime.isExpiring(now.add(const Duration(minutes: 5))), isFalse);
      expect(
        OneTime.isExpiring(now.subtract(const Duration(minutes: 1))),
        isTrue,
      );
    });
  });
}
