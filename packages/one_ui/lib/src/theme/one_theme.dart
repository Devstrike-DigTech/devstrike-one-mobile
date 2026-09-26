import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:one_ui/src/theme/one_palette.dart';
import 'package:one_ui/src/theme/one_text_styles.dart';
import 'package:one_ui/src/tokens/one_tokens.g.dart';

/// Builds the Aso-oke `ThemeData` for One's apps.
///
/// Principles carried over from the web design system: hairlines over
/// shadows, small radii (4-6px, pills only for tags), one warm accent for
/// actions, the cool accent for confirmation, calm motion.
abstract final class OneTheme {
  /// The light theme (cotton paper, indigo-black ink).
  static ThemeData light() => _build(OnePalette.light);

  /// The dark theme (indigo night, cotton ink).
  static ThemeData dark() => _build(OnePalette.dark);

  /// Theme for [brightness].
  static ThemeData of(Brightness brightness) =>
      brightness == Brightness.dark ? dark() : light();

  static ThemeData _build(OnePalette p) {
    final c = p.colors;
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: c.kola,
      onPrimary: c.kolaInk,
      primaryContainer: c.kolaWash,
      onPrimaryContainer: c.kola,
      secondary: c.river,
      onSecondary: c.riverInk,
      secondaryContainer: c.riverWash,
      onSecondaryContainer: c.river,
      tertiary: c.brass,
      onTertiary: c.ink,
      tertiaryContainer: c.brassWash,
      onTertiaryContainer: c.brassInk,
      error: c.danger,
      onError: c.dangerInk,
      errorContainer: c.dangerWash,
      onErrorContainer: c.danger,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.inkMuted,
      surfaceContainerLowest: c.paper,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surface2,
      surfaceContainerHighest: c.surface3,
      surfaceDim: c.surface2,
      surfaceBright: c.surface,
      outline: c.lineStrong,
      outlineVariant: c.line,
      inverseSurface: c.ink,
      onInverseSurface: c.paper,
      inversePrimary: p.brightness == Brightness.light
          ? oneColorsDark.kola
          : oneColorsLight.kola,
      shadow: const Color(0xFF141722),
      scrim: const Color(0xFF0E1017),
      surfaceTint: Colors.transparent,
    );

    final text = _textTheme(ink: c.ink, muted: c.inkMuted);
    const radiusSm = BorderRadius.all(Radius.circular(OneRadiusTokens.sm));
    const radiusMd = BorderRadius.all(Radius.circular(OneRadiusTokens.md));
    final hairline = BorderSide(color: c.line);
    final buttonText = text.labelLarge!.copyWith(fontWeight: FontWeight.w600);
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: OneSpaceTokens.s5,
      vertical: OneSpaceTokens.s3,
    );
    const buttonSize = Size(64, 48);

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.paper,
      canvasColor: c.paper,
      textTheme: text,
      primaryTextTheme: text,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [
        p,
        OneTextStyles.build(ink: c.ink, muted: c.inkMuted),
      ],
      iconTheme: IconThemeData(color: c.ink, size: 22),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.paper,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: OneSpaceTokens.s4,
        titleTextStyle: text.titleLarge,
        shape: Border(bottom: hairline),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radiusMd, side: hairline),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.kola,
          foregroundColor: c.kolaInk,
          disabledBackgroundColor: c.surface3,
          disabledForegroundColor: c.inkFaint,
          textStyle: buttonText,
          padding: buttonPadding,
          minimumSize: buttonSize,
          shape: const RoundedRectangleBorder(borderRadius: radiusSm),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          disabledForegroundColor: c.inkFaint,
          side: BorderSide(color: c.lineStrong),
          textStyle: buttonText,
          padding: buttonPadding,
          minimumSize: buttonSize,
          shape: const RoundedRectangleBorder(borderRadius: radiusSm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.kola,
          textStyle: buttonText,
          padding: const EdgeInsets.symmetric(
            horizontal: OneSpaceTokens.s3,
            vertical: OneSpaceTokens.s2,
          ),
          minimumSize: const Size(48, 44),
          shape: const RoundedRectangleBorder(borderRadius: radiusSm),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OneSpaceTokens.s4,
          vertical: OneSpaceTokens.s3 + 2,
        ),
        hintStyle: text.bodyLarge!.copyWith(color: c.inkFaint),
        labelStyle: text.bodyMedium!.copyWith(color: c.inkMuted),
        floatingLabelStyle: text.bodyMedium!.copyWith(color: c.ink),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall!.copyWith(color: c.danger),
        prefixIconColor: c.inkMuted,
        suffixIconColor: c.inkMuted,
        // OutlineInputBorder's default radius is 4, which is OneRadiusTokens.sm.
        border: OutlineInputBorder(borderSide: BorderSide(color: c.lineStrong)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.lineStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.focus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.danger, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.ink,
        disabledColor: c.surface2,
        labelStyle: text.labelMedium,
        secondaryLabelStyle: text.labelMedium!.copyWith(color: c.paper),
        side: BorderSide(color: c.line),
        shape: const StadiumBorder(),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: OneSpaceTokens.s2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.kolaWash,
        indicatorShape: const RoundedRectangleBorder(borderRadius: radiusSm),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium!.copyWith(
            color: states.contains(WidgetState.selected) ? c.ink : c.inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? c.kola : c.inkMuted,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.inkMuted,
        textColor: c.ink,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: OneSpaceTokens.s4,
        ),
        minVerticalPadding: OneSpaceTokens.s3,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.inkMuted,
          selectedBackgroundColor: c.ink,
          selectedForegroundColor: c.paper,
          side: BorderSide(color: c.lineStrong),
          textStyle: text.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: radiusSm),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.riverInk : c.inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.river : c.surface2,
        ),
        trackOutlineColor: WidgetStatePropertyAll(c.lineStrong),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.kola,
        linearTrackColor: c.line,
        circularTrackColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.ink,
        contentTextStyle: text.bodyMedium!.copyWith(color: c.paper),
        actionTextColor: p.brightness == Brightness.light
            ? oneColorsDark.kola
            : oneColorsLight.kola,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: radiusSm),
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.lineStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OneRadiusTokens.lg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: radiusMd),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: c.ink, borderRadius: radiusSm),
        textStyle: text.bodySmall!.copyWith(color: c.paper),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.kola,
        selectionColor: c.kolaWash,
        selectionHandleColor: c.kola,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme({required Color ink, required Color muted}) {
    TextStyle d(double size, FontWeight w, double height, double tracking) =>
        OneFonts.display(
          TextStyle(
            fontSize: size,
            fontWeight: w,
            height: height,
            letterSpacing: tracking,
            color: ink,
          ),
        );
    TextStyle u(
      double size,
      FontWeight w,
      double height, {
      Color? color,
      double tracking = 0,
    }) => OneFonts.ui(
      TextStyle(
        fontSize: size,
        fontWeight: w,
        height: height,
        letterSpacing: tracking,
        color: color ?? ink,
      ),
    );

    return TextTheme(
      displayLarge: d(
        OneFontSizeTokens.xl4,
        FontWeight.w400,
        OneLineHeightTokens.tight,
        -1.2,
      ),
      displayMedium: d(
        OneFontSizeTokens.xl3,
        FontWeight.w400,
        OneLineHeightTokens.tight,
        -0.8,
      ),
      displaySmall: d(
        OneFontSizeTokens.xl2,
        FontWeight.w500,
        OneLineHeightTokens.snug,
        -0.4,
      ),
      headlineLarge: d(
        OneFontSizeTokens.xl2,
        FontWeight.w500,
        OneLineHeightTokens.snug,
        -0.4,
      ),
      headlineMedium: d(
        OneFontSizeTokens.xl,
        FontWeight.w500,
        OneLineHeightTokens.snug,
        -0.2,
      ),
      headlineSmall: d(
        OneFontSizeTokens.lg,
        FontWeight.w600,
        OneLineHeightTokens.snug,
        -0.1,
      ),
      titleLarge: d(
        OneFontSizeTokens.xl,
        FontWeight.w500,
        OneLineHeightTokens.snug,
        -0.2,
      ),
      titleMedium: u(
        OneFontSizeTokens.base,
        FontWeight.w600,
        OneLineHeightTokens.snug,
      ),
      titleSmall: u(
        OneFontSizeTokens.sm,
        FontWeight.w600,
        OneLineHeightTokens.snug,
      ),
      bodyLarge: u(
        OneFontSizeTokens.base,
        FontWeight.w400,
        OneLineHeightTokens.normal,
      ),
      bodyMedium: u(
        OneFontSizeTokens.sm,
        FontWeight.w400,
        OneLineHeightTokens.normal,
      ),
      bodySmall: u(
        OneFontSizeTokens.xs + 1,
        FontWeight.w400,
        OneLineHeightTokens.normal,
        color: muted,
      ),
      labelLarge: u(
        OneFontSizeTokens.sm + 1,
        FontWeight.w600,
        OneLineHeightTokens.snug,
        tracking: 0.1,
      ),
      labelMedium: u(
        OneFontSizeTokens.xs + 1,
        FontWeight.w500,
        OneLineHeightTokens.snug,
        tracking: 0.1,
      ),
      labelSmall: u(
        OneFontSizeTokens.xs,
        FontWeight.w500,
        OneLineHeightTokens.snug,
        color: muted,
        tracking: 0.2,
      ),
    );
  }
}
