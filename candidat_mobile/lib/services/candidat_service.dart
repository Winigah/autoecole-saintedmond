import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/candidat_info.dart';

class CandidatService {
  static const String _keyCachedSession = 'candidat_portal_session_v2';
  static const String _keyCodeAcces = 'candidat_portal_code_v2';

  // Configuration Supabase officielle Saint Edmond
  static const String _supabaseUrl = 'https://lnfzpyvauuffkpbyvuux.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_2UFebfUzCAPPfa-ISlE_Uw_A30pWMfd';

  static Map<String, String> get _supabaseHeaders => {
    'apikey': _supabaseAnonKey,
    'Authorization': 'Bearer $_supabaseAnonKey',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Auto-École Saint Edmond - Informations officielles
  static const AutoEcoleInfo saintEdmondInfo = AutoEcoleInfo(
    nom: 'Auto-École Saint Edmond',
    telephone: '+228 91 88 02 75',
    email: 'dg@saintedmond.tg',
    logoUrl: null,
  );

  /// Normalisation et vérification du code à 8 caractères (ex: K7B9-4X2M ou K7B94X2M)
  static String normaliserCode(String codeBrut) {
    String clean = codeBrut.trim().toUpperCase().replaceAll(' ', '').replaceAll('-', '');
    if (clean.length == 8) {
      return '${clean.substring(0, 4)}-${clean.substring(4, 8)}';
    }
    return codeBrut.trim().toUpperCase();
  }

  /// Authentification du candidat via son code d'accès réel dans Supabase
  static Future<CandidatPortalData?> authentifierParCode(String codeBrut) async {
    final code = normaliserCode(codeBrut);

    try {
      // 1. Requête vers Supabase REST API pour trouver le candidat avec ce code_acces
      final url = Uri.parse(
        '$_supabaseUrl/rest/v1/candidats?code_acces=eq.$code&select=*',
      );

      final response = await http
          .get(url, headers: _supabaseHeaders)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        if (list.isNotEmpty) {
          final candMap = list.first as Map<String, dynamic>;
          final candidatId = candMap['id']?.toString() ?? '';

          // 2. Récupérer les paiements réels de ce candidat depuis la table recettes
          List<PaiementCandidat> paiementsReels = [];
          if (candidatId.isNotEmpty) {
            try {
              final recUrl = Uri.parse(
                '$_supabaseUrl/rest/v1/recettes?candidat_id=eq.$candidatId&select=*&order=date.desc',
              );
              final recResponse = await http
                  .get(recUrl, headers: _supabaseHeaders)
                  .timeout(const Duration(seconds: 5));

              if (recResponse.statusCode == 200) {
                final List<dynamic> recList = jsonDecode(recResponse.body);
                paiementsReels = recList.map((r) {
                  return PaiementCandidat(
                    id: r['id']?.toString() ?? '',
                    montant: (r['montant'] as num?)?.toInt() ?? 0,
                    datePaiement: r['date']?.toString() ?? '',
                    moyenPaiement: 'Caisse Auto-École',
                    recuNumero: r['intitule']?.toString(),
                  );
                }).toList();
              }
            } catch (e) {
              debugPrint('Erreur chargement paiements: $e');
            }
          }

          // 3. Mapper les colonnes Supabase vers l'objet CandidatDetails
          final int montantTotal = (candMap['montant_total'] as num?)?.toInt() ?? 0;
          final int montantPaye = (candMap['montant_paye'] as num?)?.toInt() ?? 0;
          final int prevues = (candMap['nb_conduites_prevues'] as num?)?.toInt() ?? 12;
          final int effectuees = (candMap['nb_conduites_effectuees'] as num?)?.toInt() ?? 0;

          final details = CandidatDetails(
            id: candidatId,
            codeAcces: code,
            nom: (candMap['nom'] ?? '').toString().toUpperCase(),
            prenom: (candMap['prenom'] ?? '').toString(),
            contact: (candMap['contact'] ?? '').toString(),
            categoriePermis: (candMap['categorie'] ?? 'B').toString(),
            langue: (candMap['langue'] ?? 'FRANCAIS').toString(),
            typeFormation: (candMap['type_formation'] ?? 'Formation Normale (Permis B)').toString(),
            statut: (candMap['statut'] ?? 'INSCRIT').toString(),
            dateInscription: (candMap['date_inscription'] ?? '').toString(),
            photoUrl: candMap['photo_url']?.toString(),
            nbConduitesPrevues: prevues,
            nbConduitesEffectuees: effectuees,
            nbConduitesRestantes: (prevues - effectuees).clamp(0, prevues),
            dateExamenCode: candMap['date_examen_code']?.toString(),
            statutExamenCode: (candMap['statut_examen_code'] ?? 'NON_PROGRAMME').toString(),
            dateExamenConduite: candMap['date_examen_conduite']?.toString(),
            statutExamenConduite: (candMap['statut_examen_conduite'] ?? 'NON_PROGRAMME').toString(),
            montantTotal: montantTotal,
            montantPaye: montantPaye,
            montantRestant: (montantTotal - montantPaye).clamp(0, montantTotal),
            estSolde: montantPaye >= montantTotal && montantTotal > 0,
          );

          final portalData = CandidatPortalData(
            entreprise: saintEdmondInfo,
            candidat: details,
            seances: [
              SeanceCandidat(
                id: 'sc_code',
                typeSeance: 'CODE',
                dateHeure: DateTime.now(),
                dureeMinutes: 120,
                moniteurNom: 'Auto-École Saint Edmond',
                statut: 'EFFECTUE',
                notes: 'Salle de cours : Siège Tokoin Ramco (Face Ambassade de Belgique)',
              ),
              if (effectuees > 0)
                SeanceCandidat(
                  id: 'sc_cond',
                  typeSeance: 'CONDUITE',
                  dateHeure: DateTime.now().subtract(const Duration(days: 2)),
                  dureeMinutes: 60,
                  moniteurNom: 'Moniteur Saint Edmond',
                  statut: 'EFFECTUE',
                  notes: 'Séances pratiques validées : $effectuees / $prevues',
                ),
            ],
            paiements: paiementsReels,
          );

          await _sauvegarderSession(code, portalData);
          return portalData;
        }
      }
    } catch (e) {
      debugPrint('Tentative connexion cloud échouée, vérification cache local: $e');
    }

    // 4. Si pas de réseau ou hors-ligne : tenter de restaurer depuis le cache local
    final cached = await getCachedSession();
    if (cached != null && normaliserCode(cached.candidat.codeAcces) == code) {
      return cached;
    }

    return null;
  }

  /// Sauvegarde locale hors-ligne dans SharedPreferences
  static Future<void> _sauvegarderSession(String code, CandidatPortalData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCodeAcces, code);
      final jsonMap = {
        'entreprise': data.entreprise.toJson(),
        'candidat': data.candidat.toJson(),
        'seances': data.seances.map((s) => s.toJson()).toList(),
        'paiements': data.paiements.map((p) => p.toJson()).toList(),
      };
      await prefs.setString(_keyCachedSession, jsonEncode(jsonMap));
    } catch (e) {
      debugPrint('Erreur sauvegarde cache session candidat: $e');
    }
  }

  /// Récupération de la session mise en cache pour démarrage instantané
  static Future<CandidatPortalData?> getCachedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyCachedSession);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return CandidatPortalData.fromJson(map);
      }
    } catch (_) {}
    return null;
  }

  /// Déconnexion
  static Future<void> deconnexion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCachedSession);
    await prefs.remove(_keyCodeAcces);
  }

  /// Ouvre WhatsApp avec un message pré-rempli pour le secrétariat de Saint Edmond
  static Future<bool> contacterAutoEcoleWhatsApp({
    required String telephone,
    required String nomCandidat,
    required String codeAcces,
    String? sujet,
  }) async {
    final cleanPhone = telephone.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = "Bonjour Auto-École Saint Edmond, je suis $nomCandidat (Code d'accès: $codeAcces). ${sujet ?? 'Je souhaite avoir un renseignement sur ma formation.'}";
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(msg)}');
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Appel téléphonique direct vers l'auto-école
  static Future<bool> appelerAutoEcole(String telephone) async {
    final cleanPhone = telephone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    return await launchUrl(uri);
  }
}
