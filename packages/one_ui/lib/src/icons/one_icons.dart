import 'package:flutter/widgets.dart';

/// The Phosphor icons One uses, drawn from the Phosphor 2.1 font files
/// vendored in `packages/one_ui/fonts` (MIT, see `PHOSPHOR_LICENSE.txt`).
///
/// Why vendored: `phosphor_flutter` 2.1.0 extends `IconData`, which is a
/// `final` class on current Flutter, so the package no longer compiles. A
/// curated set also keeps the icon language consistent. To add an icon, look
/// up its code point (the same in every weight) on phosphoricons.com or in
/// the phosphor_flutter sources and add a constant here.
abstract final class OneIcons {
  /// Search.
  static const IconData magnifyingGlass = IconData(
    0xe30c,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Search (filled).
  static const IconData magnifyingGlassFill = IconData(
    0xe30c,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Close or clear.
  static const IconData x = IconData(
    0xe4f6,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Close or clear (filled).
  static const IconData xFill = IconData(
    0xe4f6,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Rating (outline).
  static const IconData star = IconData(
    0xe46a,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Rating (outline) (filled).
  static const IconData starFill = IconData(
    0xe46a,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Error.
  static const IconData warningCircle = IconData(
    0xe4e2,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Error (filled).
  static const IconData warningCircleFill = IconData(
    0xe4e2,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Retry.
  static const IconData arrowClockwise = IconData(
    0xe036,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Retry (filled).
  static const IconData arrowClockwiseFill = IconData(
    0xe036,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Forward.
  static const IconData arrowRight = IconData(
    0xe06c,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
    matchTextDirection: true,
  );

  /// Forward (filled).
  static const IconData arrowRightFill = IconData(
    0xe06c,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
    matchTextDirection: true,
  );

  /// Leaves the app (external link, continue on a product).
  static const IconData arrowUpRight = IconData(
    0xe092,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
    matchTextDirection: true,
  );

  /// Leaves the app (external link, continue on a product) (filled).
  static const IconData arrowUpRightFill = IconData(
    0xe092,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
    matchTextDirection: true,
  );

  /// Back.
  static const IconData arrowLeft = IconData(
    0xe058,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
    matchTextDirection: true,
  );

  /// Back (filled).
  static const IconData arrowLeftFill = IconData(
    0xe058,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
    matchTextDirection: true,
  );

  /// Disclosure.
  static const IconData caretRight = IconData(
    0xe13a,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
    matchTextDirection: true,
  );

  /// Disclosure (filled).
  static const IconData caretRightFill = IconData(
    0xe13a,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
    matchTextDirection: true,
  );

  /// Switcher.
  static const IconData caretUpDown = IconData(
    0xe140,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Switcher (filled).
  static const IconData caretUpDownFill = IconData(
    0xe140,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Place.
  static const IconData mapPin = IconData(
    0xe316,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Place (filled).
  static const IconData mapPinFill = IconData(
    0xe316,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Person.
  static const IconData user = IconData(
    0xe4c2,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Person (filled).
  static const IconData userFill = IconData(
    0xe4c2,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Account.
  static const IconData userCircle = IconData(
    0xe4c4,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Account (filled).
  static const IconData userCircleFill = IconData(
    0xe4c4,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Settings.
  static const IconData gearSix = IconData(
    0xe272,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Settings (filled).
  static const IconData gearSixFill = IconData(
    0xe272,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Light theme.
  static const IconData sun = IconData(
    0xe472,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Light theme (filled).
  static const IconData sunFill = IconData(
    0xe472,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Dark theme.
  static const IconData moon = IconData(
    0xe330,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Dark theme (filled).
  static const IconData moonFill = IconData(
    0xe330,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// System theme.
  static const IconData circleHalf = IconData(
    0xe18c,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// System theme (filled).
  static const IconData circleHalfFill = IconData(
    0xe18c,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Sign in.
  static const IconData signIn = IconData(
    0xe428,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Sign in (filled).
  static const IconData signInFill = IconData(
    0xe428,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Sign out.
  static const IconData signOut = IconData(
    0xe42a,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Sign out (filled).
  static const IconData signOutFill = IconData(
    0xe42a,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Store.
  static const IconData storefront = IconData(
    0xe470,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Store (filled).
  static const IconData storefrontFill = IconData(
    0xe470,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Inbox.
  static const IconData tray = IconData(
    0xe4aa,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Inbox (filled).
  static const IconData trayFill = IconData(
    0xe4aa,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Books.
  static const IconData bookOpen = IconData(
    0xe0e6,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Books (filled).
  static const IconData bookOpenFill = IconData(
    0xe0e6,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Insights.
  static const IconData chartLine = IconData(
    0xe154,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Insights (filled).
  static const IconData chartLineFill = IconData(
    0xe154,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Home.
  static const IconData house = IconData(
    0xe2c2,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Home (filled).
  static const IconData houseFill = IconData(
    0xe2c2,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Dashboard.
  static const IconData squaresFour = IconData(
    0xe464,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Dashboard (filled).
  static const IconData squaresFourFill = IconData(
    0xe464,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Discover.
  static const IconData compass = IconData(
    0xe1c8,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Discover (filled).
  static const IconData compassFill = IconData(
    0xe1c8,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Offline.
  static const IconData wifiSlash = IconData(
    0xe4f2,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Offline (filled).
  static const IconData wifiSlashFill = IconData(
    0xe4f2,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Information.
  static const IconData info = IconData(
    0xe2ce,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Information (filled).
  static const IconData infoFill = IconData(
    0xe2ce,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Done.
  static const IconData check = IconData(
    0xe182,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Done (filled).
  static const IconData checkFill = IconData(
    0xe182,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Security.
  static const IconData shieldCheck = IconData(
    0xe40c,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Security (filled).
  static const IconData shieldCheckFill = IconData(
    0xe40c,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Organisation.
  static const IconData buildings = IconData(
    0xe102,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Organisation (filled).
  static const IconData buildingsFill = IconData(
    0xe102,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Add.
  static const IconData plus = IconData(
    0xe3d4,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Add (filled).
  static const IconData plusFill = IconData(
    0xe3d4,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );

  /// Locked.
  static const IconData lockSimple = IconData(
    0xe308,
    fontFamily: 'Phosphor',
    fontPackage: 'one_ui',
  );

  /// Locked (filled).
  static const IconData lockSimpleFill = IconData(
    0xe308,
    fontFamily: 'PhosphorFill',
    fontPackage: 'one_ui',
  );
}
