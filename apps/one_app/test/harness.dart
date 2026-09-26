import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:one_api/one_api.dart';
import 'package:one_app/app/app.dart';
import 'package:one_app/app/providers.dart';
import 'package:one_app/features/splash/splash_screen.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

final OneConfig testConfig = OneConfig(
  flavor: OneFlavor.staging,
  apiBaseUrl: Uri.parse('http://localhost:4100'),
  oidcIssuer: Uri.parse('http://localhost:4100/oidc'),
);

/// Everything a test can poke at after [pumpOneApp].
class AppHarness {
  AppHarness({
    required this.api,
    required this.auth,
    required this.store,
    required this.opened,
  });

  /// Mock HTTP adapter behind the real `OneApiClient`.
  final DioAdapter api;

  /// Fake One ID.
  final FakeAuthenticator auth;

  /// In-memory token store.
  final InMemoryTokenStore store;

  /// URLs the app tried to open outside itself.
  final List<Uri> opened;
}

/// Pumps the whole app (router, theme, providers) with fakes at the edges:
/// HTTP, One ID, token storage, preferences and the URL launcher.
Future<AppHarness> pumpOneApp(
  WidgetTester tester, {
  bool onboardingSeen = true,
  void Function(DioAdapter api)? routes,
  TokenSet? storedTokens,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    if (onboardingSeen) 'one.onboarding.v1': true,
  });
  final prefs = await SharedPreferences.getInstance();

  final dio = Dio();
  final adapter = DioAdapter(dio: dio);
  routes?.call(adapter);
  final auth = FakeAuthenticator();
  final store = InMemoryTokenStore(storedTokens);
  final opened = <Uri>[];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(testConfig),
        sharedPreferencesProvider.overrideWithValue(prefs),
        authenticatorProvider.overrideWithValue(auth),
        tokenStoreProvider.overrideWithValue(store),
        externalUrlOpenerProvider.overrideWithValue((url) async {
          opened.add(url);
          return true;
        }),
        apiClientProvider.overrideWith(
          (ref) => OneApiClient(
            baseUrl: testConfig.apiBaseUrl,
            dio: dio,
            accessToken: () => ref.read(sessionProvider.notifier).accessToken(),
          ),
        ),
      ],
      child: const OneApp(),
    ),
  );
  // Let the splash weave and hand over.
  await tester.pump(SplashScreen.weave);
  await tester.pumpAndSettle();
  return AppHarness(api: adapter, auth: auth, store: store, opened: opened);
}

/// Registers a search response for [text] (empty = browse).
void onSearch(
  DioAdapter api,
  List<Map<String, Object?>> items, {
  String text = '',
}) {
  api.onGet(
    OneApiPaths.marketplaceSearch,
    (s) => s.reply(200, {
      'items': items,
      'total': items.length,
      'page': 1,
      'pageSize': 20,
    }),
    queryParameters: {
      if (text.isNotEmpty) 'q': text,
      'page': 1,
      'pageSize': 20,
    },
  );
}
