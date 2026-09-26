import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart';

import 'helpers.dart';

void main() {
  group('OneButton', () {
    testWidgets('calls onPressed', (tester) async {
      var taps = 0;
      await pumpOne(
        tester,
        Center(
          child: OneButton(label: 'Search', onPressed: () => taps++),
        ),
      );
      await tester.tap(find.text('Search'));
      expect(taps, 1);
    });

    testWidgets('ignores taps and shows progress while loading', (
      tester,
    ) async {
      var taps = 0;
      await pumpOne(
        tester,
        Center(
          child: OneButton(
            label: 'Search',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Search'), warnIfMissed: false);
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('each variant renders its Material button', (tester) async {
      await pumpOne(
        tester,
        Column(
          children: [
            for (final v in OneButtonVariant.values)
              OneButton(label: v.name, variant: v, onPressed: () {}),
          ],
        ),
      );
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(2));
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('OneTextField', () {
    testWidgets('clear button appears with text and clears it', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final changes = <String>[];
      await pumpOne(
        tester,
        OneTextField(
          controller: controller,
          label: 'Search',
          clearable: true,
          onChanged: changes.add,
        ),
      );
      expect(find.byTooltip('Clear'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Lekki');
      await tester.pump();
      expect(find.byTooltip('Clear'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(changes.last, '');
    });

    testWidgets('shows the error text', (tester) async {
      await pumpOne(
        tester,
        const OneTextField(label: 'Email', errorText: 'Enter a valid email'),
      );
      expect(find.text('Enter a valid email'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('error state retries', (tester) async {
      var retries = 0;
      await pumpOne(
        tester,
        OneErrorState(message: 'Offline', onRetry: () => retries++),
      );
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('error state hides retry without a handler', (tester) async {
      await pumpOne(tester, const OneErrorState(message: 'Gone'));
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('empty state shows eyebrow, title and action', (tester) async {
      await pumpOne(
        tester,
        OneEmptyState(
          eyebrow: 'Coming in One-5',
          title: 'Books',
          message: 'Your books will live here.',
          action: OneButton(label: 'Learn more', onPressed: () {}),
        ),
      );
      expect(find.text('COMING IN ONE-5'), findsOneWidget);
      expect(find.text('Books'), findsOneWidget);
      expect(find.text('Learn more'), findsOneWidget);
    });

    testWidgets('loading state is announced and animates', (tester) async {
      await pumpOne(tester, const OneLoadingState(label: 'Searching'));
      expect(find.bySemanticsLabel('Searching'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('loading state is static with reduced motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OneTheme.light(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: OneLoadingState()),
          ),
        ),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('ListingTile', () {
    testWidgets('renders facts and a single semantic label', (tester) async {
      var opened = false;
      await pumpOne(
        tester,
        ListingTile(
          title: 'The Palmwine House',
          place: 'Lekki Phase 1, Lagos',
          eyebrow: 'Hotel',
          priceLabel: '₦45,000',
          priceUnit: 'night',
          ratingLabel: '4.6',
          ratingCount: 128,
          onTap: () => opened = true,
        ),
      );
      expect(find.text('HOTEL'), findsOneWidget);
      expect(find.text('The Palmwine House'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp(
            'The Palmwine House, Lekki Phase 1, Lagos, from ₦45,000 per night, rated 4.6',
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byType(ListingTile));
      expect(opened, isTrue);
    });

    testWidgets('falls back to the woven placeholder without an image', (
      tester,
    ) async {
      await pumpOne(tester, const ListingTile(title: 'A', place: 'B'));
      expect(find.byType(WovenBand), findsOneWidget);
    });
  });

  testWidgets('section header marks a heading', (tester) async {
    await pumpOne(
      tester,
      const OneSectionHeader(title: 'Discover', eyebrow: 'Marketplace'),
    );
    expect(find.text('MARKETPLACE'), findsOneWidget);
    final node = tester.getSemantics(find.text('Discover'));
    expect(node.flagsCollection.isHeader, isTrue);
  });

  testWidgets('wordmark reads as one label', (tester) async {
    await pumpOne(
      tester,
      const Center(child: OneWordmark(product: 'Business')),
    );
    expect(find.bySemanticsLabel('One Business'), findsOneWidget);
  });

  test('woven painter repaints only when inputs change', () {
    final a = WovenBandPainter(
      colors: OneWeaveTokens.light,
      seam: oneColorsLight.paper,
    );
    final b = WovenBandPainter(
      colors: List.of(OneWeaveTokens.light),
      seam: oneColorsLight.paper,
    );
    final c = WovenBandPainter(
      colors: OneWeaveTokens.light,
      seam: oneColorsLight.paper,
      seed: 2,
    );
    expect(a.shouldRepaint(b), isFalse);
    expect(a.shouldRepaint(c), isTrue);
  });
}
