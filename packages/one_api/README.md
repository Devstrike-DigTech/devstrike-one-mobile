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
| `health()` | `GET /health` |
| `searchListings(ListingQuery)` | `GET /api/v1/marketplace/search?q=&category=&city=&page=&pageSize=` → `{ items, total, page, pageSize }` |
| `getListing(id)` | `GET /api/v1/marketplace/listings/{id}` |

`Listing` follows the One Listing v1 contract (`devstrike-one/packages/contracts/schemas/one-listing.json`)
plus the fields One adds on ingestion (`id` as One's UUIDv7, `externalId`, `storeId`, `productName`).
Parsing is strict about required fields and types (a missing `title` fails with the field name) and
lenient where the contract allows growth: unknown action kinds degrade to `view`, unknown statuses to
`hidden`, and money amounts may arrive as JSON numbers or as strings (Postgres `BIGINT`).

Errors map from the core-api envelope `{ statusCode, code, message, details? }`: 401 → `UnauthorizedFailure`,
404 → `NotFoundFailure`, other 4xx keep their `code` and message, 5xx keep a generic message and are
retryable, connection problems → `NetworkFailure`, timeouts → `TimeoutFailure`, bad shapes →
`UnexpectedFailure`.

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
