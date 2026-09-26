import 'package:clock/clock.dart';

export 'package:clock/clock.dart' show Clock, clock, withClock;

/// Time helpers. Code that needs "now" reads the zone-scoped [clock] from
/// `package:clock`, so tests can freeze time with `withClock(Clock.fixed(t), ...)`.
abstract final class OneTime {
  /// The current time in UTC.
  static DateTime nowUtc() => clock.now().toUtc();

  /// Whether [instant] is within [margin] of now or already past; used for
  /// refreshing tokens a little before they expire.
  static bool isExpiring(
    DateTime instant, {
    Duration margin = const Duration(seconds: 60),
  }) => !nowUtc().add(margin).isBefore(instant.toUtc());
}
