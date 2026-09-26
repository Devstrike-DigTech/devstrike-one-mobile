# Devstrike One — mobile

The Flutter workspace for **Devstrike One**, the shared business platform of Devstrike Digital Limited.
Two apps and four shared packages, one Dart pub workspace, orchestrated with melos.

| Path | What it is |
|---|---|
| `apps/one_app` | **One**, the customer app: marketplace search across every Devstrike product, listing detail, "Continue on HotelOS" hand-off, One ID sign-in, settings |
| `apps/one_business` | **One Business**, the owner app: One ID sign-in, store switcher, dashboard, Inbox / Books / Insights (honest "coming in One-x" states for now) |
| `packages/one_core` | Flavours and `OneConfig` (from `--dart-define`), logging with secret redaction, `Result` / `OneFailure`, `Money` (integer minor units), clock |
| `packages/one_ui` | The **Devstrike One: Aso-oke** design system: tokens generated from the TypeScript repo, light and dark `ThemeData`, Newsreader / Public Sans / Martian Mono, curated Phosphor icons, the woven-band motif, core components |
| `packages/one_api` | Typed core-api client (dio): health, marketplace search, listing detail, models following the One Listing v1 contract |
| `packages/one_auth` | One ID: OIDC authorization code + PKCE through the system browser (`flutter_appauth`), tokens in the keystore (`flutter_secure_storage`), a Riverpod session with single-flight refresh |
| `tool/sync_tokens.dart` | Regenerates `one_ui` tokens from `devstrike-one/packages/design-tokens/tokens.json` |
| `config/*.json` | Per-flavour `--dart-define-from-file` values |

The TypeScript monorepo (`devstrike-one`: core-api, web apps, contracts, design tokens) lives next to this
repository in `business-os/`. The two repositories share contracts and tokens, never code.

---

## Setup

Flutter is pinned with [FVM](https://fvm.app) in `.fvmrc` (currently **3.47.5**, Dart 3.13).

```sh
dart pub global activate fvm
fvm install                       # reads .fvmrc
fvm flutter pub get               # one resolution for the whole workspace (root pubspec.lock)
fvm dart run melos list           # apps and packages melos sees
```

Without FVM, any Flutter 3.47.x on your `PATH` works; drop the `fvm` prefix. melos is a dev dependency of
the workspace root, so `dart run melos ...` needs no global install. If you want melos to use the FVM SDK
explicitly, export `MELOS_SDK_PATH=.fvm/flutter_sdk`.

Android builds need the Android SDK and JDK 17 or newer; iOS builds need Xcode on macOS.

## Everyday commands

```sh
dart run melos run analyze        # flutter analyze in every member, infos and warnings fail
dart run melos run test           # unit, widget and golden tests everywhere
dart run melos run format         # dart format .
dart run melos run tokens:check   # fail if one_ui tokens are stale
dart run melos run build:apk:debug
```

Or per member, from its folder: `flutter test`, `flutter analyze`.

## Running the apps

core-api (from `devstrike-one`) listens on port 4100 locally, with One ID at `/oidc`.

```sh
cd apps/one_app

# Android emulator against local core-api (10.0.2.2 is the host machine):
flutter run --flavor staging --dart-define-from-file=../../config/development.example.json

# iOS simulator against local core-api (no --flavor on iOS yet, see below):
flutter run --dart-define=ONE_FLAVOR=staging

# Staging / production servers:
flutter run --flavor staging    --dart-define-from-file=../../config/staging.json
flutter run --flavor production --dart-define-from-file=../../config/production.json
```

With no `ONE_API_BASE_URL` at all the apps pick the local core-api automatically: `http://10.0.2.2:4100` on
Android, `http://localhost:4100` elsewhere. The One ID issuer defaults to `<api>/oidc`.

| define | meaning |
|---|---|
| `ONE_FLAVOR` | `staging` or `production` (anything else is treated as staging) |
| `ONE_API_BASE_URL` | core-api origin, no trailing slash |
| `ONE_OIDC_ISSUER` | One ID issuer; defaults to `<ONE_API_BASE_URL>/oidc` |
| `ONE_OIDC_CLIENT_ID` | public client id; defaults to `one-app` / `one-business` |

`config/development.example.json` is the local template; copy it to `config/<name>.local.json` for your own
machine (ignored by git). The hosts in `config/production.json` are the placeholders of
`devstrike-one/docs/adr/0015-hosts-and-domains.md` (`api.devstrike.one`, `id.devstrike.one`); the
`staging.` hosts follow the same pattern and are equally provisional.

### Flavours

| Flavour | Android application id | OIDC redirect scheme | Launcher name |
|---|---|---|---|
| staging | `ng.devstrike.one.staging`, `ng.devstrike.one.business.staging` | `<application id>:/oauthredirect` | One Staging, One Business Staging |
| production | `ng.devstrike.one`, `ng.devstrike.one.business` | `<application id>:/oauthredirect` | One, One Business |

Android flavours are Gradle product flavours (`--flavor`), each with its own application id so both
can be installed side by side, and its own `appAuthRedirectScheme`. Debug builds allow cleartext HTTP to
`10.0.2.2` and `localhost` only (`src/debug/res/xml/network_security_config.xml`); release builds never do.

iOS has a single scheme for now: the flavour comes from `--dart-define` alone, and ATS allows only local
networking. Xcode schemes and configurations per flavour are an open item.

## One ID sign-in

Both apps are public OIDC clients of One ID (core-api `/oidc`, the `oidc-provider` library), using
authorization code + PKCE (S256) in the system browser (Custom Tabs / `ASWebAuthenticationSession`).

| App | client id | scopes | redirect URIs to register |
|---|---|---|---|
| One | `one-app` | `openid profile email phone offline_access one:customer` | `ng.devstrike.one[.staging]:/oauthredirect`, post-logout `...:/logout` |
| One Business | `one-business` | `openid profile email phone offline_access one:orgs` | `ng.devstrike.one.business[.staging]:/oauthredirect`, post-logout `...:/logout` |

Plain-HTTP issuers are accepted only outside the production flavour (`OneAuthConfig.forApp` throws
otherwise). Tokens are stored under `first_unlock_this_device` on iOS and in the Keystore-backed store on
Android; nothing token-shaped is ever logged (`OneLog.redact`, `TokenSet.toString`).

## Design tokens

`packages/one_ui/lib/src/tokens/one_tokens.g.dart` is generated; never edit it. The source of truth is
`devstrike-one/packages/design-tokens/tokens.json` ("Devstrike One: Aso-oke").

```sh
dart run tool/sync_tokens.dart                     # reads ../devstrike-one/... (sibling checkout)
dart run tool/sync_tokens.dart --source path/to/tokens.json
ONE_TOKENS_PATH=path/to/tokens.json dart run tool/sync_tokens.dart
dart run tool/sync_tokens.dart --check             # CI: fail if stale
```

The script copies the JSON to `packages/one_ui/tokens/tokens.json` (so this repository builds without the
TypeScript one, and a token change is a reviewable diff here), then writes the Dart file. It reads the
JSON, not the `one_tokens.dart` the TypeScript package also emits: the JSON is the contract, and the
Flutter-side shape (`Color` constants a `ThemeExtension` can use) is ours. After a sync, run
`dart run melos run test:goldens:update` and look at the golden images before committing.

### Fonts and icons

- Newsreader (display), Public Sans (interface) and Martian Mono (numbers) come from `google_fonts`,
  fetched once and cached. Martian Mono has no naira sign, so mono styles fall back to Public Sans for
  `₦`. Bundling the font files for offline first launch is an open item.
- Icons are Phosphor 2.1, with the regular and fill font files vendored in `packages/one_ui/fonts`
  (MIT). `phosphor_flutter` 2.1.0 no longer compiles on current Flutter (it extends `IconData`, now a
  `final` class), so `OneIcons` carries the curated set. To add an icon, add its code point there.

## API client

`one_api` is hand-written for the three endpoints that exist in One-0 (`GET /health`,
`GET /api/v1/marketplace/search`, `GET /api/v1/marketplace/listings/{id}`). All paths live in
`OneApiPaths`. When core-api publishes its OpenAPI document, the plan is to generate the models and
endpoints with `openapi-generator` (`dart-dio` generator) into `packages/one_api/lib/src/generated/`,
keep `OneApiClient` as the facade the apps use (so screens do not change), and delete the hand-written
models. See `packages/one_api/README.md`.

## Tests

- `one_core`, `one_api`, `one_auth`: unit tests (config resolution, money, redaction, JSON parsing and
  contract drift, error envelope mapping with a mock Dio adapter, session restore, refresh, sign-out).
- `one_ui`: widget tests, WCAG AA contrast checks on the generated palette, and goldens (light and dark)
  in `test/goldens/`. Goldens render with the test font, so they check layout, colour and the motif rather
  than typography; they are recorded on Linux, which CI also uses.
- Apps: widget tests that pump the whole app (router, theme, providers) with fakes only at the edges
  (HTTP adapter, One ID, token store, preferences, URL launcher).

`test/flutter_test_config.dart` in each member calls `setUpOneUiForTests()`, which turns off network font
fetching and loads the Phosphor fonts.

## CI

`.github/workflows/ci.yml`: format check, token staleness check, `dart analyze tool`, `melos run analyze`,
`melos run test`, then a debug APK of each app (staging flavour) uploaded as an artifact. The Flutter
version is read from `.fvmrc`.

## Open items

- iOS flavour schemes; release signing (Play upload key, App Store certificates); app icons (the
  Flutter defaults are still in place).
- Bundled font files for offline first launch.
- Store list for One Business arrives with the One-1 accounts API.
- Replace the hand-written API client with generated code once core-api serves OpenAPI.

---

Proprietary — Devstrike Digital Limited. See `LICENSE`.
