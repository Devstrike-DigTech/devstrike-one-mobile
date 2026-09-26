import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_api/one_api.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_business/app/providers.dart';
import 'package:one_core/one_core.dart';
import 'package:one_ui/one_ui.dart';

/// The owner's home: their stores (all, or the one picked in the switcher),
/// and an honest note about when the day's numbers arrive.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final stores = ref.watch(storesProvider);
    final selectedId = ref.watch(selectedStoreProvider);
    final name = session is SignedIn ? session.claims.displayName : null;

    return RefreshIndicator(
      onRefresh: () =>
          ref.refresh(storesProvider.future).then((_) {}, onError: (_) {}),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          OneSpaceTokens.s4,
          OneSpaceTokens.s6,
          OneSpaceTokens.s4,
          OneSpaceTokens.s8,
        ),
        children: [
          OneSectionHeader(
            eyebrow: 'Today',
            title: name == null ? 'Welcome' : 'Welcome, $name',
            large: true,
          ),
          const SizedBox(height: OneSpaceTokens.s6),
          switch (stores) {
            AsyncData(:final value) when value.isEmpty => const OneCard(
              padding: EdgeInsets.zero,
              child: OneEmptyState(
                icon: OneIcons.storefront,
                title: 'No stores yet',
                message:
                    'When a product such as HotelOS is linked to your organisation, '
                    'its stores show here and in the switcher above.',
              ),
            ),
            AsyncData(:final value) => _Stores(
              stores: selectedId == null
                  ? value
                  : value.where((s) => s.id == selectedId).toList(),
            ),
            AsyncError(:final error) => OneErrorState(
              message: error is OneFailure
                  ? error.message
                  : 'We could not load your stores.',
              onRetry: () => ref.invalidate(storesProvider),
            ),
            _ => const OneLoadingState(label: 'Loading your stores'),
          },
        ],
      ),
    );
  }
}

class _Stores extends StatelessWidget {
  const _Stores({required this.stores});

  final List<OneStore> stores;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final oneText = context.oneText;
    final palette = context.onePalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          (stores.length == 1 ? '1 store' : '${stores.length} stores')
              .toUpperCase(),
          style: oneText.eyebrow,
        ),
        const SizedBox(height: OneSpaceTokens.s3),
        for (final store in stores) ...[
          OneCard(
            child: Row(
              children: [
                Icon(OneIcons.storefront, color: palette.inkMuted),
                const SizedBox(width: OneSpaceTokens.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name, style: text.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        [store.productName, ?store.city].join(' · '),
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: OneSpaceTokens.s2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${store.listingCount}', style: oneText.numeric),
                    Text(
                      store.listingCount == 1 ? 'listing' : 'listings',
                      style: oneText.numericSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: OneSpaceTokens.s3),
        ],
        const SizedBox(height: OneSpaceTokens.s3),
        Text(
          'Bookings and takings join this page when the ledger (One-3) and Insights (One-5) arrive.',
          style: text.bodySmall,
        ),
      ],
    );
  }
}
