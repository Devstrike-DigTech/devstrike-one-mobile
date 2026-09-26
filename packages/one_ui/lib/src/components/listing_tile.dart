import 'package:flutter/material.dart';
import 'package:one_ui/src/icons/one_icons.dart';
import 'package:one_ui/src/motif/woven_band.dart';
import 'package:one_ui/src/theme/one_palette.dart';
import 'package:one_ui/src/theme/one_text_styles.dart';
import 'package:one_ui/src/tokens/one_tokens.g.dart';

/// A marketplace result row: image, category eyebrow, title, place, price and
/// rating. Purely presentational: pass already-formatted strings so this
/// package does not depend on the API models.
class ListingTile extends StatelessWidget {
  /// Creates a listing tile.
  const ListingTile({
    required this.title,
    required this.place,
    super.key,
    this.eyebrow,
    this.imageUrl,
    this.priceLabel,
    this.priceUnit,
    this.ratingLabel,
    this.ratingCount,
    this.onTap,
  });

  /// Listing title.
  final String title;

  /// "Lekki Phase 1, Lagos".
  final String place;

  /// Category or product, shown small and upper case ("Hotel").
  final String? eyebrow;

  /// Cover image (https). A woven placeholder shows while loading or on error.
  final String? imageUrl;

  /// "₦45,000" (already formatted).
  final String? priceLabel;

  /// "night", "session"...
  final String? priceUnit;

  /// "4.6".
  final String? ratingLabel;

  /// Number of reviews behind [ratingLabel].
  final int? ratingCount;

  /// Opens the listing.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.onePalette;
    final text = Theme.of(context).textTheme;
    final oneText = context.oneText;
    final semantics = [
      title,
      place,
      if (priceLabel != null)
        'from $priceLabel${priceUnit == null ? '' : ' per $priceUnit'}',
      if (ratingLabel != null) 'rated $ratingLabel',
    ].join(', ');

    return Semantics(
      button: onTap != null,
      label: semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OneSpaceTokens.s4,
            vertical: OneSpaceTokens.s3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListingThumbnail(url: imageUrl),
              const SizedBox(width: OneSpaceTokens.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (eyebrow ?? '').toUpperCase(),
                            style: oneText.eyebrow,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (ratingLabel != null) ...[
                          const SizedBox(width: OneSpaceTokens.s2),
                          Icon(
                            OneIcons.starFill,
                            size: 12,
                            color: palette.brass,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            ratingLabel!,
                            style: oneText.numericSmall.copyWith(
                              color: palette.ink,
                            ),
                          ),
                          if (ratingCount != null)
                            Text(
                              ' ($ratingCount)',
                              style: oneText.numericSmall,
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: text.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place,
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (priceLabel != null) ...[
                      const SizedBox(height: OneSpaceTokens.s2),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'from ', style: text.bodySmall),
                            TextSpan(text: priceLabel, style: oneText.numeric),
                            if (priceUnit != null)
                              TextSpan(
                                text: ' / $priceUnit',
                                style: oneText.numericSmall,
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded image with a woven placeholder, used by [ListingTile] and on
/// detail screens (pass `size: null` to fill the parent).
class ListingThumbnail extends StatelessWidget {
  /// Creates a thumbnail.
  const ListingThumbnail({
    super.key,
    this.url,
    this.size = 88,
    this.radius = OneRadiusTokens.sm,
    this.seed,
  });

  /// Image URL; `null` shows the placeholder.
  final String? url;

  /// Square size; `null` fills the parent.
  final double? size;

  /// Corner radius.
  final double radius;

  /// Placeholder pattern seed; derived from [url] when null.
  final int? seed;

  @override
  Widget build(BuildContext context) {
    final palette = context.onePalette;
    final placeholder = ColoredBox(
      color: palette.surface2,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: WovenBand(
            height: 10,
            stripWidth: 8,
            seed: seed ?? (url?.hashCode ?? 0) % 97,
          ),
        ),
      ),
    );
    final image = url == null
        ? placeholder
        : Image.network(
            url!,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => placeholder,
            frameBuilder: (context, child, frame, sync) => AnimatedSwitcher(
              duration: OneMotionTokens.base,
              child: frame == null && !sync ? placeholder : child,
            ),
          );
    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
    return size == null
        ? clipped
        : SizedBox.square(dimension: size, child: clipped);
  }
}
