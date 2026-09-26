@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart';

import 'helpers.dart';

/// Goldens are rendered with the test font (boxes for glyphs), so they check
/// layout, colour and the woven motif rather than typography. They are
/// recorded on Linux; CI runs on Linux too. Re-record with
/// `melos run test:goldens:update` and review the images before committing.
void main() {
  for (final brightness in Brightness.values) {
    final mode = brightness.name;

    testWidgets('woven band ($mode)', (tester) async {
      await pumpOne(
        tester,
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WovenBand.rule(),
              SizedBox(height: 16),
              WovenBand(height: 48),
              SizedBox(height: 16),
              WovenBand(height: 24, seed: 7, stripWidth: 10),
              SizedBox(height: 16),
              WovenBand(height: 24, progress: 0.5),
            ],
          ),
        ),
        brightness: brightness,
        size: const Size(360, 200),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/woven_band_$mode.png'),
      );
    });

    testWidgets('components ($mode)', (tester) async {
      await pumpOne(
        tester,
        ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: OneSectionHeader(
                eyebrow: 'Marketplace',
                title: 'Places to stay',
              ),
            ),
            const SizedBox(height: 8),
            const ListingTile(
              title: 'The Palmwine House',
              place: 'Lekki Phase 1, Lagos',
              eyebrow: 'Hotel',
              priceLabel: '₦45,000',
              priceUnit: 'night',
              ratingLabel: '4.6',
              ratingCount: 128,
            ),
            const Divider(indent: 16, endIndent: 16),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OneTag('Open now', tone: OneTagTone.cool),
                  OneTag('Featured', tone: OneTagTone.brass),
                  OneTag('New', tone: OneTagTone.warm),
                  OneTag('Lagos'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  OneButton(label: 'Continue', expand: true, onPressed: () {}),
                  const SizedBox(height: 8),
                  OneButton(
                    label: 'Secondary',
                    variant: OneButtonVariant.secondary,
                    expand: true,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 8),
                  const OneTextField(
                    label: 'Search',
                    hint: 'City, area or name',
                  ),
                ],
              ),
            ),
          ],
        ),
        brightness: brightness,
        size: const Size(390, 600),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/components_$mode.png'),
      );
    });

    testWidgets('empty state ($mode)', (tester) async {
      await pumpOne(
        tester,
        const OneEmptyState(
          eyebrow: 'Coming in One-5',
          title: 'Books',
          message: 'Profit and loss, VAT and cash book for every store.',
        ),
        brightness: brightness,
        size: const Size(360, 480),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/empty_state_$mode.png'),
      );
    });
  }
}
