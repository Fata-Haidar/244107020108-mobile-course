
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/token_store.dart';

/// Provider penyimpanan access token dan refresh token.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

/// Provider repository autentikasi.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Status autentikasi aplikasi.
/// true = sudah login, false = belum login.
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token =
        await ref.read(tokenStoreProvider).readAccess();

    return token != null && token.isNotEmpty;
  }

  /// Melakukan login dan menyimpan token.
  Future<void> login(
    String email,
    String password,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(
            email: email.trim(),
            password: password,
          );

      await ref.read(tokenStoreProvider).save(
            access: session.access,
            refresh: session.refresh,
          );

      return true;
    });
  }

  /// Menghapus token dan mengakhiri sesi.
  Future<void> logout() async {
    try {
      await ref.read(tokenStoreProvider).clear();

      state = const AsyncData(false);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
