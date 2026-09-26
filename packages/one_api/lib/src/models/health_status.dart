import 'package:meta/meta.dart';
import 'package:one_api/src/json.dart';

/// `GET /health`: `{ "status": "ok", ... }`.
@immutable
class HealthStatus {
  /// Creates a health status.
  const HealthStatus({
    required this.status,
    this.version,
    this.details = const {},
  });

  /// Parses the response body.
  factory HealthStatus.fromJson(Json json) {
    final r = JsonReader(json);
    return HealthStatus(
      status: r.string('status'),
      version: r.stringOrNull('version'),
      details: Map.of(json)
        ..remove('status')
        ..remove('version'),
    );
  }

  /// "ok" when every dependency is healthy.
  final String status;

  /// Build or git version, when reported.
  final String? version;

  /// Anything else the endpoint reports (database, redis...).
  final Map<String, Object?> details;

  /// Whether the service reports itself healthy.
  bool get isOk => status == 'ok';
}
