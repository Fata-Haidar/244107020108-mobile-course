
import 'package:dio/dio.dart';

/// Mengubah DioException menjadi pesan yang aman untuk UI.
String apiErrorMessage(DioException error) {
  if (error.response?.statusCode == 401) {
    return 'Sesi kamu telah berakhir. Silakan login kembali.';
  }

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return 'Koneksi ke server terlalu lama. Coba lagi.';
  }

  if (error.type == DioExceptionType.connectionError) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
  }

  final statusCode = error.response?.statusCode;

  if (statusCode == 403) {
    return 'Kamu tidak memiliki izin untuk melakukan tindakan ini.';
  }

  if (statusCode == 404) {
    return 'Data yang diminta tidak ditemukan.';
  }

  if (statusCode != null && statusCode >= 500) {
    return 'Server sedang bermasalah. Coba lagi nanti.';
  }

  if (error.type == DioExceptionType.cancel) {
    return 'Permintaan dibatalkan.';
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}
