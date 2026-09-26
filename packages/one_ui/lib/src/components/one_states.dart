import 'package:flutter/material.dart';
import 'package:one_ui/src/components/one_button.dart';
import 'package:one_ui/src/icons/one_icons.dart';
import 'package:one_ui/src/motif/woven_band.dart';
import 'package:one_ui/src/theme/one_palette.dart';
import 'package:one_ui/src/tokens/one_tokens.g.dart';

/// Shared layout for empty, error and "coming soon" states: an icon in a
/// hairline square, a Newsreader title, one sentence, an optional action.
class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.eyebrow,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? eyebrow;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.onePalette;
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: OneSpaceTokens.s8,
          vertical: OneSpaceTokens.s10,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border.all(color: palette.line),
                  borderRadius: BorderRadius.circular(OneRadiusTokens.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(icon, size: 28, color: iconColor),
                ),
              ),
              const SizedBox(height: OneSpaceTokens.s5),
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: text.labelSmall!.copyWith(letterSpacing: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OneSpaceTokens.s2),
              ],
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: text.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: OneSpaceTokens.s2),
              Text(
                message,
                style: text.bodyMedium!.copyWith(color: palette.inkMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OneSpaceTokens.s5),
              const WovenBand.rule(width: 40),
              if (action != null) ...[
                const SizedBox(height: OneSpaceTokens.s6),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Nothing to show yet (no results, no stores, no messages).
class OneEmptyState extends StatelessWidget {
  /// Creates an empty state.
  const OneEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.icon = OneIcons.magnifyingGlass,
    this.eyebrow,
    this.action,
  });

  /// Short heading ("No places match 'Ikeja'").
  final String title;

  /// One sentence of help.
  final String message;

  /// Phosphor icon.
  final IconData icon;

  /// Small label above the title ("Coming in One-5").
  final String? eyebrow;

  /// Optional button.
  final Widget? action;

  @override
  Widget build(BuildContext context) => _StateLayout(
    icon: icon,
    iconColor: context.onePalette.inkMuted,
    title: title,
    message: message,
    eyebrow: eyebrow,
    action: action,
  );
}

/// Something failed; say what, and offer a retry when it can help.
class OneErrorState extends StatelessWidget {
  /// Creates an error state.
  const OneErrorState({
    required this.message,
    super.key,
    this.title = 'That did not work',
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = OneIcons.warningCircle,
  });

  /// Heading.
  final String title;

  /// What happened, in plain words (usually `OneFailure.message`).
  final String message;

  /// Retry handler; hides the button when null.
  final VoidCallback? onRetry;

  /// Label of the retry button.
  final String retryLabel;

  /// Phosphor icon.
  final IconData icon;

  @override
  Widget build(BuildContext context) => _StateLayout(
    icon: icon,
    iconColor: context.onePalette.danger,
    title: title,
    message: message,
    action: onRetry == null
        ? null
        : OneButton(
            label: retryLabel,
            variant: OneButtonVariant.secondary,
            icon: OneIcons.arrowClockwise,
            onPressed: onRetry,
          ),
  );
}

/// Waiting on the network: a woven band that weaves itself, plus a label.
/// Static when the platform asks for reduced motion.
class OneLoadingState extends StatefulWidget {
  /// Creates a loading state.
  const OneLoadingState({super.key, this.label = 'Loading'});

  /// Announced and shown under the band.
  final String label;

  @override
  State<OneLoadingState> createState() => _OneLoadingStateState();
}

class _OneLoadingStateState extends State<OneLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Semantics(
        liveRegion: true,
        label: widget.label,
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 96,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => WovenBand(
                  height: 12,
                  stripWidth: 8,
                  seed: 5,
                  progress: Curves.easeInOut
                      .transform(_controller.value)
                      .clamp(0.05, 1),
                ),
              ),
            ),
            const SizedBox(height: OneSpaceTokens.s3),
            Text(widget.label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
