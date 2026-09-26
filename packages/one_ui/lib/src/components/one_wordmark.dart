import 'package:flutter/material.dart';
import 'package:one_ui/src/motif/woven_band.dart';
import 'package:one_ui/src/theme/one_palette.dart';
import 'package:one_ui/src/theme/one_text_styles.dart';

/// The "One" wordmark: the word set in Newsreader with a woven strip as its
/// baseline. [product] adds a second, lighter word ("Business").
class OneWordmark extends StatelessWidget {
  /// Creates a wordmark [size] logical pixels tall (cap height, roughly).
  const OneWordmark({super.key, this.size = 32, this.product});

  /// Font size of the wordmark.
  final double size;

  /// Optional product word shown after "One".
  final String? product;

  @override
  Widget build(BuildContext context) {
    final palette = context.onePalette;
    final style = OneFonts.display(
      TextStyle(
        fontSize: size,
        height: 1,
        fontWeight: FontWeight.w500,
        letterSpacing: -size * 0.03,
        color: palette.ink,
      ),
    );
    return Semantics(
      label: product == null ? 'One' : 'One $product',
      excludeSemantics: true,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'One'),
                  if (product != null)
                    TextSpan(
                      text: ' $product',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: palette.inkMuted,
                      ),
                    ),
                ],
              ),
              style: style,
            ),
            SizedBox(height: size * 0.18),
            WovenBand(
              height: (size * 0.14).clamp(3, 8),
              stripWidth: (size * 0.36).clamp(6, 18),
              seed: 3,
            ),
          ],
        ),
      ),
    );
  }
}
