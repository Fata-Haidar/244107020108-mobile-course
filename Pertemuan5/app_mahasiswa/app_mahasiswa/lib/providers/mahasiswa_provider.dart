import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mahasiswa.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class MahasiswaNotifier extends AsyncNotifier<List<Mahasiswa>> {
  @override
  Future<List<Mahasiswa>> build() async {
    final api = ref.watch(apiServiceProvider);
    return api.getMahasiswa();
  }

  Future<void> refreshData() async {
    state = const AsyncLoading();

    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.getMahasiswa();

      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> hapus(int id) async {
    final api = ref.read(apiServiceProvider);

    await api.hapusMahasiswa(id);
    await refreshData();
  }
}

final mahasiswaProvider =
    AsyncNotifierProvider<MahasiswaNotifier, List<Mahasiswa>>(
  MahasiswaNotifier.new,
);