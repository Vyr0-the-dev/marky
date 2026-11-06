import 'package:dio/dio.dart';

/// Returns a [Response] that represents an HTML response with the given body.
Response<String> htmlResponse(
  RequestOptions options, {
  required String body,
  int statusCode = 200,
}) {
  return Response<String>(
    requestOptions: options,
    statusCode: statusCode,
    headers: Headers.fromMap(<String, List<String>>{
      'content-type': <String>['text/html'],
    }),
    data: body,
  );
}

/// Returns a [Response] that represents a JSON response with the given body.
///
/// [body] should be a valid JSON string. The `content-type` header is set
/// to `application/json`.
Response<String> jsonResponse(
  RequestOptions options, {
  required String body,
  int statusCode = 200,
}) {
  return Response<String>(
    requestOptions: options,
    statusCode: statusCode,
    headers: Headers.fromMap(<String, List<String>>{
      'content-type': <String>['application/json'],
    }),
    data: body,
  );
}

/// An [Interceptor] that returns pre-baked GET responses based on the
/// request URL. No real network calls are made.
///
/// Use [fixtures] to map exact URL strings to [Response] builders.
/// Use [delayedFixtures] to simulate slow responses: the key must also
/// exist in [fixtures], and the associated future completes before the
/// fixture is resolved.
class FixtureInterceptor extends Interceptor {
  FixtureInterceptor({
    required Map<String, Response<String> Function(RequestOptions)> fixtures,
    Map<String, Future<void>>? delayedFixtures,
  })  : _fixtures = fixtures,
        _delayedFixtures = delayedFixtures ?? <String, Future<void>>{};

  final Map<String, Response<String> Function(RequestOptions)> _fixtures;
  final Map<String, Future<void>> _delayedFixtures;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String key = options.uri.toString();

    if (_delayedFixtures.containsKey(key)) {
      _delayedFixtures[key]!.then((_) {
        final Response<String> Function(RequestOptions)? builder =
            _fixtures[key];
        if (builder == null) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'No fixture for GET $key',
            ),
          );
          return;
        }
        handler.resolve(builder(options));
      });
      return;
    }

    final Response<String> Function(RequestOptions)? builder = _fixtures[key];

    if (builder == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'No fixture for GET $key',
        ),
      );
      return;
    }

    handler.resolve(builder(options));
  }
}
