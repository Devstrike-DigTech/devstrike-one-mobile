import 'package:flutter/material.dart';
import 'package:one_ui/src/theme/one_palette.dart';

/// Colour of a [OneTag].
enum OneTagTone {
  /// Quiet, ink on a well.
  neutral,

  /// Kola wash: highlights.
  warm,

  /// River wash: confirmation, open, available.
  cool,

  /// Brass wash: premium, featured.
  brass,
}

/// A small pill label (the only pill shape in the system).
class OneTag extends StatelessWidget {
  /// Creates a tag.
  const OneTag(this.label, {super.key, this.tone = OneTagTone.neutral});

  /// Text of the tag.
  final String label;

  /// Colour.
  final OneTagTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.onePalette.colors;
    final (bg, fg) = switch (tone) {
      OneTagTone.neutral => (c.surface2, c.inkMuted),
      OneTagTone.warm => (c.kolaWash, c.kola),
      OneTagTone.cool => (c.riverWash, c.river),
      OneTagTone.brass => (c.brassWash, c.brassInk),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: fg),
        ),
      ),
    );
  }
}
