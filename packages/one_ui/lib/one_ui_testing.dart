/// Test helpers for code that renders `one_ui` widgets. Import only from
/// tests (`flutter_test_config.dart`).
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_ui/one_ui.dart';

/// Makes widget and golden tests hermetic: no network font fetching, theme
/// fonts by family name only, and the Phosphor icon fonts loaded so icons
/// render in goldens instead of as missing-glyph boxes.
///
/// [workspaceRoot] locates `packages/one_ui/fonts`; by default it is found by
/// walking up from the current directory (tests run from the member's root).
Future<void> setUpOneUiForTests({String? workspaceRoot}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  OneFonts.source = OneFontSource.familyNameOnly;

  final fonts = _findFontsDir(workspaceRoot);
  if (fonts == null) return;
  for (final (family, file) in const [
    ('packages/one_ui/Phosphor', 'Phosphor.ttf'),
    ('packages/one_ui/PhosphorFill', 'Phosphor-Fill.ttf'),
  ]) {
    final bytes = File('${fonts.path}/$file').readAsBytesSync();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
}

Directory? _findFontsDir(String? root) {
  if (root != null) return Directory('$root/packages/one_ui/fonts');
  var dir = Directory.current;
  for (var i = 0; i < 5; i++) {
    for (final candidate in [
      'fonts',
      'packages/one_ui/fonts',
      '../../packages/one_ui/fonts',
    ]) {
      final d = Directory('${dir.path}/$candidate');
      if (File('${d.path}/Phosphor.ttf').existsSync()) return d;
    }
    dir = dir.parent;
  }
  return null;
}
