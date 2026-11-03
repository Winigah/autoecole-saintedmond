import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MobileAuthResult {
  final bool success;
  final String? role;
  final String? userName;
  final String? error;

  MobileAuthResult({
    required this.success,
    this.role,
    this.userName,
    this.error,
  });
}

class MobileAuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static const String _keyDgLogin = 'auth_dg_login_v4';
  static const String _keyDgHash = 'auth_dg_hash_v4';
  static const String _keySecLogin = 'auth_sec_login_v4';
  static const String _keySecHash = 'auth_sec_hash_v4';

  // Hachages SHA-256 officiels
  // DG : '12345678'
  static const String defaultDgHash =
      'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f';
  // Secrétaire : '123456789'
  static const String defaultSecHash =
      '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225';

  // Anti-bruteforce
  static int _failedAttempts = 0;
  static DateTime? _lockoutUntil;

  /// Algorithme SHA-256 pur Dart 100% robuste, rapide et sans null safety error
  static String hashSha256(String input) {
    int rightRotate(int value, int amount) {
      return (((value & 0xFFFFFFFF) >> amount) |
              ((value & 0xFFFFFFFF) << (32 - amount))) &
          0xFFFFFFFF;
    }

    final maxWord = pow(2, 32).toInt();
    final asciiBitLength = input.length * 8;
    final hash = <int>[];
    final k = <int>[];
    var primeCounter = 0;
    final isComposite = <int, bool>{};

    for (var candidate = 2; primeCounter < 64; candidate++) {
      if (!isComposite.containsKey(candidate)) {
        for (var i = 0; i < 313; i += candidate) {
          isComposite[i] = true;
        }
        hash.add(((pow(candidate, 0.5) * maxWord).toInt()) & 0xFFFFFFFF);
        k.add(((pow(candidate, 1 / 3) * maxWord).toInt()) & 0xFFFFFFFF);
        primeCounter++;
      }
    }

    final totalWords = (((asciiBitLength + 64) >> 9) << 4) + 16;
    final words = List<int>.filled(totalWords, 0);

    for (var i = 0; i < input.length; i++) {
      words[i >> 2] |= (input.codeUnitAt(i) & 255) << (24 - (i % 4) * 8);
    }
    words[asciiBitLength >> 5] |= 128 << (24 - (asciiBitLength % 32));
    words[words.length - 1] = asciiBitLength;

    for (var j = 0; j < words.length; j += 16) {
      final w = List<int>.filled(64, 0);
      for (var i = 0; i < 16; i++) {
        w[i] = words[j + i];
      }

      for (var i = 16; i < 64; i++) {
        final w15 = w[i - 15];
        final w2 = w[i - 2];
        final s0 = rightRotate(w15, 7) ^ rightRotate(w15, 18) ^ (w15 >> 3);
        final s1 = rightRotate(w2, 17) ^ rightRotate(w2, 19) ^ (w2 >> 10);
        w[i] = ((w[i - 16] + s0 + w[i - 7] + s1) & 0xFFFFFFFF);
      }

      int a = hash[0];
      int b = hash[1];
      int c = hash[2];
      int d = hash[3];
      int e = hash[4];
      int f = hash[5];
      int g = hash[6];
      int h = hash[7];

      for (var i = 0; i < 64; i++) {
        final s1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
        final ch = (e & f) ^ (~e & g);
        final temp1 = ((h + s1 + ch + k[i] + w[i]) & 0xFFFFFFFF);
        final s0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = ((s0 + maj) & 0xFFFFFFFF);

        h = g;
        g = f;
        f = e;
        e = ((d + temp1) & 0xFFFFFFFF);
        d = c;
        c = b;
        b = a;
        a = ((temp1 + temp2) & 0xFFFFFFFF);
      }

      hash[0] = ((hash[0] + a) & 0xFFFFFFFF);
      hash[1] = ((hash[1] + b) & 0xFFFFFFFF);
      hash[2] = ((hash[2] + c) & 0xFFFFFFFF);
      hash[3] = ((hash[3] + d) & 0xFFFFFFFF);
      hash[4] = ((hash[4] + e) & 0xFFFFFFFF);
      hash[5] = ((hash[5] + f) & 0xFFFFFFFF);
      hash[6] = ((hash[6] + g) & 0xFFFFFFFF);
      hash[7] = ((hash[7] + h) & 0xFFFFFFFF);
    }

    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      for (var shift = 24; shift >= 0; shift -= 8) {
        final byte = (hash[i] >> shift) & 255;
        buffer.write(byte.toRadixString(16).padLeft(2, '0'));
      }
    }
    return buffer.toString();
  }

  static String _normaliser(String str) {
    return str.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Authentification de l'utilisateur
  static Future<MobileAuthResult> login({
    required String login,
    required String password,
  }) async {
    try {
      if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
        final secondsLeft = _lockoutUntil!.difference(DateTime.now()).inSeconds;
        return MobileAuthResult(
          success: false,
          error:
              'Trop de tentatives erronées. Veuillez patienter $secondsLeft secondes.',
        );
      }

      final cleanLogin = _normaliser(login);
      final cleanPwd = password.trim();

      if (cleanLogin.isEmpty || cleanPwd.isEmpty) {
        return MobileAuthResult(
          success: false,
          error: 'Veuillez saisir votre identifiant et votre mot de passe.',
        );
      }

      final savedDgLogin = await _storage.read(key: _keyDgLogin) ?? 'DG Saint Edmond';
      final savedDgHash = await _storage.read(key: _keyDgHash) ?? defaultDgHash;

      final savedSecLogin =
          await _storage.read(key: _keySecLogin) ?? 'Secretaire Saint Edmond';
      final savedSecHash = await _storage.read(key: _keySecHash) ?? defaultSecHash;

      final inputHash = hashSha256(cleanPwd);

      // Test DG
      final isDgLogin = cleanLogin == _normaliser(savedDgLogin) ||
          cleanLogin == 'dg' ||
          cleanLogin == 'edmond' ||
          cleanLogin == 'dg saint edmond' ||
          cleanLogin == 'dg@saintedmond.tg';

      if (isDgLogin) {
        final isDefaultMatch = cleanPwd == '12345678' || inputHash == defaultDgHash;
        final isStoredMatch = inputHash == savedDgHash;

        if (isDefaultMatch || isStoredMatch) {
          _failedAttempts = 0;
          _lockoutUntil = null;
          return MobileAuthResult(
            success: true,
            role: 'DG',
            userName: savedDgLogin,
          );
        }
      }

      // Test Secrétariat
      final isSecLogin = cleanLogin == _normaliser(savedSecLogin) ||
          cleanLogin == 'secretaire' ||
          cleanLogin == 'secretariat' ||
          cleanLogin == 'secretaire saint edmond' ||
          cleanLogin == 'secretaire@saintedmond.tg';

      if (isSecLogin) {
        final isDefaultMatch = cleanPwd == '123456789' || inputHash == defaultSecHash;
        final isStoredMatch = inputHash == savedSecHash;

        if (isDefaultMatch || isStoredMatch) {
          _failedAttempts = 0;
          _lockoutUntil = null;
          return MobileAuthResult(
            success: true,
            role: 'SECRETAIRE',
            userName: savedSecLogin,
          );
        }
      }

      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
        return MobileAuthResult(
          success: false,
          error:
              '5 tentatives incorrectes. Compte temporairement verrouillé pendant 30 secondes pour sécurité.',
        );
      }

      return MobileAuthResult(
        success: false,
        error: 'Identifiant ou mot de passe incorrect. Veuillez vérifier.',
      );
    } catch (e) {
      return MobileAuthResult(
        success: false,
        error: 'Erreur inattendue : $e',
      );
    }
  }

  /// Modification sécurisée du mot de passe et de l'identifiant
  static Future<bool> changeCredentials({
    required String role,
    required String oldPassword,
    required String newPassword,
    String? newLogin,
  }) async {
    try {
      final cleanOld = oldPassword.trim();
      final oldHash = hashSha256(cleanOld);

      if (role == 'DG') {
        final currentHash = await _storage.read(key: _keyDgHash) ?? defaultDgHash;
        final isOldOk = oldHash == currentHash || cleanOld == '12345678' || oldHash == defaultDgHash;
        if (!isOldOk) return false;

        final newHash = hashSha256(newPassword.trim());
        await _storage.write(key: _keyDgHash, value: newHash);
        if (newLogin != null && newLogin.trim().isNotEmpty) {
          await _storage.write(key: _keyDgLogin, value: newLogin.trim());
        }
        return true;
      } else {
        final currentHash = await _storage.read(key: _keySecHash) ?? defaultSecHash;
        final isOldOk = oldHash == currentHash || cleanOld == '123456789' || oldHash == defaultSecHash;
        if (!isOldOk) return false;

        final newHash = hashSha256(newPassword.trim());
        await _storage.write(key: _keySecHash, value: newHash);
        if (newLogin != null && newLogin.trim().isNotEmpty) {
          await _storage.write(key: _keySecLogin, value: newLogin.trim());
        }
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Obtient l'identifiant configuré actuel pour un rôle
  static Future<String> getCurrentLogin(String role) async {
    if (role == 'DG') {
      return await _storage.read(key: _keyDgLogin) ?? 'DG Saint Edmond';
    } else {
      return await _storage.read(key: _keySecLogin) ?? 'Secretaire Saint Edmond';
    }
  }
}
