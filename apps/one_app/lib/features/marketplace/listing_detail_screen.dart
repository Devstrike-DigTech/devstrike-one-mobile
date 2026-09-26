import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_api/one_api.dart';
import 'package:one_app/app/providers.dart';
import 'package:one_app/features/marketplace/listing_formatting.dart';
import 'package:one_app/features/marketplace/marketplace_providers.dart';
import 'package:one_core/one_core.dart';
import 'package:one_ui/one_ui.dart';

/// A listing's page. Booking happens in the product (HotelOS...) through the
/// listing's primary action: One never takes the booking itself in One-0.
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(listingProvider(id));
    return switch (listing) {
      AsyncData(:final value) => _Detail(listing: value),
      AsyncError(:final error) => Scaffold(
        appBar: AppBar(),
        body: OneErrorState(
          title: error is NotFoundFailure
              ? 'This place is no longer listed'
              : 'We could not load this place',
          message: error is OneFailure
              ? error.message
              : 'Something unexpected happened.',
          onRetry: error is NotFoundFailure
              ? null
              : () => ref.invalidate(listingProvider(id)),
        ),
      ),
      _ => Scaffold(appBar: AppBar(), body: const OneLoadingState()),
    };
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.listing});

  final Listing listing;

  Future<void> _continue(
    BuildContext context,
    WidgetRef ref,
    ListingAction action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(externalUrlOpenerProvider)(action.url);
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Could not open ${action.url.host}. Try again in a moment.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final oneText = context.oneText;
    final palette = context.onePalette;
    final action = listing.primaryAction;
    final facts = listing.attributes.entries
        .where((e) => e.value != null)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: palette.paper,
            automaticallyImplyLeading: false,
            // A solid chip keeps "back" legible over any photograph.
            leading: Padding(
              padding: const EdgeInsets.all(OneSpaceTokens.s2),
              child: Material(
                color: palette.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OneRadiusTokens.sm),
                  side: BorderSide(color: palette.line),
                ),
                child: IconButton(
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  icon: const Icon(OneIcons.arrowLeft, size: 20),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Semantics(
                image: true,
                label: listing.coverImage?.alt,
                child: ListingThumbnail(
                  url: listing.coverImage?.url,
                  size: null,
                  radius: 0,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              OneSpaceTokens.s4,
              OneSpaceTokens.s5,
              OneSpaceTokens.s4,
              OneSpaceTokens.s8,
            ),
            sliver: SliverList.list(
              children: [
                OneSectionHeader(
                  eyebrow: listing.eyebrow,
                  title: listing.title,
                  large: true,
                ),
                const SizedBox(height: OneSpaceTokens.s3),
                Row(
                  children: [
                    Icon(OneIcons.mapPin, size: 16, color: palette.inkMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [
                          listing.location.address,
                          listing.location.shortLabel,
                        ].whereType<String>().join(', '),
                        style: text.bodyMedium!.copyWith(
                          color: palette.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OneSpaceTokens.s4),
                _PriceAndRating(listing: listing),
                if (listing.summary != null) ...[
                  const SizedBox(height: OneSpaceTokens.s5),
                  Text(listing.summary!, style: oneText.lead),
                ],
                if (listing.description != null) ...[
                  const SizedBox(height: OneSpaceTokens.s4),
                  Text(listing.description!, style: text.bodyLarge),
                ],
                if (listing.tags.isNotEmpty) ...[
                  const SizedBox(height: OneSpaceTokens.s5),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final t in listing.tags) OneTag(t)],
                  ),
                ],
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: OneSpaceTokens.s6),
                  const OneSectionHeader(title: 'Details'),
                  const SizedBox(height: OneSpaceTokens.s2),
                  for (final f in facts) _Fact(label: f.key, value: f.value!),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: action == null
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border(top: BorderSide(color: palette.line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    OneSpaceTokens.s4,
                    OneSpaceTokens.s3,
                    OneSpaceTokens.s4,
                    OneSpaceTokens.s3,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OneButton(
                        label: listing.continueLabel,
                        trailingIcon: OneIcons.arrowUpRight,
                        expand: true,
                        onPressed: () =>
                            unawaited(_continue(context, ref, action)),
                      ),
                      const SizedBox(height: OneSpaceTokens.s2),
                      Text(
                        'You will ${action.kind == ListingActionKind.order ? 'order' : 'book'} directly with '
                        '${listing.title} on ${listing.productLabel}.',
                        style: text.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _PriceAndRating extends StatelessWidget {
  const _PriceAndRating({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final oneText = context.oneText;
    final text = Theme.of(context).textTheme;
    final palette = context.onePalette;
    final price = listing.priceLabel == null
        ? Text('Prices on ${listing.productLabel}', style: text.bodySmall)
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'from ', style: text.bodySmall),
                TextSpan(
                  text: listing.priceLabel,
                  style: oneText.numeric.copyWith(fontSize: 18),
                ),
                if (listing.price!.unit != null)
                  TextSpan(
                    text: ' / ${listing.price!.unit}',
                    style: oneText.numericSmall,
                  ),
              ],
            ),
          );
    final rating = listing.rating == null
        ? const OneTag('New on One', tone: OneTagTone.brass)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(OneIcons.starFill, size: 15, color: palette.brass),
              const SizedBox(width: 4),
              Text(listing.rating!.label, style: oneText.numeric),
              Text(
                ' (${listing.rating!.count} reviews)',
                style: oneText.numericSmall,
              ),
            ],
          );
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: OneSpaceTokens.s4,
      runSpacing: OneSpaceTokens.s2,
      children: [price, rating],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final Object value;

  static String _humanise(String key) {
    final spaced = key
        .replaceAllMapped(RegExp('([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ');
    return spaced.isEmpty
        ? key
        : '${spaced[0].toUpperCase()}${spaced.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final shown = switch (value) {
      true => 'Yes',
      false => 'No',
      final Object v => '$v',
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: OneSpaceTokens.s3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.onePalette.line)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(_humanise(label), style: text.bodyMedium)),
          Text(shown, style: context.oneText.numeric),
        ],
      ),
    );
  }
}
