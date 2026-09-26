# one_api

Typed client for the Devstrike One core API, built on dio.

```dart
final api = OneApiClient(
  baseUrl: config.apiBaseUrl,
  accessToken: () => session.accessToken(), // optional
);
switch (await api.searchListings(const ListingQuery(text: 'Lekki'))) {
  case Ok(:final value): ...
  case Err(:final failure): ... // OneFailure, never an exception
}
```

| Method | Endpoint |
|---|---|
| `health()` | `GET /api/v1/health` → `{ status, role }` |
| `ready()` | `GET /api/v1/health/ready` → `{ status, checks }` (503 with `details` when a dependency is down) |
| `searchListings(ListingQuery)` | `GET /api/v1/marketplace/search?q=&category=&city=&page=&pageSize=` → `{ items, total, page, pageSize, facets: { cities, categories } }` |
| `getListing(id)` | `GET /api/v1/marketplace/listings/{id}` (a UUID) |
| `myStores()` | `GET /api/v1/accounts/stores` (bearer token) → `OneStore[]` across the person's organisations |

Products publish listings in the One Listing v1 contract
(`devstrike-one/packages/contracts/schemas/one-listing.json`); core-api's marketplace endpoints return a
projection of it, and that projection is what `Listing` reads (from
`apps/core-api/src/modules/marketplace/marketplace.service.ts`): a *card* in search results and a *detail*
from the listing endpoint. The mapping: `title` is served as `name`, the `location` object is flattened onto
the listing with `point` as `geo`, `price` becomes `priceFrom { amountMinor, currency, unit }`, and
`actions[0]` (or the product's booking page) becomes `primaryAction`. Detail adds `description`, `images`,
`actions`, `attributes`, `phone`, `whatsapp`, `productSiteUrl` and `updatedAt`.

Parsing is strict about required fields and types (a missing `name` fails with the field name) and lenient
where the contract allows growth: unknown action kinds degrade to `view`, only http(s) action URLs are
accepted, and money amounts may arrive as JSON numbers or as strings (Postgres `BIGINT`).

Errors map from the core-api envelope `{ statusCode, code, message, details? }`: 401 → `UnauthorizedFailure`,
404 → `NotFoundFailure`, other 4xx keep their `code` and message, 5xx keep a generic message and are
retryable, connection problems → `NetworkFailure`, timeouts → `TimeoutFailure`, bad shapes →
`UnexpectedFailure`.

`test/live_fixtures_test.dart` replays bodies captured from the live core-api (`test/fixtures/live/`,
with the capture commands in its README).

## Moving to generated code

This package is hand-written because One-0 core-api has three public endpoints and no OpenAPI document
yet. When core-api serves one (Nest Swagger at `/docs-json`):

1. Generate with `openapi-generator-cli generate -g dart-dio -i <core-api>/docs-json
   -o packages/one_api/lib/src/generated --additional-properties=pubName=one_api_generated`.
2. Keep `OneApiClient` as the facade: its methods call the generated API classes and still return
   `Result<T>`, so the apps do not change.
3. Replace `lib/src/models/` with the generated models (or thin extensions on them for `categoryLabel`,
   `shortLabel` and friends) and delete `lib/src/json.dart`.
4. Keep the tests in `test/`: they pin the behaviour the facade must keep.
