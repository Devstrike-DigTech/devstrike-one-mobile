/// Every core-api path this client calls, in one place so a route change
/// in core-api is a one-line change here.
abstract final class OneApiPaths {
  /// Liveness (`{ status: "ok", role }`).
  static const String health = '/api/v1/health';

  /// Readiness: database and Redis checks.
  static const String healthReady = '/api/v1/health/ready';

  /// Marketplace full-text search over listings.
  static const String marketplaceSearch = '/api/v1/marketplace/search';

  /// One listing by its One id (a UUID; anything else is a 400).
  static String marketplaceListing(String id) =>
      '/api/v1/marketplace/listings/${Uri.encodeComponent(id)}';

  /// The signed-in person's stores across all their organisations.
  static const String myStores = '/api/v1/accounts/stores';
}
