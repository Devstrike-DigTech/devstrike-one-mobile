import 'package:meta/meta.dart';
import 'package:one_api/src/json.dart';

/// `GET /api/v1/health` (`{ status, role }`) or `GET /api/v1/health/ready`
/// (`{ status, checks: { database, platformDatabase, redis } }`).
@immutable
class HealthStatus {
  /// Creates a health status.
  const HealthStatus({required this.status, this.role, this.checks = const {}});

  /// Parses either body.
  factory HealthStatus.fromJson(Json json) {
    final r = JsonReader(json);
    final checks = r.objectOrNull('checks') ?? const <String, Object?>{};
    return HealthStatus(
      status: r.string('status'),
      role: r.stringOrNull('role'),
      checks: {
        for (final MapEntry(:key, :value) in checks.entries)
          if (value is String) key: value,
      },
    );
  }

  /// "ok" when the service is up.
  final String status;

  /// Which process answered (`api` or `worker`).
  final String? role;

  /// Readiness checks by dependency (`ok` or `down`).
  final Map<String, String> checks;

  /// Whether the service reports itself healthy.
  bool get isOk => status == 'ok' && checks.values.every((v) => v == 'ok');
}
