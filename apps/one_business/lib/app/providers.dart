import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_core/one_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Light, dark or follow the system; persisted.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
  name: 'themeMode',
);

/// Persists the theme choice.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'one.business.themeMode';

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

/// A store: an organisation's instance of a product (a hotel on HotelOS).
@immutable
class StoreSummary {
  const StoreSummary({
    required this.id,
    required this.name,
    required this.productName,
    required this.city,
  });

  final String id;
  final String name;
  final String productName;
  final String city;
}

/// The stores the signed-in person can manage.
///
/// Empty until One-1 ships store linking (`GET /api/v1/orgs/{orgId}/stores`
/// in core-api); the UI already handles the empty case honestly.
final storesProvider = FutureProvider<List<StoreSummary>>((ref) async {
  ref.watch(sessionProvider.select((s) => s.isSignedIn));
  return const [];
}, name: 'stores');

/// The store the owner is looking at; `null` means "all stores".
final selectedStoreProvider = NotifierProvider<SelectedStoreNotifier, String?>(
  SelectedStoreNotifier.new,
  name: 'selectedStore',
);

/// Holds the selected store id.
class SelectedStoreNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Selects [storeId] (`null` for all stores).
  // A method rather than a setter keeps call sites readable in callbacks.
  // ignore: use_setters_to_change_properties
  void select(String? storeId) => state = storeId;
}
