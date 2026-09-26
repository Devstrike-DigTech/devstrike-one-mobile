import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:one_core/src/config/one_flavor.dart';

/// Runtime configuration for a One app, resolved once at start-up.
///
/// Values come from compile-time defines so no secret or host name is baked
/// into source:
///
/// ```sh
/// flutter run --flavor staging --dart-define-from-file=config/staging.json
/// ```
///
/// | define             | meaning                                   |
/// |--------------------|-------------------------------------------|
/// | `ONE_FLAVOR`       | `staging` or `production`                 |
/// | `ONE_API_BASE_URL` | origin of core-api, e.g. `https://...`    |
/// | `ONE_OIDC_ISSUER`  | One ID issuer, normally `<api>/oidc`      |
///
/// When `ONE_API_BASE_URL` is absent (a plain `flutter run`), the local
/// core-api on port 4100 is used: `10.0.2.2` from the Android emulator,
/// `localhost` everywhere else (iOS simulator, desktop, tests).
@immutable
class OneConfig {
  /// Creates a configuration. Prefer [OneConfig.fromEnvironment].
  const OneConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.oidcIssuer,
    this.appName = 'One',
  });

  /// Reads the compile-time defines described on [OneConfig].
  ///
  /// [platform] decides the local fallback host; it defaults to the platform
  /// the app is running on.
  factory OneConfig.fromEnvironment({
    String appName = 'One',
    TargetPlatform? platform,
  }) {
    const flavorDefine = String.fromEnvironment('ONE_FLAVOR');
    const apiDefine = String.fromEnvironment('ONE_API_BASE_URL');
    const issuerDefine = String.fromEnvironment('ONE_OIDC_ISSUER');
    return OneConfig.resolve(
      appName: appName,
      flavor: flavorDefine.isEmpty ? appFlavor : flavorDefine,
      apiBaseUrl: apiDefine,
      oidcIssuer: issuerDefine,
      platform: platform ?? defaultTargetPlatform,
    );
  }

  /// Resolves raw strings into a configuration; exposed for tests.
  @visibleForTesting
  factory OneConfig.resolve({
    required TargetPlatform platform,
    String appName = 'One',
    String? flavor,
    String? apiBaseUrl,
    String? oidcIssuer,
  }) {
    final api = (apiBaseUrl == null || apiBaseUrl.isEmpty)
        ? localApiOrigin(platform)
        : _parseOrigin(apiBaseUrl, 'ONE_API_BASE_URL');
    final issuer = (oidcIssuer == null || oidcIssuer.isEmpty)
        ? api.replace(path: '/oidc')
        : _parseOrigin(oidcIssuer, 'ONE_OIDC_ISSUER');
    return OneConfig(
      appName: appName,
      flavor: OneFlavor.parse(flavor),
      apiBaseUrl: api,
      oidcIssuer: issuer,
    );
  }

  /// The local core-api origin as seen from [platform].
  static Uri localApiOrigin(TargetPlatform platform) {
    final host = platform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
    return Uri(scheme: 'http', host: host, port: localApiPort);
  }

  /// Port core-api listens on in local development.
  static const int localApiPort = 4100;

  static Uri _parseOrigin(String raw, String name) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(raw, name, 'must be an absolute http(s) URL');
    }
    // Drop a trailing slash so paths can be appended predictably.
    final path = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return uri.replace(path: path);
  }

  /// Display name of the app (used in titles and the About section).
  final String appName;

  /// The build flavour.
  final OneFlavor flavor;

  /// Origin of core-api, without a trailing slash.
  final Uri apiBaseUrl;

  /// One ID OpenID Connect issuer.
  final Uri oidcIssuer;

  /// Whether the API is reached over plain HTTP (local development only).
  bool get isInsecure => apiBaseUrl.scheme == 'http';

  @override
  bool operator ==(Object other) =>
      other is OneConfig &&
      other.appName == appName &&
      other.flavor == flavor &&
      other.apiBaseUrl == apiBaseUrl &&
      other.oidcIssuer == oidcIssuer;

  @override
  int get hashCode => Object.hash(appName, flavor, apiBaseUrl, oidcIssuer);

  @override
  String toString() =>
      'OneConfig($appName, ${flavor.name}, api: $apiBaseUrl, '
      'issuer: $oidcIssuer)';
}
