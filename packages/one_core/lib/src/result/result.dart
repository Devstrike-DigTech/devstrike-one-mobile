import 'package:meta/meta.dart';
import 'package:one_core/src/result/one_failure.dart';

/// The outcome of an operation that can fail in an expected way.
///
/// Repositories and API clients return `Result` instead of throwing, so the
/// UI is forced to handle the failure branch:
///
/// ```dart
/// switch (await api.searchListings(query: 'Lekki')) {
///   case Ok(:final value): show(value);
///   case Err(:final failure): showError(failure.message);
/// }
/// ```
@immutable
sealed class Result<T> {
  const Result();

  /// A successful result carrying [value].
  const factory Result.ok(T value) = Ok<T>;

  /// A failed result carrying [failure].
  const factory Result.err(OneFailure failure) = Err<T>;

  /// Whether this is an [Ok].
  bool get isOk => this is Ok<T>;

  /// The value, or `null` for an [Err].
  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  /// The failure, or `null` for an [Ok].
  OneFailure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(:final failure) => failure,
  };

  /// Transforms the value of an [Ok]; failures pass through untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };

  /// Collapses both branches into one value.
  R fold<R>(R Function(T value) onOk, R Function(OneFailure failure) onErr) =>
      switch (this) {
        Ok(:final value) => onOk(value),
        Err(:final failure) => onErr(failure),
      };

  /// Returns the value or throws the failure. Use at boundaries that expect
  /// exceptions (for example a Riverpod `FutureProvider`).
  T unwrap() => switch (this) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

/// A successful [Result].
final class Ok<T> extends Result<T> {
  /// Wraps [value].
  const Ok(this.value);

  /// The value produced.
  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

/// A failed [Result].
final class Err<T> extends Result<T> {
  /// Wraps [failure].
  const Err(this.failure);

  /// Why the operation failed.
  final OneFailure failure;

  @override
  bool operator ==(Object other) => other is Err<T> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Err($failure)';
}
