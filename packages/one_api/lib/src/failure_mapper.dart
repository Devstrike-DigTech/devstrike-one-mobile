import 'package:dio/dio.dart';
import 'package:one_core/one_core.dart';

/// Turns a Dio error into a [OneFailure], reading the core-api error envelope
/// `{ statusCode, code, message, details? }` when present.
OneFailure failureFromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutFailure(cause: e);
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return NetworkFailure(cause: e);
    case DioExceptionType.cancel:
      return CancelledFailure(cause: e);
    case DioExceptionType.badResponse:
      return _fromResponse(e.response, e);
    case DioExceptionType.unknown:
      return e.error is FormatException
          ? UnexpectedFailure(cause: e.error)
          : NetworkFailure(cause: e);
  }
}

OneFailure _fromResponse(Response<Object?>? response, DioException cause) {
  final status = response?.statusCode ?? 0;
  final body = response?.data;
  final envelope = body is Map<String, Object?>
      ? body
      : const <String, Object?>{};
  final code = envelope['code'] is String ? envelope['code']! as String : null;
  final message = switch (envelope['message']) {
    final String m when m.isNotEmpty => m,
    // Nest/class-validator send a list of messages for 400s.
    final List<Object?> list when list.isNotEmpty =>
      list.whereType<String>().join('. '),
    _ => null,
  };
  final details = envelope['details'] is Map<String, Object?>
      ? envelope['details']! as Map<String, Object?>
      : null;

  return switch (status) {
    401 => UnauthorizedFailure(cause: cause),
    404 => NotFoundFailure(cause: cause),
    _ when status >= 500 => ServerFailure(
      statusCode: status,
      code: code ?? 'SERVER_ERROR',
      details: details,
      cause: cause,
    ),
    _ => ServerFailure(
      statusCode: status,
      code: code ?? 'HTTP_$status',
      // Only 4xx messages are written for people; 5xx ones stay generic.
      message: message ?? 'That request could not be completed.',
      details: details,
      cause: cause,
    ),
  };
}
