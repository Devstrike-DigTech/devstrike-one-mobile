import 'package:flutter/material.dart';
import 'package:one_ui/src/tokens/one_tokens.g.dart';

/// Every Aso-oke colour role, available as `context.onePalette`.
///
/// Material's `ColorScheme` covers the common roles; this extension carries
/// the rest (washes, brass, river, weave bands) so widgets never reach for a
/// raw hex value.
@immutable
class OnePalette extends ThemeExtension<OnePalette> {
  /// Creates a palette from generated [colors] and [weave] bands.
  const OnePalette({
    required this.colors,
    required this.weave,
    required this.brightness,
  });

  /// The light palette.
  static const OnePalette light = OnePalette(
    colors: oneColorsLight,
    weave: OneWeaveTokens.light,
    brightness: Brightness.light,
  );

  /// The dark palette.
  static const OnePalette dark = OnePalette(
    colors: oneColorsDark,
    weave: OneWeaveTokens.dark,
    brightness: Brightness.dark,
  );

  /// All colour tokens for this mode.
  final OneColorTokens colors;

  /// Weave band colours, in order.
  final List<Color> weave;

  /// Which mode this palette is for.
  final Brightness brightness;

  /// Page background (cotton paper / indigo night).
  Color get paper => colors.paper;

  /// Cards and panels.
  Color get surface => colors.surface;

  /// Wells and hover.
  Color get surface2 => colors.surface2;

  /// Primary text.
  Color get ink => colors.ink;

  /// Secondary text.
  Color get inkMuted => colors.inkMuted;

  /// Tertiary text and placeholders.
  Color get inkFaint => colors.inkFaint;

  /// Hairlines.
  Color get line => colors.line;

  /// Warm accent: primary actions.
  Color get kola => colors.kola;

  /// Cool accent: success and secondary emphasis.
  Color get river => colors.river;

  /// Premium, ratings, featured.
  Color get brass => colors.brass;

  /// Errors.
  Color get danger => colors.danger;

  @override
  OnePalette copyWith({
    OneColorTokens? colors,
    List<Color>? weave,
    Brightness? brightness,
  }) => OnePalette(
    colors: colors ?? this.colors,
    weave: weave ?? this.weave,
    brightness: brightness ?? this.brightness,
  );

  @override
  OnePalette lerp(covariant OnePalette? other, double t) {
    // Palettes swap at the midpoint: interpolating 28 roles plus the weave
    // buys nothing visible during a theme cross-fade and costs a lot of code.
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

/// Convenience accessors on [BuildContext].
extension OnePaletteContext on BuildContext {
  /// The [OnePalette] of the nearest theme (light if none is installed).
  OnePalette get onePalette =>
      Theme.of(this).extension<OnePalette>() ?? OnePalette.light;
}
