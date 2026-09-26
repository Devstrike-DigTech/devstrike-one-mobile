import 'dart:async';

import 'package:one_ui/one_ui_testing.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await setUpOneUiForTests();
  await testMain();
}
