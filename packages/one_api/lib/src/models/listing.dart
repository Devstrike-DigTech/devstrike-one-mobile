import 'package:flutter/foundation.dart';
import 'package:one_api/src/json.dart';
import 'package:one_core/one_core.dart';

/// A marketplace listing as served by core-api: the One Listing v1 contract
/// (`contracts/schemas/one-listing.json`) plus the fields One adds when it
/// ingests a listing ([id] is One's UUIDv7, [externalId] the product's own
/// id, [storeId], and the display name of the product).
@immutable
class Listing {
  /// Creates a listing.
  const Listing({
    required this.id,
    required this.productKey,
    required this.category,
    required this.title,
    required this.location,
    required this.actions,
    required this.updatedAt,
    this.externalId,
    this.tenantId,
    this.storeId,
    this.productName,
    this.summary,
    this.description,
    this.price,
    this.rating,
    this.images = const [],
    this.tags = const [],
    this.attributes = const {},
    this.status = ListingStatus.active,
  });

  /// Parses a listing; throws [FormatException] on contract drift.
  factory Listing.fromJson(Json json) {
    final r = JsonReader(json);
    final product = r.objectOrNull('product');
    return Listing(
      id: r.string('id'),
      externalId: r.stringOrNull('externalId'),
      productKey: r.string('productKey'),
      productName:
          r.stringOrNull('productName') ??
          (product == null ? null : JsonReader(product).stringOrNull('name')),
      tenantId: r.stringOrNull('tenantId'),
      storeId: r.stringOrNull('storeId'),
      category: r.string('category'),
      title: r.string('title'),
      summary: r.stringOrNull('summary'),
      description: r.stringOrNull('description'),
      location: ListingLocation.fromJson(r.object('location')),
      price: switch (r.objectOrNull('price')) {
        null => null,
        final p => ListingPrice.fromJson(p),
      },
      rating: switch (r.objectOrNull('rating')) {
        null => null,
        final p => ListingRating.fromJson(p),
      },
      images: r
          .objects('images')
          .map(ListingImage.fromJson)
          .toList(growable: false),
      tags: r.strings('tags'),
      actions: r
          .objects('actions')
          .map(ListingAction.fromJson)
          .toList(growable: false),
      attributes: switch (r.objectOrNull('attributes')) {
        null => const {},
        final a => Map.unmodifiable(a),
      },
      status: ListingStatus.parse(r.stringOrNull('status')),
      updatedAt: r.dateTime('updatedAt'),
    );
  }

  /// One's id for the listing (UUIDv7).
  final String id;

  /// The product's own id for the listing.
  final String? externalId;

  /// Registered product key, e.g. `hotel`.
  final String productKey;

  /// Display name of the product ("HotelOS"), when the API includes it.
  final String? productName;

  /// The product tenant (== One store after linking).
  final String? tenantId;

  /// One store id.
  final String? storeId;

  /// Dotted category path, industry first: `lodging.hotel`.
  final String category;

  /// Title.
  final String title;

  /// One-line summary.
  final String? summary;

  /// Long description (plain text).
  final String? description;

  /// Where it is.
  final ListingLocation location;

  /// Starting price, or `null` when the product does not publish one.
  final ListingPrice? price;

  /// Rating, or `null` when there are no reviews yet.
  final ListingRating? rating;

  /// Images (https only per contract).
  final List<ListingImage> images;

  /// Free-form tags.
  final List<String> tags;

  /// Deep links into the product's own flow; the first is the primary one.
  final List<ListingAction> actions;

  /// Product-specific facts (flat scalars).
  final Map<String, Object?> attributes;

  /// Visibility.
  final ListingStatus status;

  /// Last change at the source.
  final DateTime updatedAt;

  /// The primary action, if any.
  ListingAction? get primaryAction => actions.isEmpty ? null : actions.first;

  /// The first image, if any.
  ListingImage? get coverImage => images.isEmpty ? null : images.first;

  /// Human label for the category leaf: `lodging.hotel` -> "Hotel".
  String get categoryLabel => _titleCase(category.split('.').last);

  /// Product display name, falling back to a title-cased key.
  String get productLabel => productName ?? _titleCase(productKey);

  static String _titleCase(String s) => s
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  bool operator ==(Object other) =>
      other is Listing && other.id == id && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, updatedAt);

  @override
  String toString() => 'Listing($id, $title)';
}

/// Listing visibility.
enum ListingStatus {
  /// Shown in the marketplace.
  active,

  /// Hidden by the business or by moderation.
  hidden;

  /// Parses a status; unknown values are treated as [hidden] (fail closed).
  static ListingStatus parse(String? value) =>
      value == null || value == 'active' ? active : hidden;
}

/// Where a listing is.
@immutable
class ListingLocation {
  /// Creates a location.
  const ListingLocation({
    required this.city,
    required this.country,
    this.address,
    this.area,
    this.state,
    this.point,
  });

  /// Parses a location.
  factory ListingLocation.fromJson(Json json) {
    final r = JsonReader(json);
    final point = r.objectOrNull('point');
    return ListingLocation(
      address: r.stringOrNull('address'),
      area: r.stringOrNull('area'),
      city: r.string('city'),
      state: r.stringOrNull('state'),
      country: r.string('country'),
      point: point == null
          ? null
          : (
              lat: JsonReader(point).number('lat'),
              lng: JsonReader(point).number('lng'),
            ),
    );
  }

  /// Street address.
  final String? address;

  /// Neighbourhood ("Lekki Phase 1").
  final String? area;

  /// City.
  final String city;

  /// State or region.
  final String? state;

  /// ISO 3166-1 alpha-2.
  final String country;

  /// Coordinates.
  final ({double lat, double lng})? point;

  /// "Lekki Phase 1, Lagos" (area and city, without repeating the city).
  String get shortLabel => [
    if (area != null && area!.isNotEmpty && area != city) area!,
    city,
  ].join(', ');
}

/// Starting price.
@immutable
class ListingPrice {
  /// Creates a price.
  const ListingPrice({required this.from, this.unit});

  /// Parses `{ fromMinor, currency, unit? }`.
  factory ListingPrice.fromJson(Json json) {
    final r = JsonReader(json);
    return ListingPrice(
      from: Money(r.integer('fromMinor'), r.string('currency')),
      unit: r.stringOrNull('unit'),
    );
  }

  /// Lowest price.
  final Money from;

  /// Per what: night, hour, session, person...
  final String? unit;
}

/// Average rating.
@immutable
class ListingRating {
  /// Creates a rating.
  const ListingRating({required this.average, required this.count});

  /// Parses `{ average, count }`.
  factory ListingRating.fromJson(Json json) {
    final r = JsonReader(json);
    return ListingRating(
      average: r.number('average'),
      count: r.integer('count'),
    );
  }

  /// 0..5.
  final double average;

  /// Number of reviews.
  final int count;

  /// "4.6".
  String get label => average.toStringAsFixed(1);
}

/// An image.
@immutable
class ListingImage {
  /// Creates an image.
  const ListingImage({required this.url, this.alt});

  /// Parses `{ url, alt? }`.
  factory ListingImage.fromJson(Json json) {
    final r = JsonReader(json);
    return ListingImage(url: r.string('url'), alt: r.stringOrNull('alt'));
  }

  /// https URL.
  final String url;

  /// Alternative text.
  final String? alt;
}

/// What a listing action does.
enum ListingActionKind {
  /// Book a stay, an appointment...
  book,

  /// Order goods or food.
  order,

  /// Ask a question.
  enquire,

  /// Just open the page.
  view;

  /// Parses a kind; unknown kinds degrade to [view].
  static ListingActionKind parse(String value) => ListingActionKind.values
      .firstWhere((k) => k.name == value, orElse: () => ListingActionKind.view);
}

/// A deep link into the product's own public flow.
@immutable
class ListingAction {
  /// Creates an action.
  const ListingAction({required this.kind, required this.url, this.label});

  /// Parses `{ kind, url, label? }`.
  factory ListingAction.fromJson(Json json) {
    final r = JsonReader(json);
    final url = Uri.tryParse(r.string('url'));
    if (url == null || !(url.isScheme('https') || url.isScheme('http'))) {
      throw FormatException('action url must be http(s): ${json['url']}');
    }
    return ListingAction(
      kind: ListingActionKind.parse(r.string('kind')),
      url: url,
      label: r.stringOrNull('label'),
    );
  }

  /// Kind of action.
  final ListingActionKind kind;

  /// Where it goes.
  final Uri url;

  /// Label chosen by the product ("Book a room").
  final String? label;
}
