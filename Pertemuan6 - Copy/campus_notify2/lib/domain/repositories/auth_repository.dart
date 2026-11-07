class AuthSession {
  const AuthSession({required this.access, this.refresh = ''});

  final String access;
  final String refresh;
}

abstract interface class AuthRepository {
  bool get isLoggedIn;

  Future<AuthSession> login({required String email, required String password});

  Future<void> logout();
}
