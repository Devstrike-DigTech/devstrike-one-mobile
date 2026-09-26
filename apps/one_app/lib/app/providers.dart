import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_api/one_api.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Resolved app configuration (overridden in `bootstrap`).
final appConfigProvider = Provider<OneConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden'),
  name: 'appConfig',
);

/// Loaded preferences (overridden in `bootstrap`).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
  name: 'sharedPreferences',
);

/// The core-api client, authenticated when a session exists.
final apiClientProvider = Provider<OneApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final client = OneApiClient(
    baseUrl: config.apiBaseUrl,
    clientName: 'one_app',
    accessToken: () => ref.read(sessionProvider.notifier).accessToken(),
  );
  ref.onDispose(client.close);
  return client;
}, name: 'apiClient');

/// Opens a URL outside the app; replaced in tests.
typedef ExternalUrlOpener = Future<bool> Function(Uri url);

/// Opens product deep links in the product's app or the browser.
final externalUrlOpenerProvider = Provider<ExternalUrlOpener>(
  (ref) =>
      (url) => launchUrl(url, mode: LaunchMode.externalApplication),
  name: 'externalUrlOpener',
);

/// Light, dark or follow the system; persisted.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
  name: 'themeMode',
);

/// Persists the theme choice in shared preferences.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'one.themeMode';

  @override
  ThemeMode build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  /// Chooses [mode] and remembers it.
  Future<void> select(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

/// Whether onboarding has been completed on this device.
final onboardingSeenProvider = NotifierProvider<OnboardingSeenNotifier, bool>(
  OnboardingSeenNotifier.new,
  name: 'onboardingSeen',
);

/// Persists onboarding completion. Bump the key version to show a new
/// onboarding to everyone.
class OnboardingSeenNotifier extends Notifier<bool> {
  static const _key = 'one.onboarding.v1';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  /// Marks onboarding as done.
  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}
