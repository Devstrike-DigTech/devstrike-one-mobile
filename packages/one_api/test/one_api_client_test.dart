import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:one_api/one_api.dart';
import 'package:one_core/one_core.dart';

import 'fixtures/listings.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late OneApiClient client;
  String? token;

  setUp(() {
    token = null;
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    client = OneApiClient(
      baseUrl: Uri.parse('http://localhost:4100'),
      dio: dio,
      accessToken: () async => token,
    );
  });

  test('health parses the status', () async {
    adapter.onGet(
      OneApiPaths.health,
      (s) => s.reply(200, {'status': 'ok', 'role': 'api'}),
    );
    final health = (await client.health()).unwrap();
    expect(health.isOk, isTrue);
    expect(health.role, 'api');
  });

  test('search sends the query and parses a page', () async {
    adapter.onGet(
      OneApiPaths.marketplaceSearch,
      (s) => s.reply(200, {
        'items': [palmwineCard, minimalCard],
        'total': 2,
        'page': 1,
        'pageSize': 20,
      }),
      queryParameters: {'q': 'lekki', 'page': 1, 'pageSize': 20},
    );
    final page = (await client.searchListings(
      const ListingQuery(text: 'lekki'),
    )).unwrap();
    expect(page.items.map((l) => l.title), [
      'The Palmwine House',
      'Kinks & Co',
    ]);
    expect(page.hasMore, isFalse);
  });

  test('listing detail escapes the id and parses', () async {
    adapter.onGet(
      OneApiPaths.marketplaceListing('abc/1'),
      (s) => s.reply(200, palmwineDetail),
    );
    expect(OneApiPaths.marketplaceListing('abc/1'), endsWith('abc%2F1'));
    final listing = (await client.getListing('abc/1')).unwrap();
    expect(listing.title, 'The Palmwine House');
  });

  test('adds the bearer token when the session has one', () async {
    token = 'tok_123';
    adapter.onGet(
      OneApiPaths.health,
      (s) => s.reply(200, {'status': 'ok'}),
      headers: {'Authorization': 'Bearer tok_123'},
    );
    expect((await client.health()).isOk, isTrue);
  });

  test('404 becomes NotFoundFailure', () async {
    adapter.onGet(
      OneApiPaths.marketplaceListing('missing'),
      (s) => s.reply(404, {
        'statusCode': 404,
        'code': 'NOT_FOUND',
        'message': 'Listing not found',
      }),
    );
    final result = await client.getListing('missing');
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('4xx envelope keeps code and message', () async {
    adapter.onGet(
      OneApiPaths.marketplaceSearch,
      (s) => s.reply(400, {
        'statusCode': 400,
        'code': 'VALIDATION_FAILED',
        'message': ['pageSize must not be greater than 100'],
      }),
      queryParameters: {'page': 1, 'pageSize': 20},
    );
    final failure =
        (await client.searchListings(const ListingQuery())).failureOrNull!
            as ServerFailure;
    expect(failure.statusCode, 400);
    expect(failure.code, 'VALIDATION_FAILED');
    expect(failure.message, 'pageSize must not be greater than 100');
    expect(failure.isRetryable, isFalse);
  });

  test('5xx is retryable and keeps a generic message', () async {
    adapter.onGet(
      OneApiPaths.health,
      (s) =>
          s.reply(503, {'statusCode': 503, 'message': 'db down: pg timeout'}),
    );
    final failure = (await client.health()).failureOrNull! as ServerFailure;
    expect(failure.isRetryable, isTrue);
    expect(failure.message, isNot(contains('pg timeout')));
  });

  test('connection errors become NetworkFailure', () async {
    adapter.onGet(
      OneApiPaths.health,
      (s) => s.throws(
        0,
        DioException.connectionError(
          requestOptions: RequestOptions(path: OneApiPaths.health),
          reason: 'refused',
        ),
      ),
    );
    expect((await client.health()).failureOrNull, isA<NetworkFailure>());
  });

  test('timeouts become TimeoutFailure', () async {
    adapter.onGet(
      OneApiPaths.health,
      (s) => s.throws(
        0,
        DioException.receiveTimeout(
          timeout: const Duration(seconds: 15),
          requestOptions: RequestOptions(path: OneApiPaths.health),
        ),
      ),
    );
    expect((await client.health()).failureOrNull, isA<TimeoutFailure>());
  });

  test('an unexpected body shape becomes UnexpectedFailure', () async {
    adapter.onGet(
      OneApiPaths.marketplaceListing('x'),
      (s) => s.reply(200, {'id': 'x'}),
    );
    expect(
      (await client.getListing('x')).failureOrNull,
      isA<UnexpectedFailure>(),
    );
    adapter.onGet(
      OneApiPaths.health,
      (s) => s.reply(200, ['not', 'an', 'object']),
    );
    expect((await client.health()).failureOrNull, isA<UnexpectedFailure>());
  });
}
