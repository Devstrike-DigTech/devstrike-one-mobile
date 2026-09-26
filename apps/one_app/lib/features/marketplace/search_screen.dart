import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:one_api/one_api.dart';
import 'package:one_app/app/router.dart';
import 'package:one_app/features/marketplace/listing_formatting.dart';
import 'package:one_app/features/marketplace/marketplace_providers.dart';
import 'package:one_core/one_core.dart';
import 'package:one_ui/one_ui.dart';

/// Marketplace search: one field, results as they arrive, and honest
/// loading, empty and error states.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  /// Pause after the last keystroke before searching.
  static const Duration debounce = Duration(milliseconds: 350);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _field = TextEditingController(
    text: ref.read(searchTextProvider),
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(
      SearchScreen.debounce,
      () => ref.read(searchTextProvider.notifier).set(text),
    );
  }

  void _submit(String text) {
    _debounce?.cancel();
    ref.read(searchTextProvider.notifier).set(text);
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final text = ref.watch(searchTextProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                OneSpaceTokens.s4,
                OneSpaceTokens.s6,
                OneSpaceTokens.s4,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OneSectionHeader(
                      eyebrow: 'One marketplace',
                      title: 'Discover',
                      large: true,
                    ),
                    const SizedBox(height: OneSpaceTokens.s5),
                    OneTextField(
                      controller: _field,
                      hint: 'Search places, areas or cities',
                      prefixIcon: OneIcons.magnifyingGlass,
                      clearable: true,
                      textInputAction: TextInputAction.search,
                      onChanged: _onChanged,
                      onSubmitted: _submit,
                    ),
                    const SizedBox(height: OneSpaceTokens.s3),
                  ],
                ),
              ),
            ),
          ],
          body: RefreshIndicator(
            onRefresh: () => ref
                .refresh(searchResultsProvider.future)
                .then((_) {}, onError: (_) {}),
            child: switch (results) {
              // First load, or a retry after an error: nothing useful to keep on screen.
              AsyncValue(isLoading: true, hasValue: false) => const _Scrollable(
                child: OneLoadingState(label: 'Searching'),
              ),
              AsyncValue(:final value?, isLoading: false) when value.isEmpty =>
                _Scrollable(
                  child: OneEmptyState(
                    title: text.isEmpty
                        ? 'Nothing listed yet'
                        : 'No places match "$text"',
                    message: text.isEmpty
                        ? 'Businesses appear here as they join One. Check back soon.'
                        : 'Try a city or an area instead, such as Lekki or Wuse II.',
                  ),
                ),
              AsyncValue(:final value?) => _Results(
                page: value,
                query: text,
                refreshing: results.isLoading,
              ),
              AsyncError(:final error) => _Scrollable(
                child: OneErrorState(
                  title: error is NetworkFailure
                      ? 'You are offline'
                      : 'Search is unavailable',
                  message: error is OneFailure
                      ? error.message
                      : 'Something unexpected happened.',
                  icon: error is NetworkFailure
                      ? OneIcons.wifiSlash
                      : OneIcons.warningCircle,
                  onRetry: () => ref.invalidate(searchResultsProvider),
                ),
              ),
              _ => const _Scrollable(
                child: OneLoadingState(label: 'Searching'),
              ),
            },
          ),
        ),
      ),
    );
  }
}

/// Keeps pull-to-refresh working when the body is a single state widget.
class _Scrollable extends StatelessWidget {
  const _Scrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: child,
      ),
    ),
  );
}

class _Results extends StatelessWidget {
  const _Results({
    required this.page,
    required this.query,
    this.refreshing = false,
  });

  final ListingPage page;
  final String query;

  /// A new search is running; the previous results stay visible under a
  /// hairline progress bar instead of flashing to a spinner on every key.
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final oneText = context.oneText;
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: OneSpaceTokens.s8),
      itemCount: page.items.length + 1,
      separatorBuilder: (_, i) => i == 0
          ? const SizedBox.shrink()
          : const Divider(
              indent: OneSpaceTokens.s4,
              endIndent: OneSpaceTokens.s4,
            ),
      itemBuilder: (context, i) {
        if (i == 0) {
          if (refreshing) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(
                OneSpaceTokens.s4,
                OneSpaceTokens.s2,
                OneSpaceTokens.s4,
                OneSpaceTokens.s1,
              ),
              child: LinearProgressIndicator(
                minHeight: 2,
                semanticsLabel: 'Searching',
              ),
            );
          }
          final count = page.total == 1 ? '1 place' : '${page.total} places';
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              OneSpaceTokens.s4,
              OneSpaceTokens.s2,
              OneSpaceTokens.s4,
              OneSpaceTokens.s1,
            ),
            child: Semantics(
              liveRegion: true,
              child: Text(
                query.isEmpty
                    ? '$count on One'.toUpperCase()
                    : '$count for "$query"'.toUpperCase(),
                style: oneText.eyebrow,
              ),
            ),
          );
        }
        final listing = page.items[i - 1];
        return ListingTile(
          key: ValueKey(listing.id),
          title: listing.title,
          place: listing.location.shortLabel,
          eyebrow: listing.eyebrow,
          imageUrl: listing.coverImage?.url,
          priceLabel: listing.priceLabel,
          priceUnit: listing.price?.unit,
          ratingLabel: listing.rating?.label,
          ratingCount: listing.rating?.count,
          onTap: () => context.go(Routes.listing(listing.id)),
        );
      },
    );
  }
}
