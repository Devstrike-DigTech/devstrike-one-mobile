import 'package:meta/meta.dart';
import 'package:one_api/src/json.dart';
import 'package:one_api/src/models/listing.dart';

/// A facet bucket: a city or category and how many listings it holds.
typedef FacetCount = ({String name, int count});

/// One page of search results, with facets for narrowing the search.
@immutable
class ListingPage {
  /// Creates a page.
  const ListingPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    this.cities = const [],
    this.categories = const [],
  });

  /// Parses `{ items, total, page, pageSize, facets: { cities, categories } }`.
  factory ListingPage.fromJson(Json json) {
    final r = JsonReader(json);
    final items = r
        .objects('items')
        .map(Listing.fromJson)
        .toList(growable: false);
    final facets = r.objectOrNull('facets');
    List<FacetCount> buckets(String key) => facets == null
        ? const []
        : JsonReader(facets)
              .objects(key)
              .map(
                (b) => (
                  name: JsonReader(b).string('name'),
                  count: JsonReader(b).integer('count'),
                ),
              )
              .toList(growable: false);
    return ListingPage(
      items: items,
      total: r.integerOrNull('total') ?? items.length,
      page: r.integerOrNull('page') ?? 1,
      pageSize: r.integerOrNull('pageSize') ?? items.length,
      cities: buckets('cities'),
      categories: buckets('categories'),
    );
  }

  /// Results on this page.
  final List<Listing> items;

  /// Total matches.
  final int total;

  /// 1-based page number.
  final int page;

  /// Page size the server applied.
  final int pageSize;

  /// Cities with matches (ignoring the city filter), most first.
  final List<FacetCount> cities;

  /// Categories with matches (ignoring the category filter), most first.
  final List<FacetCount> categories;

  /// Whether more pages exist.
  bool get hasMore => page * pageSize < total;

  /// Whether nothing matched.
  bool get isEmpty => items.isEmpty;
}
