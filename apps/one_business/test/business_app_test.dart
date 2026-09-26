import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_business/app/app.dart';
import 'package:one_business/app/providers.dart';
import 'package:one_core/one_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

Future<(FakeAuthenticator, InMemoryTokenStore)> pumpBusiness(
  WidgetTester tester, {
  TokenSet? stored,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final auth = FakeAuthenticator();
  final store = InMemoryTokenStore(stored);
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
    expect(find.text('Link your first store'), findsOneWidget);
    expect(find.text('COMING IN ONE-1'), findsOneWidget);
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
    expect(find.text('No stores linked yet'), findsOneWidget);
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
