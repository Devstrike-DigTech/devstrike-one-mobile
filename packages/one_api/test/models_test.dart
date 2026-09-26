import 'package:flutter_test/flutter_test.dart';
import 'package:one_api/one_api.dart';
import 'package:one_core/one_core.dart';

import 'fixtures/listings.dart';

/// [base] with [key] replaced (a function, so the literal stays mutable).
Map<String, Object?> _with(
  Map<String, Object?> base,
  String key,
  Object? value,
) => {...base, key: value};

void main() {
  group('Listing.fromJson', () {
    test('parses a search card', () {
      final l = Listing.fromJson(palmwineCard);
      expect(l.id, '01926d4e-8a4b-7c3e-9f00-5a1b2c3d4e5f');
      expect(l.title, 'The Palmwine House');
      expect(l.productLabel, 'HotelOS');
      expect(l.categoryLabel, 'Hotel');
      expect(l.location.shortLabel, 'Lekki Phase 1, Lagos');
      expect(l.location.point!.lat, closeTo(6.4474, 1e-9));
      expect(l.price!.from, const Money.ngn(4500000));
      expect(l.price!.from.format(), '₦45,000');
      expect(l.price!.unit, 'night');
      expect(l.rating!.label, '4.6');
      expect(l.coverImage!.alt, 'Lobby with palm-frond screens');
      expect(l.primaryAction!.kind, ListingActionKind.book);
      expect(l.primaryAction!.url.host, 'palmwine.hotelos.ng');
      expect(l.description, isNull);
      expect(l.updatedAt, isNull);
    });

    test('parses a detail body', () {
      final l = Listing.fromJson(palmwineDetail);
      expect(l.images, hasLength(2));
      expect(l.actions, hasLength(2));
      expect(l.attributes['rooms'], 24);
      expect(l.phone, '+2348030000001');
      expect(l.updatedAt, DateTime.utc(2026, 9, 20, 10, 15));
    });

    test('parses a minimal card', () {
      final l = Listing.fromJson(minimalCard);
      expect(l.price, isNull);
      expect(l.rating, isNull);
      expect(l.images, isEmpty);
      expect(l.primaryAction, isNull);
      expect(l.productLabel, 'Salon');
      expect(l.categoryLabel, 'Hair Salon');
      expect(l.location.shortLabel, 'Abuja');
      expect(l.distanceKm, 2.4);
    });

    test('accepts amounts sent as strings (BIGINT)', () {
      final l = Listing.fromJson(
        _with(palmwineCard, 'priceFrom', {
          'amountMinor': '4500000',
          'currency': 'NGN',
        }),
      );
      expect(l.price!.from.minor, 4500000);
    });

    test('rejects a missing required field with its name', () {
      final broken = Map.of(palmwineCard)..remove('name');
      expect(
        () => Listing.fromJson(broken),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('"name"'),
          ),
        ),
      );
    });

    test('rejects a non-http action url', () {
      final broken = _with(minimalCard, 'primaryAction', {
        'kind': 'book',
        'url': 'javascript:alert(1)',
      });
      expect(() => Listing.fromJson(broken), throwsFormatException);
    });

    test('unknown action kinds degrade to view', () {
      final odd = _with(minimalCard, 'primaryAction', {
        'kind': 'teleport',
        'url': 'https://x.test',
      });
      expect(Listing.fromJson(odd).primaryAction!.kind, ListingActionKind.view);
    });

    test('falls back to the first action when there is no primary action', () {
      final l = Listing.fromJson(_with(palmwineDetail, 'primaryAction', null));
      expect(l.primaryAction!.label, 'Book a room');
    });
  });

  test('ListingPage parses items, paging and facets', () {
    final page = ListingPage.fromJson(const {
      'items': [palmwineCard],
      'total': 45,
      'page': 2,
      'pageSize': 12,
      'facets': {
        'cities': [
          {'name': 'Lagos', 'count': 30},
          {'name': 'Abuja', 'count': 15},
        ],
        'categories': [
          {'name': 'lodging.hotel', 'count': 45},
        ],
      },
    });
    expect(page.items.single.title, 'The Palmwine House');
    expect(page.hasMore, isTrue);
    expect(page.cities.first, (name: 'Lagos', count: 30));
    expect(page.categories.single.count, 45);
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

  test('HealthStatus reads liveness and readiness bodies', () {
    expect(
      HealthStatus.fromJson(const {'status': 'ok', 'role': 'api'}).role,
      'api',
    );
    final ready = HealthStatus.fromJson(const {
      'status': 'ok',
      'checks': {'database': 'ok', 'redis': 'down'},
    });
    expect(ready.checks['redis'], 'down');
    expect(ready.isOk, isFalse);
  });
}
