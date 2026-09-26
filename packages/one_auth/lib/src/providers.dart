import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_auth/src/authenticator.dart';
import 'package:one_auth/src/one_auth_config.dart';
import 'package:one_auth/src/session.dart';
import 'package:one_auth/src/token_store.dart';

/// The app's One ID client configuration. Apps must override this:
///
/// ```dart
/// ProviderScope(overrides: [oneAuthConfigProvider.overrideWithValue(cfg)])
/// ```
final oneAuthConfigProvider = Provider<OneAuthConfig>(
  (ref) => throw UnimplementedError(
    'Override oneAuthConfigProvider in the app ProviderScope.',
  ),
  name: 'oneAuthConfig',
);

/// Where tokens are kept (secure storage by default).
final tokenStoreProvider = Provider<TokenStore>(
  (ref) => const SecureTokenStore(),
  name: 'tokenStore',
);

/// The One ID client (AppAuth by default).
final authenticatorProvider = Provider<OneAuthenticator>(
  (ref) => AppAuthAuthenticator(ref.watch(oneAuthConfigProvider)),
  name: 'authenticator',
);

/// The current session. Watch it to react to sign-in and sign-out.
final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
  name: 'session',
);
