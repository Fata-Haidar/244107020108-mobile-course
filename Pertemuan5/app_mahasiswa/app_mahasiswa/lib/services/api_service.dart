import 'package:dio/dio.dart';
import '../models/mahasiswa.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

  Future<List<Mahasiswa>> getMahasiswa() async {
  final response = await _dio.get('/mahasiswa');

  final data = response.data;

  if (data is List) {
    return data
        .map((json) => Mahasiswa.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();
  }

  if (data is Map<String, dynamic>) {
    final list = data['data'];

    if (list is List) {
      return list
          .map((json) => Mahasiswa.fromJson(
                Map<String, dynamic>.from(json),
              ))
          .toList();
    }
  }

  throw Exception('Format data API tidak sesuai');
}

  Future<void> tambahMahasiswa(Mahasiswa mahasiswa) async {
    await _dio.post(
      '/mahasiswa',
      data: mahasiswa.toJson(),
    );
  }

  Future<void> updateMahasiswa(
    int id,
    Mahasiswa mahasiswa,
  ) async {
    await _dio.put(
      '/mahasiswa/$id',
      data: mahasiswa.toJson(),
    );
  }

  Future<void> hapusMahasiswa(int id) async {
    await _dio.delete('/mahasiswa/$id');
  }
}