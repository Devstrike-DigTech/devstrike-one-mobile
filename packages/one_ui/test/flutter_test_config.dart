import 'dart:async';

import 'package:one_ui/one_ui_testing.dart';

/// Runs before every test in this package (hermetic fonts, icon fonts).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await setUpOneUiForTests();
  await testMain();
}
