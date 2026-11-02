import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static const String _keyToken = 'auth_token_jwt';
  static const String _keyRole = 'user_role';
  static const String _keyPin = 'security_pin_code';

  static Future<void> saveSession({required String token, required String role}) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole, value: role);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<String> getRole() async {
    final role = await _storage.read(key: _keyRole);
    return role ?? 'DG';
  }

  static Future<void> setSecurityPin(String pin) async {
    await _storage.write(key: _keyPin, value: pin);
  }

  static Future<bool> verifyPin(String pin) async {
    final savedPin = await _storage.read(key: _keyPin);
    if (savedPin == null) return true; // Pas encore configuré
    return savedPin == pin;
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRole);
  }
}
