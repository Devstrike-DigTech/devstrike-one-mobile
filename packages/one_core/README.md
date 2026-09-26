# one_core

Foundations shared by every One app and package. No UI, no network.

- `OneConfig` / `OneFlavor`: flavour, core-api origin and One ID issuer from `--dart-define`s, with
  local defaults (`10.0.2.2:4100` on the Android emulator, `localhost:4100` elsewhere).
- `OneLog`: one-line set-up for `package:logging`, writing to `dart:developer` with bearer tokens,
  token fields and passwords redacted.
- `Result<T>` (`Ok` / `Err`) and the sealed `OneFailure` family (`NetworkFailure`, `TimeoutFailure`,
  `ServerFailure`, `NotFoundFailure`, `UnauthorizedFailure`, `CancelledFailure`, `UnexpectedFailure`),
  each with a message safe to show to people and an `isRetryable` flag.
- `Money`: integer minor units plus ISO 4217 currency, formatted as `₦12,500`.
- `OneTime` over `package:clock`, so tests can freeze time with `withClock`.
