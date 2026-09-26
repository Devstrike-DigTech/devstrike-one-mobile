import 'package:meta/meta.dart';
import 'package:one_api/src/json.dart';

/// A store the signed-in person can manage: an organisation's instance of a
/// product (a hotel on HotelOS, a kitchen on EateryOS).
///
/// One item of `GET /api/v1/accounts/stores`, which lists stores across all
/// of the person's organisations.
@immutable
class OneStore {
  /// Creates a store.
  const OneStore({
    required this.id,
    required this.name,
    required this.productKey,
    required this.productName,
    required this.organizationId,
    required this.organizationName,
    required this.role,
    this.slug,
    this.city,
    this.status = 'active',
    this.productSiteUrl,
    this.listingCount = 0,
    this.locationCount = 0,
  });

  /// Parses one item.
  factory OneStore.fromJson(Json json) {
    final r = JsonReader(json);
    final product = JsonReader(r.object('product'));
    final org = JsonReader(r.object('organization'));
    return OneStore(
      id: r.string('id'),
      name: r.string('name'),
      slug: r.stringOrNull('slug'),
      city: r.stringOrNull('city'),
      status: r.stringOrNull('status') ?? 'active',
      productKey: product.string('key'),
      productName: product.string('name'),
      productSiteUrl: product.stringOrNull('siteUrl'),
      listingCount: r.integerOrNull('listingCount') ?? 0,
      locationCount: r.integerOrNull('locationCount') ?? 0,
      organizationId: org.string('id'),
      organizationName: org.string('name'),
      role: r.string('role'),
    );
  }

  /// One store id (== the product's tenant id after linking).
  final String id;

  /// Display name.
  final String name;

  /// URL slug.
  final String? slug;

  /// City.
  final String? city;

  /// `active`, `suspended`...
  final String status;

  /// Product key, e.g. `hotel`.
  final String productKey;

  /// Product display name, e.g. "HotelOS".
  final String productName;

  /// The product's site (where its admin lives).
  final String? productSiteUrl;

  /// Listings the store publishes on the marketplace.
  final int listingCount;

  /// Physical locations.
  final int locationCount;

  /// Owning organisation.
  final String organizationId;

  /// Owning organisation's name.
  final String organizationName;

  /// The person's role in that organisation (owner, admin, finance, member).
  final String role;

  /// Whether the store is live.
  bool get isActive => status == 'active';

  @override
  bool operator ==(Object other) => other is OneStore && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OneStore($id, $name)';
}
