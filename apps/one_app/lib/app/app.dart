import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_app/app/providers.dart';
import 'package:one_app/app/router.dart';
import 'package:one_ui/one_ui.dart';

/// The One customer app.
class OneApp extends ConsumerWidget {
  const OneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: OneTheme.light(),
      darkTheme: OneTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
