import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_app/app/app.dart';
import 'package:one_app/app/providers.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Public OIDC client registered for this app in One ID.
const String oneAppClientId = String.fromEnvironment(
  'ONE_OIDC_CLIENT_ID',
  defaultValue: 'one-app',
);

/// Private-use URI scheme for OIDC redirects; the Android manifest
/// placeholder and the iOS URL type must match it (per flavour).
String redirectSchemeFor(OneFlavor flavor) =>
    flavor.isProduction ? 'ng.devstrike.one' : 'ng.devstrike.one.staging';

/// Starts the app with [config].
Future<void> bootstrap(OneConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  OneLog.init();
  final log = Logger('one_app')..info('Starting $config');

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(prefs),
        oneAuthConfigProvider.overrideWithValue(
          OneAuthConfig.forApp(
            config: config,
            clientId: oneAppClientId,
            redirectScheme: redirectSchemeFor(config.flavor),
            scopes: OneAuthConfig.customerScopes,
          ),
        ),
      ],
      observers: [_ProviderLogger(log)],
      child: const OneApp(),
    ),
  );
}

final class _ProviderLogger extends ProviderObserver {
  _ProviderLogger(this._log);

  final Logger _log;

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _log.warning(
      '${context.provider.name ?? context.provider.runtimeType} failed',
      error,
      stackTrace,
    );
  }
}
