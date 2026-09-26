import 'package:flutter/foundation.dart';
import 'package:one_api/src/json.dart';
import 'package:one_core/one_core.dart';

/// A marketplace listing as core-api serves it.
///
/// Products publish the One Listing v1 contract
/// (`contracts/schemas/one-listing.json`); core-api normalises it and the
/// marketplace endpoints return a projection of it: a *card* in search
/// results and a *detail* from `GET /marketplace/listings/{id}`. This class
/// reads both. The detail-only fields ([description], [images],
/// [attributes], [phone], [whatsapp], [productSiteUrl], [updatedAt]) are
/// empty or `null` on cards.
///
/// Mapping from One Listing v1: `title` is served as `name`, `location.*`
/// flattened onto the listing with `location.point` as `geo`, `price` as
/// `priceFrom { amountMinor, currency, unit }`, and `actions[0]` as
/// `primaryAction`.
@immutable
class Listing {
  /// Creates a listing.
  const Listing({
    required this.id,
    required this.productKey,
    required this.productName,
    required this.category,
    required this.title,
    required this.location,
    this.storeName,
    this.slug,
    this.subcategories = const [],
    this.summary,
    this.description,
    this.price,
    this.rating,
    this.images = const [],
    this.tags = const [],
    this.primaryAction,
    this.actions = const [],
    this.bookingUrl,
    this.attributes = const {},
    this.phone,
    this.whatsapp,
    this.productSiteUrl,
    this.distanceKm,
    this.updatedAt,
  });

  /// Parses a search card or a detail body; throws [FormatException] (with
  /// the field name) on contract drift.
  factory Listing.fromJson(Json json) {
    final r = JsonReader(json);
    final actions = r
        .objects('actions')
        .map(ListingAction.fromJson)
        .toList(growable: false);
    final primary = r.objectOrNull('primaryAction');
    final images = r
        .objects('images')
        .map(ListingImage.fromJson)
        .toList(growable: false);
    final image = r.objectOrNull('image');
    return Listing(
      id: r.string('id'),
      productKey: r.string('productKey'),
      productName: r.stringOrNull('productName'),
      storeName: r.stringOrNull('storeName'),
      slug: r.stringOrNull('slug'),
      title: r.string('name'),
      category: r.string('category'),
      subcategories: r.strings('subcategories'),
      summary: r.stringOrNull('summary'),
      description: r.stringOrNull('description'),
      location: ListingLocation.fromJson(json),
      price: switch (r.objectOrNull('priceFrom')) {
        null => null,
        final p => ListingPrice.fromJson(p),
      },
      rating: switch (r.objectOrNull('rating')) {
        null => null,
        final p => ListingRating.fromJson(p),
      },
      images: images.isNotEmpty
          ? images
          : [if (image != null) ListingImage.fromJson(image)],
      tags: r.strings('tags'),
      primaryAction: primary != null
          ? ListingAction.fromJson(primary)
          : (actions.isEmpty ? null : actions.first),
      actions: actions,
      bookingUrl: r.stringOrNull('bookingUrl'),
      attributes: switch (r.objectOrNull('attributes')) {
        null => const {},
        final a => Map.unmodifiable(a),
      },
      phone: r.stringOrNull('phone'),
      whatsapp: r.stringOrNull('whatsapp'),
      productSiteUrl: r.stringOrNull('productSiteUrl'),
      distanceKm: r.numberOrNull('distanceKm'),
      updatedAt: json['updatedAt'] == null ? null : r.dateTime('updatedAt'),
    );
  }

  /// One's id for the listing (UUIDv7).
  final String id;

  /// Registered product key, e.g. `hotel`.
  final String productKey;

  /// Display name of the product ("HotelOS").
  final String? productName;

  /// Name of the store (the business) that owns the listing.
  final String? storeName;

  /// URL slug on the marketplace web.
  final String? slug;

  /// Dotted category path, industry first: `lodging.hotel`.
  final String category;

  /// Extra category paths.
  final List<String> subcategories;

  /// Title (served as `name`).
  final String title;

  /// One-line summary.
  final String? summary;

  /// Long description (plain text; detail only).
  final String? description;

  /// Where it is.
  final ListingLocation location;

  /// Starting price, or `null` when the product does not publish one.
  final ListingPrice? price;

  /// Rating, or `null` when there are no reviews yet.
  final ListingRating? rating;

  /// Images (all of them on detail, the cover on cards).
  final List<ListingImage> images;

  /// Free-form tags.
  final List<String> tags;

  /// How to continue in the product: its first action, else its booking page.
  final ListingAction? primaryAction;

  /// Every action (detail only).
  final List<ListingAction> actions;

  /// The product's booking page for this listing.
  final String? bookingUrl;

  /// Product-specific facts (flat scalars; detail only).
  final Map<String, Object?> attributes;

  /// Contact phone (detail only).
  final String? phone;

  /// WhatsApp number (detail only).
  final String? whatsapp;

  /// The product's public site.
  final String? productSiteUrl;

  /// Distance from the `near` point of a search, in km.
  final double? distanceKm;

  /// Last change at the source (detail only).
  final DateTime? updatedAt;

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

/// Where a listing is (flat fields on the listing, `geo` for coordinates).
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

  /// Reads the location fields from a listing body.
  factory ListingLocation.fromJson(Json json) {
    final r = JsonReader(json);
    final geo = r.objectOrNull('geo');
    return ListingLocation(
      address: r.stringOrNull('address'),
      area: r.stringOrNull('area'),
      city: r.string('city'),
      state: r.stringOrNull('state'),
      country: r.string('country'),
      point: geo == null
          ? null
          : (
              lat: JsonReader(geo).number('lat'),
              lng: JsonReader(geo).number('lng'),
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

  /// Parses `{ amountMinor, currency, unit? }`.
  factory ListingPrice.fromJson(Json json) {
    final r = JsonReader(json);
    return ListingPrice(
      from: Money(r.integer('amountMinor'), r.string('currency')),
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

  /// Parses `{ kind, url, label? }`. Only http(s) URLs are accepted, so a
  /// listing can never make the app open another scheme.
  factory ListingAction.fromJson(Json json) {
    final r = JsonReader(json);
    final url = Uri.tryParse(r.string('url'));
    if (url == null ||
        !(url.isScheme('https') || url.isScheme('http')) ||
        url.host.isEmpty) {
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
