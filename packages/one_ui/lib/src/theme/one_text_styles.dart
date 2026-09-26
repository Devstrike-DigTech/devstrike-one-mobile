import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_ui/src/tokens/one_tokens.g.dart';

/// Where theme fonts come from.
enum OneFontSource {
  /// Fetch (and cache) Newsreader, Public Sans and Martian Mono with
  /// `google_fonts`, or use bundled copies when the app ships them.
  googleFonts,

  /// Only set the family names. Used by tests (no network, no async font
  /// loading) and as an escape hatch if fonts are bundled another way.
  familyNameOnly,
}

/// Builds text styles in the three Aso-oke families.
abstract final class OneFonts {
  /// Global switch; tests set this to [OneFontSource.familyNameOnly] in
  /// `flutter_test_config.dart`.
  static OneFontSource source = OneFontSource.googleFonts;

  /// Newsreader: display and headings.
  static TextStyle display(TextStyle style) =>
      _apply(OneFontTokens.display, style);

  /// Public Sans: interface and body.
  static TextStyle ui(TextStyle style) => _apply(OneFontTokens.ui, style);

  /// Martian Mono: prices, codes, counts. Always tabular.
  ///
  /// Martian Mono has no naira sign (U+20A6), so Public Sans is the first
  /// fallback: "₦45,000" gets a matching ₦ instead of whatever the platform
  /// font happens to draw.
  static TextStyle mono(TextStyle style) {
    final fallback = ui(const TextStyle()).fontFamily;
    return _apply(
      OneFontTokens.mono,
      style.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        fontFamilyFallback: [?fallback, ...?style.fontFamilyFallback],
      ),
    );
  }

  static TextStyle _apply(String family, TextStyle style) => switch (source) {
    OneFontSource.googleFonts => GoogleFonts.getFont(family, textStyle: style),
    OneFontSource.familyNameOnly => style.copyWith(fontFamily: family),
  };
}

/// Styles Material's `TextTheme` has no slot for, as `context.oneText`.
@immutable
class OneTextStyles extends ThemeExtension<OneTextStyles> {
  /// Creates the extension.
  const OneTextStyles({
    required this.eyebrow,
    required this.numeric,
    required this.numericSmall,
    required this.lead,
  });

  /// Builds the styles for [ink]/[muted] text colours.
  factory OneTextStyles.build({required Color ink, required Color muted}) =>
      OneTextStyles(
        eyebrow: OneFonts.mono(
          TextStyle(
            fontSize: 11,
            height: 1.3,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w500,
            color: muted,
          ),
        ),
        numeric: OneFonts.mono(
          TextStyle(
            fontSize: OneFontSizeTokens.sm,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: ink,
          ),
        ),
        numericSmall: OneFonts.mono(
          TextStyle(fontSize: OneFontSizeTokens.xs, height: 1.3, color: muted),
        ),
        lead: OneFonts.display(
          TextStyle(
            fontSize: OneFontSizeTokens.lg,
            height: OneLineHeightTokens.normal,
            fontStyle: FontStyle.italic,
            color: muted,
          ),
        ),
      );

  /// Small upper-case label above a heading (Martian Mono).
  final TextStyle eyebrow;

  /// Prices, counts and codes (Martian Mono, tabular figures).
  final TextStyle numeric;

  /// Secondary numbers, units.
  final TextStyle numericSmall;

  /// Italic Newsreader introduction line.
  final TextStyle lead;

  @override
  OneTextStyles copyWith({
    TextStyle? eyebrow,
    TextStyle? numeric,
    TextStyle? numericSmall,
    TextStyle? lead,
  }) => OneTextStyles(
    eyebrow: eyebrow ?? this.eyebrow,
    numeric: numeric ?? this.numeric,
    numericSmall: numericSmall ?? this.numericSmall,
    lead: lead ?? this.lead,
  );

  @override
  OneTextStyles lerp(covariant OneTextStyles? other, double t) {
    if (other == null) return this;
    return OneTextStyles(
      eyebrow: TextStyle.lerp(eyebrow, other.eyebrow, t)!,
      numeric: TextStyle.lerp(numeric, other.numeric, t)!,
      numericSmall: TextStyle.lerp(numericSmall, other.numericSmall, t)!,
      lead: TextStyle.lerp(lead, other.lead, t)!,
    );
  }
}

/// Convenience accessor on [BuildContext].
extension OneTextStylesContext on BuildContext {
  /// The [OneTextStyles] of the nearest theme.
  OneTextStyles get oneText =>
      Theme.of(this).extension<OneTextStyles>() ??
      OneTextStyles.build(
        ink: const Color(0xFF141722),
        muted: const Color(0xFF565866),
      );
}
