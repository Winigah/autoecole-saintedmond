import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/candidat.dart';
import '../models/finance.dart';
import 'supabase_config.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  // Clés de persistance locale SharedPreferences
  static const String _keyCandidats = 'autoecole_candidats_saintedmond';
  static const String _keyDepenses = 'autoecole_depenses_saintedmond';
  static const String _keyRecettes = 'autoecole_recettes_saintedmond';
  static const String _keyAnnexes = 'autoecole_annexes_saintedmond';
  static const String _keyStaffPresences = 'autoecole_staff_presences';
  static const String _keyCandidatPresences = 'autoecole_candidat_presences';

  // Siège unique officiel de l'Auto-École Saint Edmond
  final List<String> annexes = ['Tokoin Ramco (Siège)'];

  final List<Candidat> _candidats = [];
  final List<Depense> _depenses = [];
  final List<Recette> _recettes = [];
  final Map<String, bool> staffPresences = {};
  final Map<String, bool> candidatPresences = {};

  bool isInitialized = false;
  bool isSyncing = false;
  DateTime? lastSyncTime;

  /// Initialise la base de données locale (offline-first)
  Future<void> init() async {
    if (isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charger les annexes
      final savedAnnexes = prefs.getStringList(_keyAnnexes);
      if (savedAnnexes != null && savedAnnexes.isNotEmpty) {
        annexes.clear();
        annexes.addAll(savedAnnexes);
      }

      // Charger les candidats
      final rawCandidats = prefs.getString(_keyCandidats);
      if (rawCandidats != null) {
        final List<dynamic> list = jsonDecode(rawCandidats);
        _candidats.clear();
        _candidats.addAll(list.map((item) => Candidat.fromJson(item)).toList());
      }

      // Charger les dépenses
      final rawDepenses = prefs.getString(_keyDepenses);
      if (rawDepenses != null) {
        final List<dynamic> list = jsonDecode(rawDepenses);
        _depenses.clear();
        _depenses.addAll(list.map((item) => Depense.fromJson(item)).toList());
      }

      // Charger les recettes
      final rawRecettes = prefs.getString(_keyRecettes);
      if (rawRecettes != null) {
        final List<dynamic> list = jsonDecode(rawRecettes);
        _recettes.clear();
        _recettes.addAll(list.map((item) => Recette.fromJson(item)).toList());
      }

      // Charger les présences
      final rawStaff = prefs.getString(_keyStaffPresences);
      if (rawStaff != null) {
        final Map<String, dynamic> map = jsonDecode(rawStaff);
        staffPresences.clear();
        staffPresences.addAll(map.map((k, v) => MapEntry(k, v as bool)));
      }

      final rawCandPres = prefs.getString(_keyCandidatPresences);
      if (rawCandPres != null) {
        final Map<String, dynamic> map = jsonDecode(rawCandPres);
        candidatPresences.clear();
        candidatPresences.addAll(map.map((k, v) => MapEntry(k, v as bool)));
      }

      isInitialized = true;
      debugPrint('DatabaseService: ${_candidats.length} candidats chargés en local.');

      // Si Supabase est prêt, synchroniser en tâche de fond
      if (SupabaseConfig.isConfigured) {
        syncWithSupabase();
      }
    } catch (e) {
      debugPrint('Erreur init DatabaseService: $e');
      isInitialized = true;
    }
  }

  /// Sauvegarde immédiate dans le stockage local persistant (offline-first)
  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyAnnexes, annexes);
      await prefs.setString(
        _keyCandidats,
        jsonEncode(_candidats.map((c) => c.toJson()).toList()),
      );
      await prefs.setString(
        _keyDepenses,
        jsonEncode(_depenses.map((d) => d.toJson()).toList()),
      );
      await prefs.setString(
        _keyRecettes,
        jsonEncode(_recettes.map((r) => r.toJson()).toList()),
      );
      await prefs.setString(_keyStaffPresences, jsonEncode(staffPresences));
      await prefs.setString(_keyCandidatPresences, jsonEncode(candidatPresences));
    } catch (e) {
      debugPrint('Erreur sauvegarde locale: $e');
    }
  }

  void addAnnexe(String nom) {
    final clean = nom.trim();
    if (clean.isNotEmpty && !annexes.contains(clean)) {
      annexes.add(clean);
      _saveLocal();
      _syncAnnexeToSupabase(clean);
    }
  }

  List<Candidat> getCandidats({String annexe = 'Toutes', String query = ''}) {
    return _candidats.where((c) {
      final matchAnnexe = annexe == 'Toutes' || c.annexe == annexe;
      final q = query.toLowerCase().trim();
      final matchQuery = q.isEmpty ||
          c.nom.toLowerCase().contains(q) ||
          c.prenom.toLowerCase().contains(q) ||
          c.contact.contains(q);
      return matchAnnexe && matchQuery;
    }).toList();
  }

  void addCandidat(Candidat c, {int? premierVersement}) {
    _candidats.insert(0, c);
    if (premierVersement != null && premierVersement > 0) {
      final r = Recette(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        intitule: 'Premier versement - ${c.nom} ${c.prenom}',
        montant: premierVersement,
        date: c.dateInscription,
        annexe: c.annexe,
        candidatId: c.id,
      );
      _recettes.insert(0, r);
      _syncRecetteToSupabase(r);
    }
    _saveLocal();
    _syncCandidatToSupabase(c);
  }

  /// Version async pour attendre la sauvegarde + sync cloud avant de retourner
  Future<void> addCandidatAsync(Candidat c, {int? premierVersement}) async {
    _candidats.insert(0, c);
    if (premierVersement != null && premierVersement > 0) {
      final r = Recette(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        intitule: 'Premier versement - ${c.nom} ${c.prenom}',
        montant: premierVersement,
        date: c.dateInscription,
        annexe: c.annexe,
        candidatId: c.id,
      );
      _recettes.insert(0, r);
      await _syncRecetteToSupabase(r);
    }
    await _saveLocal();
    await _syncCandidatToSupabase(c);
  }

  List<Depense> getDepenses({String annexe = 'Toutes', bool isSecretaire = false}) {
    return _depenses.where((d) {
      final matchAnnexe = annexe == 'Toutes' || d.annexe == annexe;
      if (isSecretaire && d.type == 'SPECIALE_DG') return false;
      return matchAnnexe;
    }).toList();
  }

  void addDepense(Depense d) {
    _depenses.insert(0, d);
    _saveLocal();
    _syncDepenseToSupabase(d);
  }

  List<Recette> getRecettes({String annexe = 'Toutes'}) {
    return _recettes.where((r) {
      return annexe == 'Toutes' || r.annexe == annexe;
    }).toList();
  }

  void addRecette(Recette r) {
    _recettes.insert(0, r);
    _saveLocal();
    _syncRecetteToSupabase(r);
  }

  void toggleStaffPresence(String key) {
    staffPresences[key] = !(staffPresences[key] ?? false);
    _saveLocal();
  }

  void toggleCandidatPresence(String key) {
    candidatPresences[key] = !(candidatPresences[key] ?? false);
    _saveLocal();
  }

  void addSupplementConduite({
    required String candidatId,
    required int nbSeances,
    required int montantSupplement,
    required int montantVerse,
    String motif = 'Perfectionnement conduite',
  }) {
    final index = _candidats.indexWhere((c) => c.id == candidatId);
    if (index != -1) {
      final old = _candidats[index];
      final updatedCand = Candidat(
        id: old.id,
        nom: old.nom,
        prenom: old.prenom,
        contact: old.contact,
        email: old.email,
        adresse: old.adresse,
        annexe: old.annexe,
        categorie: old.categorie,
        langue: old.langue,
        sexe: old.sexe,
        montantTotal: old.montantTotal + montantSupplement,
        montantPaye: old.montantPaye + montantVerse,
        dateInscription: old.dateInscription,
        dureeFormationMois: old.dureeFormationMois,
        statut: old.statut,
        codeAcces: old.codeAcces,
        photoUrl: old.photoUrl,
      );
      _candidats[index] = updatedCand;

      if (montantVerse > 0) {
        final r = Recette(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          intitule: 'Séances conduite (+$nbSeances) – ${old.nom} ${old.prenom} [$motif]',
          montant: montantVerse,
          date: DateTime.now().toIso8601String().split('T').first,
          annexe: old.annexe,
          candidatId: old.id,
        );
        _recettes.insert(0, r);
        _syncRecetteToSupabase(r);
      }

      _saveLocal();
      _syncCandidatToSupabase(updatedCand);
    }
  }

  // ==========================================
  // SYNCHRONISATION SUPABASE (ONLINE / CLOUD)
  // ==========================================

  Future<void> syncWithSupabase() async {
    final client = SupabaseConfig.client;
    if (client == null || isSyncing) return;

    isSyncing = true;
    try {
      debugPrint('Début de la synchronisation Supabase mobile...');

      // 1. Récupérer les candidats depuis Supabase
      final responseCandidats = await client.from('candidats').select();
      if (responseCandidats.isNotEmpty) {
        final cloudCands = responseCandidats.map((j) => Candidat.fromJson(j)).toList();
        for (final cloudC in cloudCands) {
          final idx = _candidats.indexWhere((c) => c.id == cloudC.id);
          if (idx == -1) {
            _candidats.add(cloudC);
          } else {
            _candidats[idx] = cloudC;
          }
        }
      }

      // 2. Récupérer les dépenses
      final responseDepenses = await client.from('depenses').select();
      if (responseDepenses.isNotEmpty) {
        final cloudDep = responseDepenses.map((j) => Depense.fromJson(j)).toList();
        for (final cd in cloudDep) {
          if (!_depenses.any((d) => d.id == cd.id)) {
            _depenses.add(cd);
          }
        }
      }

      // 3. Récupérer les recettes
      final responseRecettes = await client.from('recettes').select();
      if (responseRecettes.isNotEmpty) {
        final cloudRec = responseRecettes.map((j) => Recette.fromJson(j)).toList();
        for (final cr in cloudRec) {
          if (!_recettes.any((r) => r.id == cr.id)) {
            _recettes.add(cr);
          }
        }
      }

      lastSyncTime = DateTime.now();
      await _saveLocal();
      debugPrint('Synchronisation Supabase réussie à $lastSyncTime');
    } catch (e) {
      debugPrint('Avertissement synchronisation Supabase: $e');
    } finally {
      isSyncing = false;
    }
  }

  Future<void> _syncCandidatToSupabase(Candidat c) async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    try {
      await client.from('candidats').upsert(c.toJson());
    } catch (e) {
      debugPrint('Échec sync candidat vers cloud: $e');
    }
  }

  Future<void> _syncDepenseToSupabase(Depense d) async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    try {
      await client.from('depenses').upsert(d.toJson());
    } catch (e) {
      debugPrint('Échec sync dépense vers cloud: $e');
    }
  }

  Future<void> _syncRecetteToSupabase(Recette r) async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    try {
      await client.from('recettes').upsert(r.toJson());
    } catch (e) {
      debugPrint('Échec sync recette vers cloud: $e');
    }
  }

  Future<void> _syncAnnexeToSupabase(String nom) async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    try {
      await client.from('annexes').upsert({'nom': nom});
    } catch (e) {
      debugPrint('Échec sync annexe vers cloud: $e');
    }
  }

  // ==========================================
  // HELPERS COMMUNICATION
  // ==========================================

  static Future<void> launchWhatsApp(String phone, String studentName) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final url = Uri.parse("https://wa.me/228$cleanPhone?text=Bonjour%20$studentName%2C%20de%20l'Auto-Ecole%20Saint%20Edmond");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("WhatsApp launch error: $e");
    }
  }

  static Future<void> launchCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final url = Uri.parse("tel:$cleanPhone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint("Call error: $e");
    }
  }
}
