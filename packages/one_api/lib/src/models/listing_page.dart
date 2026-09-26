import 'package:meta/meta.dart';
import 'package:one_api/src/json.dart';
import 'package:one_api/src/models/listing.dart';

/// One page of search results.
@immutable
class ListingPage {
  /// Creates a page.
  const ListingPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  /// Parses `{ items, total, page, pageSize }`.
  factory ListingPage.fromJson(Json json) {
    final r = JsonReader(json);
    final items = r
        .objects('items')
        .map(Listing.fromJson)
        .toList(growable: false);
    return ListingPage(
      items: items,
      total: r.integerOrNull('total') ?? items.length,
      page: r.integerOrNull('page') ?? 1,
      pageSize: r.integerOrNull('pageSize') ?? items.length,
    );
  }

  /// Results on this page.
  final List<Listing> items;

  /// Total matches.
  final int total;

  /// 1-based page number.
  final int page;

  /// Requested page size.
  final int pageSize;

  /// Whether more pages exist.
  bool get hasMore => page * pageSize < total;

  /// Whether nothing matched.
  bool get isEmpty => items.isEmpty;
}
