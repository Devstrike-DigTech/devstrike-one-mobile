import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_business/app/providers.dart';
import 'package:one_business/app/router.dart';
import 'package:one_ui/one_ui.dart';

/// The One Business owner app.
class OneBusinessApp extends ConsumerWidget {
  const OneBusinessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: ref.watch(appConfigProvider).appName,
      debugShowCheckedModeBanner: false,
      theme: OneTheme.light(),
      darkTheme: OneTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
