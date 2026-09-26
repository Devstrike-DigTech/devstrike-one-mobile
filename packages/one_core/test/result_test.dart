import 'package:flutter_test/flutter_test.dart';
import 'package:one_core/one_core.dart';

void main() {
  const failure = NotFoundFailure();

  test('Ok exposes its value and maps', () {
    const Result<int> result = Ok(2);
    expect(result.isOk, isTrue);
    expect(result.valueOrNull, 2);
    expect(result.failureOrNull, isNull);
    expect(result.map((v) => v * 10), const Ok(20));
    expect(result.unwrap(), 2);
  });

  test('Err carries its failure through map and fold', () {
    const Result<int> result = Err(failure);
    expect(result.isOk, isFalse);
    expect(result.map((v) => v * 10), const Err<int>(failure));
    expect(result.fold((v) => 'ok', (f) => f.code), 'NOT_FOUND');
    expect(result.unwrap, throwsA(isA<NotFoundFailure>()));
  });

  test('failures know whether a retry can help', () {
    expect(const NetworkFailure().isRetryable, isTrue);
    expect(const TimeoutFailure().isRetryable, isTrue);
    expect(const ServerFailure(statusCode: 503).isRetryable, isTrue);
    expect(const ServerFailure(statusCode: 400).isRetryable, isFalse);
    expect(const NotFoundFailure().isRetryable, isFalse);
  });
}
