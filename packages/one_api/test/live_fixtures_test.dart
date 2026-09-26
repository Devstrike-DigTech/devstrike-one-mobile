import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:one_api/one_api.dart';
import 'package:one_core/one_core.dart';

/// Bodies captured from the live core-api (One-0 seed data) with curl; see
/// test/fixtures/live/README.md. They pin the client to what the server
/// really sends, not to what we think it sends.
Object? live(String name) =>
    jsonDecode(File('test/fixtures/live/$name.json').readAsStringSync());

void main() {
  late DioAdapter adapter;
  late OneApiClient client;

  setUp(() {
    final dio = Dio();
    adapter = DioAdapter(dio: dio);
    client = OneApiClient(
      baseUrl: Uri.parse('http://localhost:4100'),
      dio: dio,
      accessToken: () async => 'tok',
    );
  });

  test('health and readiness', () async {
    adapter
      ..onGet(OneApiPaths.health, (s) => s.reply(200, live('health')))
      ..onGet(
        OneApiPaths.healthReady,
        (s) => s.reply(200, live('health_ready')),
      );
    expect((await client.health()).unwrap().isOk, isTrue);
    final ready = (await client.ready()).unwrap();
    expect(
      ready.checks.keys,
      containsAll(['database', 'platformDatabase', 'redis']),
    );
  });

  test('search page parses every card and the facets', () async {
    adapter.onGet(
      OneApiPaths.marketplaceSearch,
      (s) => s.reply(200, live('search')),
      queryParameters: {'page': 1, 'pageSize': 4},
    );
    final page = (await client.searchListings(const ListingQuery(pageSize: 4)))
        .unwrap();
    expect(page.items, hasLength(4));
    expect(page.total, greaterThan(4));
    expect(page.hasMore, isTrue);
    expect(page.cities.first.name, 'Lagos');
    for (final l in page.items) {
      expect(l.title, isNotEmpty);
      expect(l.location.city, isNotEmpty);
      expect(l.primaryAction, isNotNull, reason: l.title);
    }
    final first = page.items.first;
    expect(first.price!.from.currency, 'NGN');
    expect(first.coverImage, isNotNull);
  });

  test('an empty search', () async {
    adapter.onGet(
      OneApiPaths.marketplaceSearch,
      (s) => s.reply(200, live('search_empty')),
      queryParameters: {'q': 'zzzzqqq', 'page': 1, 'pageSize': 20},
    );
    final page = (await client.searchListings(
      const ListingQuery(text: 'zzzzqqq'),
    )).unwrap();
    expect(page.isEmpty, isTrue);
  });

  test('listing detail', () async {
    const id = '01a0def0-e2a0-7bc5-8f9d-671067a3ad5e';
    adapter.onGet(
      OneApiPaths.marketplaceListing(id),
      (s) => s.reply(200, live('listing_detail')),
    );
    final l = (await client.getListing(id)).unwrap();
    expect(l.title, 'Lantern Spa, Ikoyi');
    expect(l.productLabel, 'HotelOS');
    expect(l.price!.from, const Money.ngn(3500000));
    expect(l.primaryAction!.label, 'Book a treatment');
    expect(l.description, isNotNull);
    expect(l.attributes['treatmentRooms'], 4);
    expect(l.updatedAt, isNotNull);
  });

  test('missing and malformed listing ids map to failures', () async {
    adapter
      ..onGet(
        OneApiPaths.marketplaceListing('gone'),
        (s) => s.reply(404, live('listing_not_found')),
      )
      ..onGet(
        OneApiPaths.marketplaceListing('not-a-uuid'),
        (s) => s.reply(400, live('listing_bad_id')),
      );
    expect(
      (await client.getListing('gone')).failureOrNull,
      isA<NotFoundFailure>(),
    );
    final bad =
        (await client.getListing('not-a-uuid')).failureOrNull! as ServerFailure;
    expect(bad.code, 'BAD_REQUEST');
  });

  test('my stores across organisations', () async {
    adapter.onGet(
      OneApiPaths.myStores,
      (s) => s.reply(200, live('accounts_stores')),
      headers: {'Authorization': 'Bearer tok'},
    );
    final stores = (await client.myStores()).unwrap();
    expect(stores, isNotEmpty);
    expect(stores.first.name, 'The Palmwine House');
    expect(stores.first.productName, 'HotelOS');
    expect(stores.first.organizationName, 'Kolanut Hospitality');
    expect(stores.first.role, 'owner');
    expect(
      stores.map((s) => s.productKey).toSet(),
      containsAll(['hotel', 'eatery']),
    );
  });

  test('my stores without a session is unauthorised', () async {
    adapter.onGet(
      OneApiPaths.myStores,
      (s) => s.reply(401, {
        'statusCode': 401,
        'code': 'UNAUTHORIZED',
        'message': 'Authentication required',
      }),
      headers: {'Authorization': 'Bearer tok'},
    );
    expect((await client.myStores()).failureOrNull, isA<UnauthorizedFailure>());
  });
}
