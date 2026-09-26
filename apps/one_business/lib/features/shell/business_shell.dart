import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_business/app/providers.dart';
import 'package:one_ui/one_ui.dart';

/// App frame: a store switcher on top, the four areas at the bottom.
class BusinessShell extends ConsumerWidget {
  const BusinessShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.onePalette;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: OneSpaceTokens.s2,
        title: const StoreSwitcherButton(),
        actions: [
          IconButton(
            tooltip: 'Account',
            icon: const Icon(OneIcons.userCircle),
            onPressed: () => unawaited(showAccountSheet(context)),
          ),
          const SizedBox(width: OneSpaceTokens.s2),
        ],
      ),
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.line)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(OneIcons.squaresFour),
              selectedIcon: Icon(OneIcons.squaresFourFill),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(OneIcons.tray),
              selectedIcon: Icon(OneIcons.trayFill),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: Icon(OneIcons.bookOpen),
              selectedIcon: Icon(OneIcons.bookOpenFill),
              label: 'Books',
            ),
            NavigationDestination(
              icon: Icon(OneIcons.chartLine),
              selectedIcon: Icon(OneIcons.chartLineFill),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the current store (or organisation) and opens the switcher.
class StoreSwitcherButton extends ConsumerWidget {
  const StoreSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final stores = ref.watch(storesProvider).value ?? const [];
    final selectedId = ref.watch(selectedStoreProvider);
    final session = ref.watch(sessionProvider);
    final orgs = session is SignedIn
        ? session.claims.organisations
        : const <Map<String, Object?>>[];
    final orgName = orgs.isEmpty ? null : orgs.first['name'] as String?;

    final selected = stores.where((s) => s.id == selectedId).firstOrNull;
    final title =
        selected?.name ?? (stores.isEmpty ? 'No store linked' : 'All stores');
    final subtitle = selected?.productName ?? orgName ?? 'Your business';

    return Semantics(
      button: true,
      label: 'Store: $title. Switch store',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(OneRadiusTokens.sm),
        onTap: () => unawaited(showStoreSwitcher(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OneSpaceTokens.s2,
            vertical: OneSpaceTokens.s1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      subtitle.toUpperCase(),
                      style: context.oneText.eyebrow,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      title,
                      style: text.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: OneSpaceTokens.s2),
              Icon(
                OneIcons.caretUpDown,
                size: 18,
                color: context.onePalette.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet listing the owner's stores.
Future<void> showStoreSwitcher(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _StoreSwitcherSheet(),
    );

class _StoreSwitcherSheet extends ConsumerWidget {
  const _StoreSwitcherSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(storesProvider).value ?? const [];
    final selectedId = ref.watch(selectedStoreProvider);
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OneSpaceTokens.s4,
          0,
          OneSpaceTokens.s4,
          OneSpaceTokens.s6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OneSectionHeader(
              eyebrow: 'Switch store',
              title: 'Your stores',
            ),
            const SizedBox(height: OneSpaceTokens.s4),
            if (stores.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: OneSpaceTokens.s4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      OneIcons.storefront,
                      color: context.onePalette.inkMuted,
                    ),
                    const SizedBox(width: OneSpaceTokens.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No stores linked yet', style: text.titleMedium),
                          const SizedBox(height: OneSpaceTokens.s1),
                          Text(
                            'Linking a HotelOS property to your One account arrives in One-1. '
                            'Your stores will be listed here.',
                            style: text.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _StoreRow(
                title: 'All stores',
                subtitle: '${stores.length} linked',
                selected: selectedId == null,
                onTap: () {
                  ref.read(selectedStoreProvider.notifier).select(null);
                  Navigator.of(context).pop();
                },
              ),
              for (final store in stores)
                _StoreRow(
                  title: store.name,
                  subtitle: '${store.productName} · ${store.city}',
                  selected: selectedId == store.id,
                  onTap: () {
                    ref.read(selectedStoreProvider.notifier).select(store.id);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(OneIcons.storefront),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: selected
        ? Icon(OneIcons.check, color: context.onePalette.river)
        : null,
    selected: selected,
    onTap: onTap,
  );
}

/// Account, appearance and sign-out.
Future<void> showAccountSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AccountSheet(),
    );

class _AccountSheet extends ConsumerWidget {
  const _AccountSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final mode = ref.watch(themeModeProvider);
    final text = Theme.of(context).textTheme;
    final claims = session is SignedIn ? session.claims : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OneSpaceTokens.s4,
          0,
          OneSpaceTokens.s4,
          OneSpaceTokens.s6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OneSectionHeader(
              eyebrow: 'Signed in as',
              title: claims?.displayName ?? 'Account',
            ),
            if (claims?.email case final email?) ...[
              const SizedBox(height: OneSpaceTokens.s2),
              Text(email, style: text.bodyMedium),
            ],
            const SizedBox(height: OneSpaceTokens.s6),
            Text('Appearance', style: text.titleSmall),
            const SizedBox(height: OneSpaceTokens.s2),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (s) => unawaited(
                ref.read(themeModeProvider.notifier).select(s.first),
              ),
            ),
            const SizedBox(height: OneSpaceTokens.s6),
            OneButton(
              label: 'Sign out',
              icon: OneIcons.signOut,
              variant: OneButtonVariant.danger,
              expand: true,
              onPressed: () {
                Navigator.of(context).pop();
                unawaited(ref.read(sessionProvider.notifier).signOut());
              },
            ),
          ],
        ),
      ),
    );
  }
}
