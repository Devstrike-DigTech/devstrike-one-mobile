import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:one_ui/src/theme/one_palette.dart';

/// Paints the Aso-oke motif: narrow woven strips sewn edge to edge, the way
/// strip-cloth is made from bands a hand's width across (many businesses,
/// woven into one cloth).
///
/// Each strip has a dark ground in a repeating A-B-A-C rhythm, two fine warp
/// threads running its length, and short weft blocks in accent colours. The
/// blocks of neighbouring strips sit half a repeat apart, the way sewn strips
/// never quite line up. Everything is derived from [seed], so goldens are
/// stable and the motif never shimmers between rebuilds.
///
/// Use it thin, as structure: a 4-6px rule under a heading, a 12-48px band on
/// a splash or empty state. Never as a fill behind text.
class WovenBandPainter extends CustomPainter {
  /// Creates a painter.
  WovenBandPainter({
    required this.colors,
    required this.seam,
    this.stripWidth = 14,
    this.pitch = 3,
    this.seed = 0,
    this.progress = 1,
  }) : assert(colors.isNotEmpty, 'colors must not be empty'),
       assert(stripWidth > 2 && pitch > 0, 'strip and pitch must be positive'),
       assert(progress >= 0 && progress <= 1, 'progress is 0..1');

  /// Weave colours, in order.
  final List<Color> colors;

  /// Colour of the thin seam between strips (usually the page background).
  final Color seam;

  /// Width of one strip in logical pixels.
  final double stripWidth;

  /// Height of one weft block unit in logical pixels.
  final double pitch;

  /// Changes the arrangement without changing the character.
  final int seed;

  /// Fraction of strips drawn, left to right (for a reveal animation).
  final double progress;

  /// Ground rhythm across strips: A B A C A B A D.
  static const List<int> _rhythm = [0, 1, 0, 2, 0, 1, 0, 3];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress == 0) return;
    final (grounds, accents) = _split();
    final paint = Paint()..isAntiAlias = false;
    final bounds = Offset.zero & size;
    final strips = (size.width / stripWidth).ceil();
    final visible = (strips * progress).ceil();
    final thin = size.height <= pitch * 3;
    final period = pitch * 5;

    for (var i = 0; i < visible; i++) {
      final left = i * stripWidth;
      final width = math.min(stripWidth, size.width - left);
      final ground =
          grounds[_rhythm[(i + seed) % _rhythm.length] % grounds.length];

      paint.color = ground;
      canvas.drawRect(Rect.fromLTWH(left, 0, width, size.height), paint);

      if (!thin && accents.isNotEmpty) {
        // Warp: two fine threads along the strip.
        if (width >= 8) {
          paint.color = accents[(i + seed) % accents.length].withValues(
            alpha: 0.45,
          );
          for (final f in const [0.34, 0.66]) {
            canvas.drawRect(
              Rect.fromLTWH(left + width * f, 0, 1, size.height),
              paint,
            );
          }
        }
        // Weft: blocks two units tall, half a repeat out of phase on odd strips.
        final phase = (i.isOdd ? period / 2 : 0) + (seed % 5) * pitch;
        var k = 0;
        for (var top = phase - period; top < size.height; top += period, k++) {
          paint.color = accents[(i ~/ 2 + k + seed) % accents.length];
          canvas.drawRect(
            Rect.fromLTWH(left, top, width, pitch * 2).intersect(bounds),
            paint,
          );
        }
      } else if (thin && accents.isNotEmpty && (i + seed) % 4 == 3) {
        // Seen edge-on, the cloth shows an accent every few strips.
        paint.color = accents[(i ~/ 4 + seed) % accents.length];
        canvas.drawRect(Rect.fromLTWH(left, 0, width, size.height), paint);
      }

      // The seam: a 1px line where two strips were sewn together.
      if (i > 0) {
        paint.color = seam;
        canvas.drawRect(Rect.fromLTWH(left, 0, 1, size.height), paint);
      }
    }
  }

  /// Splits the weave into grounds (colours that stand off the seam, so the
  /// band always has weight) and accents (everything else, in order).
  (List<Color>, List<Color>) _split() {
    final seamLum = seam.computeLuminance();
    double contrast(Color c) {
      final l = c.computeLuminance();
      return (math.max(l, seamLum) + 0.05) / (math.min(l, seamLum) + 0.05);
    }

    final strong = colors.where((c) => contrast(c) >= 4.5).toList();
    final grounds = strong.isEmpty ? colors : strong.take(4).toList();
    final accents = colors
        .where((c) => !grounds.contains(c) && contrast(c) >= 1.5)
        .toList();
    return (grounds, accents.isEmpty ? [grounds.last] : accents);
  }

  @override
  bool shouldRepaint(WovenBandPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.progress != progress ||
      oldDelegate.stripWidth != stripWidth ||
      oldDelegate.pitch != pitch ||
      oldDelegate.seam != seam ||
      !_sameColors(oldDelegate.colors, colors);

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// The woven strip motif as a widget, coloured from the current theme.
///
/// ```dart
/// const WovenBand.rule()          // 4px divider under a heading
/// const WovenBand(height: 40)     // a band on a splash or empty state
/// ```
class WovenBand extends StatelessWidget {
  /// A band of [height] logical pixels.
  const WovenBand({
    super.key,
    this.height = 32,
    this.width,
    this.seed = 0,
    this.progress = 1,
    this.stripWidth = 14,
    this.colors,
  });

  /// A thin rule (4px), for separating a heading from its content.
  const WovenBand.rule({super.key, this.width, this.seed = 0, this.colors})
    : height = 4,
      progress = 1,
      stripWidth = 18;

  /// Height of the band.
  final double height;

  /// Width of the band; fills the available width when null.
  final double? width;

  /// Pattern seed.
  final int seed;

  /// Reveal progress, 0..1.
  final double progress;

  /// Strip width.
  final double stripWidth;

  /// Overrides the theme's weave colours.
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final palette = context.onePalette;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(width ?? double.infinity, height),
          painter: WovenBandPainter(
            colors: colors ?? palette.weave,
            seam: palette.paper,
            seed: seed,
            progress: progress,
            stripWidth: stripWidth,
          ),
        ),
      ),
    );
  }
}
