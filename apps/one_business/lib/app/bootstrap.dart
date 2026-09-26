import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_business/app/app.dart';
import 'package:one_business/app/providers.dart';
import 'package:one_core/one_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Public OIDC client registered for this app in One ID.
const String oneBusinessClientId = String.fromEnvironment(
  'ONE_OIDC_CLIENT_ID',
  defaultValue: 'one-business',
);

/// Private-use URI scheme for OIDC redirects (must match the Android
/// manifest placeholder of the flavour).
String redirectSchemeFor(OneFlavor flavor) => flavor.isProduction
    ? 'ng.devstrike.one.business'
    : 'ng.devstrike.one.business.staging';

/// Starts the app with [config].
Future<void> bootstrap(OneConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  OneLog.init();
  Logger('one_business').info('Starting $config');
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(prefs),
        oneAuthConfigProvider.overrideWithValue(
          OneAuthConfig.forApp(
            config: config,
            clientId: oneBusinessClientId,
            redirectScheme: redirectSchemeFor(config.flavor),
            scopes: OneAuthConfig.businessScopes,
          ),
        ),
        tokenStoreProvider.overrideWithValue(
          const SecureTokenStore(key: 'one.business.session.tokens'),
        ),
      ],
      child: const OneBusinessApp(),
    ),
  );
}
