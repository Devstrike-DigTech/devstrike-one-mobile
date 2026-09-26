import 'dart:async';

import 'package:dio/dio.dart';
import 'package:one_api/src/api_paths.dart';
import 'package:one_api/src/failure_mapper.dart';
import 'package:one_api/src/json.dart';
import 'package:one_api/src/models/health_status.dart';
import 'package:one_api/src/models/listing.dart';
import 'package:one_api/src/models/listing_page.dart';
import 'package:one_api/src/models/listing_query.dart';
import 'package:one_api/src/models/store.dart';
import 'package:one_core/one_core.dart';

/// Supplies a bearer token for a request, or `null` to send none. Called per
/// request so a session can refresh an expiring token first.
typedef AccessTokenProvider = Future<String?> Function();

/// Client for the parts of core-api the apps use today.
///
/// Every call returns a [Result]; nothing throws for expected failures
/// (offline, 404, 5xx, malformed body).
class OneApiClient {
  /// Creates a client for [baseUrl].
  ///
  /// Pass [dio] to share an instance or to install a mock adapter in tests;
  /// the client adds its own interceptors to it either way.
  OneApiClient({
    required Uri baseUrl,
    Dio? dio,
    AccessTokenProvider? accessToken,
    String clientName = 'one_mobile',
    Duration timeout = const Duration(seconds: 15),
  }) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl.toString()
      ..connectTimeout = timeout
      ..receiveTimeout = timeout
      ..sendTimeout = timeout
      ..responseType = ResponseType.json
      ..headers.addAll({
        'Accept': 'application/json',
        'X-One-Client': clientName,
      });
    _dio.interceptors.addAll([
      if (accessToken != null) _AuthInterceptor(accessToken),
      _LogInterceptor(),
    ]);
  }

  final Dio _dio;
  static final Logger _log = Logger('one_api');

  /// The underlying Dio instance (for adapters in tests).
  Dio get dio => _dio;

  /// `GET /api/v1/health`: the process answers.
  Future<Result<HealthStatus>> health() =>
      _get(OneApiPaths.health, HealthStatus.fromJson);

  /// `GET /api/v1/health/ready`: database and Redis answer too. A 503 here
  /// is a `ServerFailure` whose `details` hold the failing checks.
  Future<Result<HealthStatus>> ready() =>
      _get(OneApiPaths.healthReady, HealthStatus.fromJson);

  /// `GET /api/v1/marketplace/search`.
  Future<Result<ListingPage>> searchListings(ListingQuery query) => _get(
    OneApiPaths.marketplaceSearch,
    ListingPage.fromJson,
    query: query.toQueryParameters(),
  );

  /// `GET /api/v1/marketplace/listings/{id}`.
  Future<Result<Listing>> getListing(String id) =>
      _get(OneApiPaths.marketplaceListing(id), Listing.fromJson);

  /// `GET /api/v1/accounts/stores` (needs a signed-in person): every store
  /// the person can manage, across their organisations.
  Future<Result<List<OneStore>>> myStores() => _getRaw(
    OneApiPaths.myStores,
    (body) => switch (body) {
      final List<Object?> list => [
        for (final (i, item) in list.indexed)
          if (item is Map<String, Object?>)
            OneStore.fromJson(item)
          else
            throw FormatException('stores[$i] must be an object'),
      ],
      _ => throw const FormatException(
        'Expected a JSON list from ${OneApiPaths.myStores}',
      ),
    },
  );

  Future<Result<T>> _get<T>(
    String path,
    T Function(Json json) parse, {
    Map<String, Object>? query,
  }) => _getRaw(
    path,
    (body) => body is Map<String, Object?>
        ? parse(body)
        : throw FormatException('Expected a JSON object from $path'),
    query: query,
  );

  Future<Result<T>> _getRaw<T>(
    String path,
    T Function(Object? body) parse, {
    Map<String, Object>? query,
  }) async {
    try {
      final response = await _dio.get<Object?>(path, queryParameters: query);
      return Ok(parse(response.data));
    } on DioException catch (e) {
      final failure = failureFromDio(e);
      _log.warning('GET $path failed: ${failure.code}', e.error);
      return Err(failure);
    } on FormatException catch (e, st) {
      _log.severe('GET $path returned an unexpected shape', e, st);
      return Err(UnexpectedFailure(cause: e));
    }
  }

  /// Closes the underlying connections.
  void close() => _dio.close();
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._token);

  final AccessTokenProvider _token;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _token();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } on Object catch (e) {
      // A token refresh failure must not crash the request pipeline: send the
      // request anonymously and let the API answer 401 where auth is needed.
      Logger('one_api.auth').warning('Could not obtain an access token', e);
      handler.next(options);
    }
  }
}

class _LogInterceptor extends Interceptor {
  final Logger _log = Logger('one_api.http');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['one_started'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _log.fine(
      () =>
          '${response.requestOptions.method} ${response.requestOptions.uri.path} '
          '${response.statusCode} ${_elapsed(response.requestOptions)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.fine(
      () =>
          '${err.requestOptions.method} ${err.requestOptions.uri.path} '
          '${err.response?.statusCode ?? err.type.name} ${_elapsed(err.requestOptions)}',
    );
    handler.next(err);
  }

  String _elapsed(RequestOptions o) {
    final started = o.extra['one_started'];
    return started is DateTime
        ? '${DateTime.now().difference(started).inMilliseconds}ms'
        : '';
  }
}
