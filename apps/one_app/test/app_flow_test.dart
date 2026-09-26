import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_api/one_api.dart';
import 'package:one_app/features/marketplace/search_screen.dart';
import 'package:one_ui/one_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'harness.dart';

void main() {
  group('first launch', () {
    testWidgets('splash leads to onboarding, which can be skipped once', (
      tester,
    ) async {
      await pumpOneApp(
        tester,
        onboardingSeen: false,
        routes: (api) => onSearch(api, [palmwine]),
      );
      expect(
        find.text('Hotels, salons and more, woven together.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(
        find.text('You book with them, not with a middleman.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('Discover'), findsWidgets);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('one.onboarding.v1'), isTrue);
    });

    testWidgets('the last onboarding page starts exploring', (tester) async {
      await pumpOneApp(
        tester,
        onboardingSeen: false,
        routes: (api) => onSearch(api, [palmwine]),
      );
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Skip'), findsNothing);
      await tester.tap(find.text('Start exploring'));
      await tester.pumpAndSettle();
      expect(find.text('The Palmwine House'), findsOneWidget);
    });
  });

  group('marketplace search', () {
    testWidgets('lists what is on One, then searches as you type', (
      tester,
    ) async {
      await pumpOneApp(
        tester,
        routes: (api) {
          onSearch(api, [palmwine, kinks]);
          onSearch(api, [kinks], text: 'wuse');
        },
      );
      expect(find.text('2 PLACES ON ONE'), findsOneWidget);
      expect(find.text('The Palmwine House'), findsOneWidget);
      expect(
        find.textContaining('₦45,000', findRichText: true),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'wuse');
      await tester.pump(SearchScreen.debounce);
      await tester.pumpAndSettle();
      expect(find.text('The Palmwine House'), findsNothing);
      expect(find.text('Kinks & Co'), findsOneWidget);
      expect(find.text('1 PLACE FOR "WUSE"'), findsOneWidget);
    });

    testWidgets('shows an empty state when nothing matches', (tester) async {
      await pumpOneApp(
        tester,
        routes: (api) {
          onSearch(api, [palmwine]);
          onSearch(api, const [], text: 'ikeja');
        },
      );
      await tester.enterText(find.byType(TextField), 'ikeja');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('No places match "ikeja"'), findsOneWidget);
    });

    testWidgets('shows an offline state with a working retry', (tester) async {
      await pumpOneApp(
        tester,
        routes: (api) => api.onGet(
          OneApiPaths.marketplaceSearch,
          (s) => s.throws(
            0,
            DioException.connectionError(
              requestOptions: RequestOptions(
                path: OneApiPaths.marketplaceSearch,
              ),
              reason: 'offline',
            ),
          ),
          queryParameters: {'page': 1, 'pageSize': 20},
        ),
      );
      expect(find.text('You are offline'), findsOneWidget);
      expect(
        find.text(
          'You appear to be offline. Check your connection and try again.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(find.byType(OneLoadingState), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('You are offline'), findsOneWidget);
    });

    testWidgets('shows a loading state while waiting', (tester) async {
      await pumpOneApp(
        tester,
        routes: (api) {
          onSearch(api, [palmwine]);
          api.onGet(
            OneApiPaths.marketplaceSearch,
            (s) => s.reply(200, {
              'items': <Object?>[],
            }, delay: const Duration(seconds: 2)),
            queryParameters: {'q': 'slow', 'page': 1, 'pageSize': 20},
          );
        },
      );
      await tester.enterText(find.byType(TextField), 'slow');
      await tester.pump(SearchScreen.debounce);
      await tester.pump();
      // Previous results stay while the new search runs.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('The Palmwine House'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('No places match "slow"'), findsOneWidget);
    });
  });

  group('listing detail', () {
    testWidgets('opens from search and continues on the product', (
      tester,
    ) async {
      final h = await pumpOneApp(
        tester,
        routes: (api) {
          onSearch(api, [palmwine]);
          api.onGet(
            OneApiPaths.marketplaceListing(palmwine['id']! as String),
            (s) => s.reply(200, palmwine),
          );
        },
      );
      await tester.tap(find.text('The Palmwine House'));
      await tester.pumpAndSettle();

      expect(
        find.text('A quiet boutique hotel two streets from the lagoon.'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Hourly stays'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Check in'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(
        find.text('You will book directly with The Palmwine House on HotelOS.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Continue on HotelOS'));
      await tester.pump();
      expect(h.opened, [Uri.parse('https://palmwine.hotelos.ng/book')]);
    });

    testWidgets('says so when a listing is gone', (tester) async {
      await pumpOneApp(
        tester,
        routes: (api) {
          onSearch(api, [kinks]);
          api.onGet(
            OneApiPaths.marketplaceListing(kinks['id']! as String),
            (s) => s.reply(404, {
              'statusCode': 404,
              'code': 'NOT_FOUND',
              'message': 'Listing not found',
            }),
          );
        },
      );
      await tester.tap(find.text('Kinks & Co'));
      await tester.pumpAndSettle();
      expect(find.text('This place is no longer listed'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });
  });

  group('you', () {
    testWidgets('signs in with One ID and out again', (tester) async {
      final h = await pumpOneApp(
        tester,
        routes: (api) => onSearch(api, [palmwine]),
      );
      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      expect(find.text('Keep your trips in one place'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in with One ID'), findsOneWidget);

      await tester.tap(find.text('Continue with One ID'));
      await tester.pumpAndSettle();
      expect(h.auth.signIns, 1);
      expect(find.text('Adaeze'), findsOneWidget);
      expect(find.text('ada@example.test'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Keep your trips in one place'), findsOneWidget);
      expect(await h.store.read(), isNull);
      expect(h.auth.endSessions, 1);
    });

    testWidgets('restores a stored session at launch', (tester) async {
      await pumpOneApp(
        tester,
        storedTokens: adaezeTokens,
        routes: (api) => onSearch(api, [palmwine]),
      );
      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      expect(find.text('Adaeze'), findsOneWidget);
    });

    testWidgets('remembers the chosen theme', (tester) async {
      await pumpOneApp(tester, routes: (api) => onSearch(api, [palmwine]));
      await tester.tap(find.text('You'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(
        Theme.of(tester.element(find.text('Dark'))).brightness,
        Brightness.dark,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('one.themeMode'), 'dark');
    });
  });
}
