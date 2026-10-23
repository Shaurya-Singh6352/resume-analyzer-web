import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:resume_analyzer_web/models/auth_result.dart';

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

  Future<void> restoreSession() async {
    _token = await _storage.read(key: _tokenKey);
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