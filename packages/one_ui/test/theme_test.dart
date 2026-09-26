import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart';

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, theme, tokens) in [
    ('light', OneTheme.light(), oneColorsLight),
    ('dark', OneTheme.dark(), oneColorsDark),
  ]) {
    group('$name theme', () {
      test('maps the Aso-oke roles onto the colour scheme', () {
        final s = theme.colorScheme;
        expect(s.primary, tokens.kola);
        expect(s.onPrimary, tokens.kolaInk);
        expect(s.secondary, tokens.river);
        expect(s.error, tokens.danger);
        expect(s.surface, tokens.surface);
        expect(s.onSurface, tokens.ink);
        expect(theme.scaffoldBackgroundColor, tokens.paper);
      });

      test('exposes the palette and text-style extensions', () {
        expect(theme.extension<OnePalette>()!.colors, same(tokens));
        expect(theme.extension<OneTextStyles>(), isNotNull);
      });

      test('uses the Aso-oke families, never a default sans', () {
        final t = theme.textTheme;
        expect(t.displayLarge!.fontFamily, OneFontTokens.display);
        expect(t.bodyMedium!.fontFamily, OneFontTokens.ui);
        expect(
          theme.extension<OneTextStyles>()!.numeric.fontFamily,
          OneFontTokens.mono,
        );
      });

      test('text pairs reach WCAG AA', () {
        final pairs = <(String, Color, Color)>[
          ('ink/paper', tokens.ink, tokens.paper),
          ('ink/surface', tokens.ink, tokens.surface),
          ('ink-muted/paper', tokens.inkMuted, tokens.paper),
          ('ink-muted/surface', tokens.inkMuted, tokens.surface),
          ('kola-ink/kola', tokens.kolaInk, tokens.kola),
          ('river-ink/river', tokens.riverInk, tokens.river),
          ('kola/surface', tokens.kola, tokens.surface),
          ('danger/surface', tokens.danger, tokens.surface),
          ('danger-ink/danger', tokens.dangerInk, tokens.danger),
        ];
        for (final (label, fg, bg) in pairs) {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: label);
        }
      });
    });
  }

  test('token set is identified', () {
    expect(OneTokenSet.name, 'Devstrike One: Aso-oke');
  });
}
