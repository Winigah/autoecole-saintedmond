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

  // Clés de stockage sécurisé
  static const String _keyDgLogin = 'auth_dg_login_v3';
  static const String _keyDgHash = 'auth_dg_hash_v3';
  static const String _keySecLogin = 'auth_sec_login_v3';
  static const String _keySecHash = 'auth_sec_hash_v3';

  // Hachages par défaut :
  // DG : '12345678'
  static const String _defaultDgHash =
      'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f';
  // Secrétaire : '123456789'
  static const String _defaultSecHash =
      '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225';

  // Anti-bruteforce
  static int _failedAttempts = 0;
  static DateTime? _lockoutUntil;

  /// Hachage SHA-256 pur Dart autonome et ultra-sécurisé
  static String hashSha256(String input) {
    int rightRotate(int value, int amount) {
      return ((value & 0xFFFFFFFF) >> amount) |
          ((value & 0xFFFFFFFF) << (32 - amount)) & 0xFFFFFFFF;
    }

    final maxWord = pow(2, 32).toInt();
    final words = <int>[];
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

    words.length = (((asciiBitLength + 64) >> 9) << 4) + 16;
    words.fillRange(0, words.length, 0);

    for (var i = 0; i < input.length; i++) {
      words[i >> 2] |= (input.codeUnitAt(i) & 255) << (24 - (i % 4) * 8);
    }
    words[asciiBitLength >> 5] |= 128 << (24 - (asciiBitLength % 32));
    words[words.length - 1] = asciiBitLength;

    for (var j = 0; j < words.length; j += 16) {
      final w = words.sublist(j, j + 16);
      final oldHash = List<int>.from(hash);

      for (var i = 0; i < 64; i++) {
        final w15 = i >= 15 ? w[i - 15] : 0;
        final w2 = i >= 2 ? w[i - 2] : 0;
        final a = hash[0];
        final e = hash[4];

        int s1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
        int ch = (e & hash[5]) ^ (~e & hash[6]);
        int wi;
        if (i < 16) {
          wi = w[i] & 0xFFFFFFFF;
        } else {
          int s0 = rightRotate(w15, 7) ^ rightRotate(w15, 18) ^ ((w15 >> 3) & 0x1FFFFFFF);
          int s2 = rightRotate(w2, 17) ^ rightRotate(w2, 19) ^ ((w2 >> 10) & 0x003FFFFF);
          wi = ((w[i - 16] + s0 + w[i - 7] + s2) & 0xFFFFFFFF);
          w.add(wi);
        }

        int temp1 = (hash[7] + s1 + ch + k[i] + wi) & 0xFFFFFFFF;
        int s0A = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
        int maj = (a & hash[1]) ^ (a & hash[2]) ^ (hash[1] & hash[2]);
        int temp2 = (s0A + maj) & 0xFFFFFFFF;

        hash[7] = hash[6];
        hash[6] = hash[5];
        hash[5] = hash[4];
        hash[4] = (hash[3] + temp1) & 0xFFFFFFFF;
        hash[3] = hash[2];
        hash[2] = hash[1];
        hash[1] = a;
        hash[0] = (temp1 + temp2) & 0xFFFFFFFF;
      }

      for (var i = 0; i < 8; i++) {
        hash[i] = (hash[i] + oldHash[i]) & 0xFFFFFFFF;
      }
    }

    final buffer = StringBuffer();
    for (var i = 0; i < 8; i++) {
      for (var shift = 24; shift >= 0; shift -= 8) {
        final b = (hash[i] >> shift) & 255;
        buffer.write(b.toRadixString(16).padLeft(2, '0'));
      }
    }
    return buffer.toString();
  }

  static String _normaliser(String str) {
    return str.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Authentification de l'utilisateur avec protection anti-bruteforce
  static Future<MobileAuthResult> login({
    required String login,
    required String password,
  }) async {
    // Vérification temporisation brute force
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

    // Récupérer les identifiants stockés ou par défaut
    final savedDgLogin = await _storage.read(key: _keyDgLogin) ?? 'DG Saint Edmond';
    final savedDgHash = await _storage.read(key: _keyDgHash) ?? _defaultDgHash;

    final savedSecLogin =
        await _storage.read(key: _keySecLogin) ?? 'Secretaire Saint Edmond';
    final savedSecHash = await _storage.read(key: _keySecHash) ?? _defaultSecHash;

    final inputHash = hashSha256(cleanPwd);

    // Test DG
    final isDgLogin = cleanLogin == _normaliser(savedDgLogin) ||
        cleanLogin == 'dg' ||
        cleanLogin == 'edmond' ||
        cleanLogin == 'dg saint edmond' ||
        cleanLogin == 'dg@saintedmond.tg';

    if (isDgLogin) {
      if (inputHash == savedDgHash) {
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
      if (inputHash == savedSecHash) {
        _failedAttempts = 0;
        _lockoutUntil = null;
        return MobileAuthResult(
          success: true,
          role: 'SECRETAIRE',
          userName: savedSecLogin,
        );
      }
    }

    // Échec de connexion : incrémenter le compteur anti-bruteforce
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
  }

  /// Modification sécurisée du mot de passe et de l'identifiant
  static Future<bool> changeCredentials({
    required String role,
    required String oldPassword,
    required String newPassword,
    String? newLogin,
  }) async {
    final oldHash = hashSha256(oldPassword.trim());

    if (role == 'DG') {
      final currentHash = await _storage.read(key: _keyDgHash) ?? _defaultDgHash;
      if (oldHash != currentHash) return false;

      final newHash = hashSha256(newPassword.trim());
      await _storage.write(key: _keyDgHash, value: newHash);
      if (newLogin != null && newLogin.trim().isNotEmpty) {
        await _storage.write(key: _keyDgLogin, value: newLogin.trim());
      }
      return true;
    } else {
      final currentHash =
          await _storage.read(key: _keySecHash) ?? _defaultSecHash;
      if (oldHash != currentHash) return false;

      final newHash = hashSha256(newPassword.trim());
      await _storage.write(key: _keySecHash, value: newHash);
      if (newLogin != null && newLogin.trim().isNotEmpty) {
        await _storage.write(key: _keySecLogin, value: newLogin.trim());
      }
      return true;
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
