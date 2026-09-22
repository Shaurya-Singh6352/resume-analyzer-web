import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:resume_analyzer_web/models/auth_result.dart';

/// Holds the current session in memory and on disk (browser secure storage),
/// so a page refresh doesn't log the person out.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  static const _tokenKey = 'auth_token';
  static const _storage = FlutterSecureStorage();

  String? _token;
  String? _fullName;
  String? _email;

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  String? get fullName => _fullName;
  String? get email => _email;

  /// Called once when the app starts, to restore a session after a refresh.
  Future<void> restoreSession() async {
    _token = await _storage.read(key: _tokenKey);
    // We only persist the token; name/email are re-attached on next login.
    // Good enough for now — a "who am I" endpoint would replace this later.
  }

  Future<void> saveSession(AuthResult result) async {
    _token = result.token;
    _fullName = result.fullName;
    _email = result.email;
    await _storage.write(key: _tokenKey, value: result.token);
  }

  Future<void> logout() async {
    _token = null;
    _fullName = null;
    _email = null;
    await _storage.delete(key: _tokenKey);
  }
}