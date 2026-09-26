import 'package:flutter/material.dart';
import 'package:one_ui/src/motif/woven_band.dart';
import 'package:one_ui/src/theme/one_text_styles.dart';
import 'package:one_ui/src/tokens/one_tokens.g.dart';

/// A heading with an optional mono "eyebrow" above it and a short woven rule
/// below: the recurring typographic signature of One.
class OneSectionHeader extends StatelessWidget {
  /// Creates a header.
  const OneSectionHeader({
    required this.title,
    super.key,
    this.eyebrow,
    this.trailing,
    this.large = false,
  });

  /// Heading text.
  final String title;

  /// Small upper-case label above the heading.
  final String? eyebrow;

  /// Optional widget at the end of the title row (e.g. a text button).
  final Widget? trailing;

  /// Use the display size (screen titles) instead of the section size.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: context.oneText.eyebrow),
          const SizedBox(height: OneSpaceTokens.s2),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: large ? text.displaySmall : text.headlineMedium,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: OneSpaceTokens.s3),
        const WovenBand.rule(width: 56),
      ],
    );
  }
}
