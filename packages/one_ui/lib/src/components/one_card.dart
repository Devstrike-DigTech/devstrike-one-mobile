import 'package:flutter/material.dart';
import 'package:one_ui/src/tokens/one_tokens.g.dart';

/// A surface with a hairline border and no shadow. Tappable when [onTap] is
/// given (with an ink ripple clipped to the card).
class OneCard extends StatelessWidget {
  /// Creates a card.
  const OneCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(OneSpaceTokens.s4),
    this.semanticLabel,
  });

  /// Card content.
  final Widget child;

  /// Tap handler.
  final VoidCallback? onTap;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Label announced for the whole card when it is tappable.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Card(
      child: onTap == null
          ? body
          : Semantics(
              button: true,
              label: semanticLabel,
              child: InkWell(onTap: onTap, child: body),
            ),
    );
  }
}
