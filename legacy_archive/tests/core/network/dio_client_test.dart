import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marky/core/network/dio_client.dart';

void main() {
  group('DioClient', () {
    test('create returns a Dio instance', () {
      final Dio dio = DioClient.create();
      expect(dio, isA<Dio>());
    });

    test('connectTimeout is 10 seconds', () {
      final Dio dio = DioClient.create();
      expect(
        dio.options.connectTimeout,
        const Duration(seconds: 10),
      );
    });

    test('receiveTimeout is 10 seconds', () {
      final Dio dio = DioClient.create();
      expect(
        dio.options.receiveTimeout,
        const Duration(seconds: 10),
      );
    });

    test('followRedirects is false', () {
      final Dio dio = DioClient.create();
      expect(dio.options.followRedirects, isFalse);
    });
  });
}
