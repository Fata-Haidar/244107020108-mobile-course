import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Dio client untuk endpoint HTTP tambahan milik aplikasi.
/// Login dan database notifikasi pada versi ini menggunakan Firebase SDK,
/// sehingga tidak ada URL API contoh/placeholder di dalam source code.
Dio buildApiClient({required String baseUrl}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    },
  ));
  return dio;
}
