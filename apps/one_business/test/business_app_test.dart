import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:one_api/one_api.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_business/app/app.dart';
import 'package:one_business/app/providers.dart';
import 'package:one_core/one_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// `GET /api/v1/accounts/stores` captured from the live core-api (six stores
/// of Kolanut Hospitality: five on HotelOS, one on EateryOS).
final Object? liveStores = jsonDecode(
  File('test/fixtures/accounts_stores.json').readAsStringSync(),
);

Future<(FakeAuthenticator, InMemoryTokenStore)> pumpBusiness(
  WidgetTester tester, {
  TokenSet? stored,
  Object? stores = const <Object?>[],
  int storesStatus = 200,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final auth = FakeAuthenticator();
  final store = InMemoryTokenStore(stored);
  final dio = Dio();
  DioAdapter(dio: dio)
      .onGet(OneApiPaths.myStores, (s) => s.reply(storesStatus, stores));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          OneConfig(
            appName: 'One Business',
            flavor: OneFlavor.staging,
            apiBaseUrl: Uri.parse('http://localhost:4100'),
            oidcIssuer: Uri.parse('http://localhost:4100/oidc'),
          ),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
        authenticatorProvider.overrideWithValue(auth),
        tokenStoreProvider.overrideWithValue(store),
        apiClientProvider.overrideWith(
          (ref) => OneApiClient(
            baseUrl: Uri.parse('http://localhost:4100'),
            dio: dio,
            accessToken: () => ref.read(sessionProvider.notifier).accessToken(),
          ),
        ),
      ],
      child: const OneBusinessApp(),
    ),
  );
  await tester.pumpAndSettle();
  return (auth, store);
}

void main() {
  testWidgets('signed-out owners land on sign-in', (tester) async {
    await pumpBusiness(tester);
    expect(find.text('Every store you run, in one place.'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('a failed sign-in explains itself', (tester) async {
    final (auth, _) = await pumpBusiness(tester);
    auth.failure = const NetworkFailure(message: 'We could not reach One ID.');
    await tester.tap(find.text('Sign in with One ID'));
    await tester.pumpAndSettle();
    expect(find.text('We could not reach One ID.'), findsOneWidget);
  });

  testWidgets('signing in opens the empty dashboard', (tester) async {
    await pumpBusiness(tester);
    await tester.tap(find.text('Sign in with One ID'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Tunde'), findsOneWidget);
    expect(find.text('No stores yet'), findsOneWidget);
    expect(find.text('No store linked'), findsOneWidget);
    expect(find.text('PALMWINE HOSPITALITY'), findsOneWidget);
  });

  testWidgets('placeholder tabs are honest about timing', (tester) async {
    await pumpBusiness(tester, stored: ownerTokens);
    for (final (tab, eyebrow) in [
      ('Inbox', 'NOT SCHEDULED YET'),
      ('Books', 'COMING IN ONE-5'),
      ('Insights', 'COMING IN ONE-5'),
    ]) {
      await tester.tap(find.widgetWithText(NavigationDestination, tab));
      await tester.pumpAndSettle();
      expect(find.text(eyebrow), findsOneWidget, reason: tab);
    }
  });

  testWidgets('the store switcher says no stores are linked yet', (
    tester,
  ) async {
    await pumpBusiness(tester, stored: ownerTokens);
    await tester.tap(
      find.bySemanticsLabel('Store: No store linked. Switch store'),
    );
    await tester.pumpAndSettle();
    expect(find.text('No stores yet'), findsWidgets);
  });

  testWidgets('lists the stores of the owner and switches between them', (
    tester,
  ) async {
    await pumpBusiness(tester, stored: ownerTokens, stores: liveStores);
    expect(find.text('6 STORES'), findsOneWidget);
    expect(find.text('All stores'), findsOneWidget);
    expect(find.text('PALMWINE HOSPITALITY'), findsOneWidget);
    expect(find.text('The Palmwine House'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Store: All stores. Switch store'));
    await tester.pumpAndSettle();
    expect(find.text('Kolanut Kitchen'), findsWidgets);
    await tester.tap(find.text('Maitama Court').last);
    await tester.pumpAndSettle();

    expect(find.text('1 STORE'), findsOneWidget);
    expect(find.text('HOTELOS'), findsOneWidget);
    expect(find.text('HotelOS · Abuja'), findsOneWidget);
    expect(find.text('The Palmwine House'), findsNothing);
  });

  testWidgets('a failed store load offers a retry', (tester) async {
    await pumpBusiness(
      tester,
      stored: ownerTokens,
      stores: const {'statusCode': 500, 'message': 'boom'},
      storesStatus: 500,
    );
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('signing out returns to sign-in and clears tokens', (
    tester,
  ) async {
    final (auth, store) = await pumpBusiness(tester, stored: ownerTokens);
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(find.text('tunde@palmwine.test'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Every store you run, in one place.'), findsOneWidget);
    expect(await store.read(), isNull);
    expect(auth.endSessions, 1);
  });

  testWidgets('theme choice applies and persists', (tester) async {
    await pumpBusiness(tester, stored: ownerTokens);
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('one.business.themeMode'), 'dark');
  });
}
