import 'package:meta/meta.dart';

/// An expected failure, described for both people and code.
///
/// [message] is safe to show to a customer; [code] is stable and machine
/// readable (it mirrors the core-api error envelope `code` where one exists).
@immutable
sealed class OneFailure implements Exception {
  const OneFailure({required this.code, required this.message, this.cause});

  /// Stable, machine-readable code, e.g. `NETWORK` or `NOT_FOUND`.
  final String code;

  /// A short sentence that can be shown to the person using the app.
  final String message;

  /// The underlying error, for logs only.
  final Object? cause;

  /// Whether retrying the same request may succeed.
  bool get isRetryable => false;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is OneFailure &&
      other.code == code &&
      other.message == message;

  @override
  int get hashCode => Object.hash(runtimeType, code, message);

  @override
  String toString() => 'OneFailure($code: $message)';
}

/// The device could not reach the server (offline, DNS, refused, TLS).
final class NetworkFailure extends OneFailure {
  /// Creates a network failure.
  const NetworkFailure({
    super.message =
        'You appear to be offline. Check your connection and try again.',
    super.cause,
  }) : super(code: 'NETWORK');

  @override
  bool get isRetryable => true;
}

/// The server took too long to answer.
final class TimeoutFailure extends OneFailure {
  /// Creates a timeout failure.
  const TimeoutFailure({
    super.message = 'This is taking longer than it should. Please try again.',
    super.cause,
  }) : super(code: 'TIMEOUT');

  @override
  bool get isRetryable => true;
}

/// The server answered with an error envelope
/// `{ statusCode, code, message, details? }`.
final class ServerFailure extends OneFailure {
  /// Creates a server failure.
  const ServerFailure({
    required this.statusCode,
    super.code = 'SERVER_ERROR',
    super.message =
        'Something went wrong on our side. Please try again shortly.',
    this.details,
    super.cause,
  });

  /// HTTP status code.
  final int statusCode;

  /// Optional structured details from the envelope.
  final Map<String, Object?>? details;

  @override
  bool get isRetryable => statusCode >= 500 || statusCode == 429;
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundFailure extends OneFailure {
  /// Creates a not-found failure.
  const NotFoundFailure({
    super.message = 'We could not find that. It may have been removed.',
    super.cause,
  }) : super(code: 'NOT_FOUND');
}

/// The person is not signed in, or their session has ended (HTTP 401).
final class UnauthorizedFailure extends OneFailure {
  /// Creates an unauthorised failure.
  const UnauthorizedFailure({
    super.message = 'Please sign in again to continue.',
    super.cause,
  }) : super(code: 'UNAUTHORIZED');
}

/// The person cancelled a flow (for example closed the sign-in browser).
final class CancelledFailure extends OneFailure {
  /// Creates a cancelled failure.
  const CancelledFailure({super.message = 'Cancelled.', super.cause})
    : super(code: 'CANCELLED');
}

/// The response could not be understood (contract drift or a bug).
final class UnexpectedFailure extends OneFailure {
  /// Creates an unexpected failure.
  const UnexpectedFailure({
    super.message = 'Something unexpected happened. Please try again.',
    super.code = 'UNEXPECTED',
    super.cause,
  });
}
