import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

export 'package:logging/logging.dart' show Level, Logger;

/// Process-wide logging set-up for the One apps.
///
/// Libraries create loggers with `Logger('one_api.client')`; the app calls
/// [OneLog.init] once. Records go to `dart:developer` (visible in DevTools
/// and `flutter logs`) with secrets redacted.
abstract final class OneLog {
  static bool _initialised = false;

  /// Starts listening to the root logger. Safe to call more than once.
  ///
  /// [level] defaults to [Level.FINE] in debug builds and [Level.INFO]
  /// otherwise. [sink] replaces the default output (useful in tests).
  static void init({Level? level, void Function(LogRecord record)? sink}) {
    Logger.root.level = level ?? (kDebugMode ? Level.FINE : Level.INFO);
    if (_initialised) return;
    _initialised = true;
    Logger.root.onRecord.listen(sink ?? _write);
  }

  static void _write(LogRecord record) {
    developer.log(
      redact(record.message),
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  }

  static final RegExp _bearer = RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*');
  static final RegExp _tokenField = RegExp(
    r'("?(?:access_token|refresh_token|id_token|code_verifier|password)"?\s*[:=]\s*"?)([^"\s,}&]+)',
    caseSensitive: false,
  );

  /// Replaces bearer tokens and token-like fields with `[redacted]`.
  static String redact(String message) => message
      .replaceAll(_bearer, 'Bearer [redacted]')
      .replaceAllMapped(_tokenField, (m) => '${m[1]}[redacted]');
}
