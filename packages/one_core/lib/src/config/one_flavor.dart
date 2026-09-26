/// The build flavour an app was compiled for.
///
/// Android builds carry it as a Gradle product flavour (`--flavor staging`),
/// and every build also receives it as `--dart-define=ONE_FLAVOR=...` (see
/// `config/*.json` at the workspace root).
enum OneFlavor {
  /// Internal testing against the staging One core API.
  staging,

  /// The store build, against the production One core API.
  production;

  /// Parses a flavour name, falling back to [staging] for anything unknown so
  /// a mis-typed define can never point a debug build at production.
  static OneFlavor parse(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'production' || 'prod' => OneFlavor.production,
      _ => OneFlavor.staging,
    };
  }

  /// Whether this is the production flavour.
  bool get isProduction => this == OneFlavor.production;
}
