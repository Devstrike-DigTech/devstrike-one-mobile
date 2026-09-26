import 'package:flutter/material.dart';
import 'package:one_ui/src/theme/one_palette.dart';

/// Visual weight of a [OneButton].
enum OneButtonVariant {
  /// Kola fill: the one main action on a screen.
  primary,

  /// Hairline outline: secondary actions.
  secondary,

  /// Text only: low-emphasis actions (skip, cancel).
  quiet,

  /// Danger outline: destructive actions (sign out, delete).
  danger,
}

/// A button in the Aso-oke style. Shows a small progress indicator in place
/// of the icon while [loading] and ignores taps meanwhile.
class OneButton extends StatelessWidget {
  /// Creates a button.
  const OneButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = OneButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
  });

  /// Button text. Use a verb: "Search", "Continue on HotelOS".
  final String label;

  /// Called on tap; `null` disables the button.
  final VoidCallback? onPressed;

  /// Visual weight.
  final OneButtonVariant variant;

  /// Optional leading icon (Phosphor).
  final IconData? icon;

  /// Optional trailing icon, e.g. an arrow for "continue elsewhere".
  final IconData? trailingIcon;

  /// Shows progress and disables the button.
  final bool loading;

  /// Stretch to the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = context.onePalette;
    final action = loading ? null : onPressed;
    final leading = loading
        ? SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == OneButtonVariant.primary
                  ? palette.colors.kolaInk
                  : palette.ink,
            ),
          )
        : (icon == null ? null : Icon(icon, size: 18));

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: 10)],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (trailingIcon != null) ...[
          const SizedBox(width: 10),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );

    final button = switch (variant) {
      OneButtonVariant.primary => FilledButton(
        onPressed: action,
        child: content,
      ),
      OneButtonVariant.secondary => OutlinedButton(
        onPressed: action,
        child: content,
      ),
      OneButtonVariant.quiet => TextButton(onPressed: action, child: content),
      OneButtonVariant.danger => OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.danger,
          side: BorderSide(color: palette.danger),
        ),
        child: content,
      ),
    };

    return Semantics(
      button: true,
      enabled: action != null,
      label: loading ? '$label, in progress' : null,
      excludeSemantics: loading,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
