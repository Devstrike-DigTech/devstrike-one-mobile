/// Every core-api path this client calls, in one place so a route change
/// in core-api is a one-line change here.
abstract final class OneApiPaths {
  /// Liveness and dependency status (outside the `/api/v1` prefix, like the
  /// worker's `/health`).
  static const String health = '/health';

  /// Marketplace full-text search over listings.
  static const String marketplaceSearch = '/api/v1/marketplace/search';

  /// One listing by its One id.
  static String marketplaceListing(String id) =>
      '/api/v1/marketplace/listings/${Uri.encodeComponent(id)}';
}
