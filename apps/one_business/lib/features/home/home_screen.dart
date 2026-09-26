import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_auth/one_auth.dart';
import 'package:one_business/app/providers.dart';
import 'package:one_ui/one_ui.dart';

/// The owner's dashboard. Empty in One-0: it says what will appear and when,
/// rather than showing placeholder numbers.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final stores = ref.watch(storesProvider);
    final name = session is SignedIn ? session.claims.displayName : null;
    final text = Theme.of(context).textTheme;

    return ListView(
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
        const SizedBox(height: OneSpaceTokens.s4),
        Text(
          'Bookings, takings and messages from every store will gather here.',
          style: context.oneText.lead,
        ),
        const SizedBox(height: OneSpaceTokens.s6),
        switch (stores) {
          AsyncData(:final value) when value.isEmpty => const OneCard(
            padding: EdgeInsets.zero,
            child: OneEmptyState(
              eyebrow: 'Coming in One-1',
              icon: OneIcons.storefront,
              title: 'Link your first store',
              message:
                  "When your HotelOS property is linked to One, today's arrivals, "
                  'takings and occupancy show here, store by store.',
            ),
          ),
          AsyncData(:final value) => Text(
            '${value.length} stores linked',
            style: text.titleMedium,
          ),
          AsyncError(:final error) => OneErrorState(
            message: error is Exception
                ? 'We could not load your stores.'
                : '$error',
            onRetry: () => ref.invalidate(storesProvider),
          ),
          _ => const OneLoadingState(label: 'Loading your stores'),
        },
      ],
    );
  }
}
