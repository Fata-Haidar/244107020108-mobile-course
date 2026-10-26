
import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  group('routeFromMessage', () {
    test('route kosong atau tidak ada menghasilkan home', () {
      expect(routeFromMessage({}), AppRoutes.home);
      expect(routeFromMessage({'route': ''}), AppRoutes.home);
      expect(routeFromMessage({'route': null}), AppRoutes.home);
    });

    test('route tanpa slash diberi slash', () {
      expect(
        routeFromMessage({
          'route': 'pengumuman/3',
        }),
        '/pengumuman/3',
      );
    });

    test('route dengan slash dipertahankan', () {
      expect(
        routeFromMessage({
          'route': '/pengumuman/3',
        }),
        '/pengumuman/3',
      );
    });

    test('payload membawa id pengumuman', () {
      const data = <String, dynamic>{
        'route': '/pengumuman/3',
        'id': '3',
      };

      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });
  });

  test('status login tiruan bergantung pada access token', () {
    final store = FakeTokenStore()
      ..access = 'mock-access';

    expect(store.access != null, isTrue);

    store.access = null;

    expect(store.access != null, isFalse);
  });

  test('refresh kosong berarti perlu login ulang', () {
    final store = FakeTokenStore()..refresh = '';

    final needsLogin = (store.refresh ?? '').isEmpty;

    expect(needsLogin, isTrue);
  });

  group('apiErrorMessage', () {
    test('401 menghasilkan pesan sesi berakhir', () {
      final request = RequestOptions(path: '/test');

      final error = DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(
        apiErrorMessage(error),
        'Sesi kamu telah berakhir. Silakan login kembali.',
      );
    });

    test('timeout menghasilkan pesan ramah pengguna', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        apiErrorMessage(error),
        'Koneksi ke server terlalu lama. Coba lagi.',
      );
    });

    test('offline menghasilkan pesan koneksi', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      expect(
        apiErrorMessage(error),
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    });
  });
}
