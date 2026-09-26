import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:one_api/one_api.dart';
import 'package:one_app/app/providers.dart';

/// The search the person has typed (already debounced by the screen).
final searchTextProvider = NotifierProvider<SearchTextNotifier, String>(
  SearchTextNotifier.new,
  name: 'searchText',
);

/// Holds the current search text.
class SearchTextNotifier extends Notifier<String> {
  @override
  String build() => '';

  /// Replaces the search text.
  void set(String text) => state = text.trim();
}

/// Results for [searchTextProvider]. An empty search lists what is on the
/// marketplace (the API orders by relevance, then recency).
///
/// Failures surface as `AsyncError` carrying a `OneFailure`; Riverpod's
/// automatic retry is off so the error state (and its retry button) shows
/// immediately instead of spinning while offline.
final FutureProvider<ListingPage> searchResultsProvider =
    FutureProvider.autoDispose<ListingPage>(
      (ref) async {
        final text = ref.watch(searchTextProvider);
        final api = ref.watch(apiClientProvider);
        final result = await api.searchListings(ListingQuery(text: text));
        return result.unwrap();
      },
      retry: (_, _) => null,
      name: 'searchResults',
    );

/// One listing by id.
final FutureProviderFamily<Listing, String> listingProvider = FutureProvider
    .autoDispose
    .family<Listing, String>(
      (ref, id) async {
        final result = await ref.watch(apiClientProvider).getListing(id);
        return result.unwrap();
      },
      retry: (_, _) => null,
      name: 'listing',
    );
