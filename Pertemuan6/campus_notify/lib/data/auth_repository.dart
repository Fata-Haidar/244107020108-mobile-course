import 'package:firebase_auth/firebase_auth.dart';

class AuthSession {
  const AuthSession({required this.access, this.refresh = ''});

  /// Firebase ID token. Firebase SDK memperbaruinya secara otomatis.
  final String access;
  final String refresh;
}

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('Login gagal. Data pengguna tidak ditemukan.');
      }
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        throw Exception('Firebase tidak memberikan token autentikasi.');
      }
      return AuthSession(access: token);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authError(e.code));
    }
  }

  /// Firebase mengelola refresh token secara internal.
  /// Fungsi ini dipertahankan agar kompatibel dengan pemanggil lama.
  Future<String> refresh(String ignoredRefreshToken) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sesi login sudah berakhir.');
    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw Exception('Gagal memperbarui token.');
    }
    return token;
  }

  Future<void> logout() => _auth.signOut();

  String _authError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Metode login Email/Password belum diaktifkan di Firebase.';
      default:
        return 'Login gagal ($code). Periksa konfigurasi Firebase.';
    }
  }
}
