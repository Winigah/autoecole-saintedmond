import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseConfig {
  // L'utilisateur peut renseigner son URL et sa clé publique Supabase ici
  // ou les configurer via l'interface des paramètres de l'application.
  static String _url = 'https://lnfzpyvauuffkpbyvuux.supabase.co';
  static String _anonKey = 'sb_publishable_2UFebfUzCAPPfa-ISlE_Uw_A30pWMfd';

  static const String _keyUrlPref = 'supabase_project_url';
  static const String _keyAnonPref = 'supabase_project_anon_key';

  static String get url => _url;
  static String get anonKey => _anonKey;

  static bool get isConfigured =>
      _url.isNotEmpty &&
      _anonKey.isNotEmpty &&
      !_url.contains('votre-projet');

  static SupabaseClient? get client {
    if (!isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialise la configuration et tente d'initialiser Supabase
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_keyUrlPref);
      final savedKey = prefs.getString(_keyAnonPref);
      if (savedUrl != null && savedUrl.isNotEmpty) _url = savedUrl;
      if (savedKey != null && savedKey.isNotEmpty) _anonKey = savedKey;

      if (isConfigured) {
        await Supabase.initialize(
          url: _url,
          // ignore: deprecated_member_use
          anonKey: _anonKey,
          debug: kDebugMode,
        );
        debugPrint('Supabase initialisé avec succès sur Mobile.');
      }
    } catch (e) {
      debugPrint('Avis Supabase config: $e');
    }
  }

  /// Permet au DG de configurer ses clés directement depuis l'application
  static Future<bool> saveCredentials(String newUrl, String newKey) async {
    try {
      final cleanUrl = newUrl.trim();
      final cleanKey = newKey.trim();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUrlPref, cleanUrl);
      await prefs.setString(_keyAnonPref, cleanKey);

      _url = cleanUrl;
      _anonKey = cleanKey;

      if (isConfigured) {
        await Supabase.initialize(
          url: _url,
          // ignore: deprecated_member_use
          anonKey: _anonKey,
        );
      }
      return true;
    } catch (e) {
      debugPrint('Erreur sauvegarde Supabase: $e');
      return false;
    }
  }
}
