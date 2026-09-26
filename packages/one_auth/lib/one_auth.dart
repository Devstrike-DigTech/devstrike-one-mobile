/// One ID sign-in for the Devstrike One apps.
///
/// OpenID Connect Authorization Code + PKCE (S256) through the system browser
/// (`flutter_appauth`), tokens in the platform keystore
/// (`flutter_secure_storage`), and a Riverpod `sessionProvider` the apps
/// watch. The access token is refreshed shortly before it expires.
library;

export 'src/authenticator.dart';
export 'src/discovery_check.dart';
export 'src/id_token_claims.dart';
export 'src/one_auth_config.dart';
export 'src/providers.dart';
export 'src/session.dart';
export 'src/token_set.dart';
export 'src/token_store.dart';
