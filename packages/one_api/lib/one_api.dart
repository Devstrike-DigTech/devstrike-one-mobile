/// Typed client for the Devstrike One core API.
///
/// Hand-written for One-0 (health, marketplace search, listing detail) with
/// models that follow the One Listing v1 contract
/// (`devstrike-one/packages/contracts/schemas/one-listing.json`). Once
/// core-api publishes its OpenAPI document this package is replaced by
/// `openapi-generator` output behind the same `OneApiClient` facade; see
/// README.md.
library;

export 'src/api_paths.dart';
export 'src/models/health_status.dart';
export 'src/models/listing.dart';
export 'src/models/listing_page.dart';
export 'src/models/listing_query.dart';
export 'src/models/store.dart';
export 'src/one_api_client.dart';
