import 'package:flutter_test/flutter_test.dart';
import 'package:one_api/one_api.dart';
import 'package:one_core/one_core.dart';

import 'fixtures/listings.dart';

void main() {
  group('Listing.fromJson', () {
    test('parses a full One Listing v1 body', () {
      final l = Listing.fromJson(palmwineListing);
      expect(l.id, '01926d4e-8a4b-7c3e-9f00-5a1b2c3d4e5f');
      expect(l.productLabel, 'HotelOS');
      expect(l.categoryLabel, 'Hotel');
      expect(l.location.shortLabel, 'Lekki Phase 1, Lagos');
      expect(l.location.point!.lat, closeTo(6.4474, 1e-9));
      // BIGINT amounts may arrive as strings.
      expect(l.price!.from, const Money.ngn(4500000));
      expect(l.price!.from.format(), '₦45,000');
      expect(l.price!.unit, 'night');
      expect(l.rating!.label, '4.6');
      expect(l.coverImage!.alt, 'Lobby with palm-frond screens');
      expect(l.primaryAction!.kind, ListingActionKind.book);
      expect(l.primaryAction!.url.host, 'palmwine.hotelos.ng');
      expect(l.attributes['rooms'], 24);
      expect(
        l.updatedAt.isUtc || l.updatedAt.timeZoneOffset == Duration.zero,
        isTrue,
      );
    });

    test('parses a minimal body with null price and rating', () {
      final l = Listing.fromJson(minimalListing);
      expect(l.price, isNull);
      expect(l.rating, isNull);
      expect(l.images, isEmpty);
      expect(l.productLabel, 'Salon');
      expect(l.categoryLabel, 'Hair Salon');
      expect(l.location.shortLabel, 'Abuja');
    });

    test('rejects a missing required field with its name', () {
      final broken = Map.of(palmwineListing)..remove('title');
      expect(
        () => Listing.fromJson(broken),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('"title"'),
          ),
        ),
      );
    });

    test('rejects a non-http action url', () {
      final broken = Map.of(minimalListing)
        ..['actions'] = [
          {'kind': 'book', 'url': 'javascript:alert(1)'},
        ];
      expect(() => Listing.fromJson(broken), throwsFormatException);
    });

    test('unknown action kinds degrade to view and unknown status hides', () {
      final odd = Map.of(minimalListing)
        ..['actions'] = [
          {'kind': 'teleport', 'url': 'https://x.test'},
        ]
        ..['status'] = 'archived';
      final l = Listing.fromJson(odd);
      expect(l.primaryAction!.kind, ListingActionKind.view);
      expect(l.status, ListingStatus.hidden);
    });
  });

  test('ListingPage knows when more results exist', () {
    final page = ListingPage.fromJson(const {
      'items': [palmwineListing],
      'total': 45,
      'page': 2,
      'pageSize': 20,
    });
    expect(page.items.single.title, 'The Palmwine House');
    expect(page.hasMore, isTrue);
    expect(ListingPage.fromJson(const {'items': <Object?>[]}).isEmpty, isTrue);
  });

  test('ListingQuery omits empty parameters', () {
    expect(const ListingQuery().toQueryParameters(), {
      'page': 1,
      'pageSize': 20,
    });
    expect(
      const ListingQuery(
        text: '  pool  ',
        city: 'Lagos',
        category: 'lodging',
      ).toQueryParameters(),
      {
        'q': 'pool',
        'category': 'lodging',
        'city': 'Lagos',
        'page': 1,
        'pageSize': 20,
      },
    );
  });
}
