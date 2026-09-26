# one_auth

One ID sign-in for the One apps.

- `OneAuthConfig.forApp(config: ..., clientId: ..., redirectScheme: ..., scopes: ...)` derives issuer,
  redirect and post-logout URIs; plain-HTTP issuers are refused in the production flavour.
- `AppAuthAuthenticator`: authorization code + PKCE (S256) with `flutter_appauth` in the system browser,
  refresh with the refresh token, RP-initiated logout (`/oidc/session/end`). AppAuth errors become
  `OneFailure`s (cancel → `CancelledFailure`, `invalid_grant` on refresh → `UnauthorizedFailure`).
- `SecureTokenStore`: `flutter_secure_storage`, iOS `first_unlock_this_device`. `InMemoryTokenStore` for tests.
- `sessionProvider` (Riverpod): `SessionRestoring` → `SignedOut` / `SigningIn` / `SignedIn`. Restores at
  launch, refreshes a token about to expire (single flight for concurrent callers), keeps the session when
  offline, signs out and clears storage when the refresh token is dead.

`discoveryProblems(config, discovery)` lists every mismatch between an app's configuration and One ID's
discovery document (issuer, endpoints, PKCE, public clients, refresh, scopes).

Apps override `oneAuthConfigProvider`; tests override `authenticatorProvider` and `tokenStoreProvider`.

ID token claims (`IdTokenClaims`) are decoded for display only; authorisation decisions belong to the API,
which validates the access token.
