import 'package:flutter/material.dart';
import 'package:one_ui/src/icons/one_icons.dart';
import 'package:one_ui/src/theme/one_palette.dart';

/// A labelled text input with the Aso-oke field styling.
///
/// When [clearable] is set, a clear button appears while the field has text.
class OneTextField extends StatefulWidget {
  /// Creates a text field.
  const OneTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.clearable = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.autofocus = false,
    this.enabled = true,
    this.obscureText = false,
    this.autofillHints,
    this.focusNode,
  });

  /// Controls the text; one is created when null.
  final TextEditingController? controller;

  /// Floating label.
  final String? label;

  /// Placeholder.
  final String? hint;

  /// Helper line below the field.
  final String? helper;

  /// Error line below the field; also turns the border red.
  final String? errorText;

  /// Leading icon.
  final IconData? prefixIcon;

  /// Show a clear button when there is text.
  final bool clearable;

  /// Text changes.
  final ValueChanged<String>? onChanged;

  /// Keyboard action pressed.
  final ValueChanged<String>? onSubmitted;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Focus on first build.
  final bool autofocus;

  /// Whether input is accepted.
  final bool enabled;

  /// Hide the text (passwords).
  final bool obscureText;

  /// Autofill hints.
  final Iterable<String>? autofillHints;

  /// Focus node.
  final FocusNode? focusNode;

  @override
  State<OneTextField> createState() => _OneTextFieldState();
}

class _OneTextFieldState extends State<OneTextField> {
  TextEditingController? _owned;

  TextEditingController get _controller =>
      widget.controller ?? (_owned ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(OneTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _owned)?.removeListener(_onText);
      _controller.addListener(_onText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _owned?.dispose();
    super.dispose();
  }

  void _onText() {
    if (widget.clearable) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final showClear =
        widget.clearable && _controller.text.isNotEmpty && widget.enabled;
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helper,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20),
        suffixIcon: showClear
            ? IconButton(
                tooltip: 'Clear',
                icon: Icon(
                  OneIcons.x,
                  size: 18,
                  color: context.onePalette.inkMuted,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged?.call('');
                },
              )
            : null,
      ),
    );
  }
}
