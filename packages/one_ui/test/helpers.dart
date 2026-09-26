import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart';

/// Pumps [child] inside a themed app.
Future<void> pumpOne(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  Size? size,
}) async {
  if (size != null) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: OneTheme.of(brightness),
      home: Scaffold(body: child),
    ),
  );
}
