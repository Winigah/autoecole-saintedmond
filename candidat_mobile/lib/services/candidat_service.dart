import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/candidat_info.dart';

class CandidatService {
  static const String _keyCachedSession = 'candidat_portal_session_v1';
  static const String _keyCodeAcces = 'candidat_portal_code_v1';

  // Base de données de démonstration / hors-ligne miroir de l'application mère
  static final Map<String, CandidatPortalData> _mockDatabase = {
    'K7B9-4X2M': CandidatPortalData(
      entreprise: const AutoEcoleInfo(
        nom: 'Auto-École Saint Edmond',
        telephone: '+228 91 88 02 75',
        email: 'saintedmondofficiel@gmail.com',
      ),
      candidat: const CandidatDetails(
        id: '1',
        codeAcces: 'K7B9-4X2M',
        nom: 'KOFFI',
        prenom: 'Mawuli',
        contact: '+228 90 XX XX XX',
        categoriePermis: 'B',
        langue: 'EWE',
        typeFormation: 'Formation Normale (Permis B)',
        statut: 'ADMIS',
        dateInscription: '2026-04-12',
        nbConduitesPrevues: 20,
        nbConduitesEffectuees: 20,
        nbConduitesRestantes: 0,
        dateExamenCode: '2026-06-15',
        statutExamenCode: 'ADMIS',
        dateExamenConduite: '2026-07-20',
        statutExamenConduite: 'ADMIS',
        montantTotal: 120000,
        montantPaye: 120000,
        montantRestant: 0,
        estSolde: true,
      ),
      seances: [
        SeanceCandidat(
          id: 's1',
          typeSeance: 'CODE',
          dateHeure: DateTime.now().subtract(const Duration(days: 20)),
          dureeMinutes: 120,
          moniteurNom: 'Moniteur Komi',
          statut: 'EFFECTUE',
          notes: 'Maîtrise parfaite des priorités et signalisation',
        ),
        SeanceCandidat(
          id: 's2',
          typeSeance: 'CONDUITE',
          dateHeure: DateTime.now().subtract(const Duration(days: 5)),
          dureeMinutes: 60,
          moniteurNom: 'Moniteur Séna',
          statut: 'EFFECTUE',
          notes: 'Circulation en ville et stationnement en épi validés',
        ),
      ],
      paiements: const [
        PaiementCandidat(
          id: 'p1',
          montant: 60000,
          datePaiement: '2026-04-12',
          moyenPaiement: 'Espèces',
          recuNumero: 'REC-2026-0412',
        ),
        PaiementCandidat(
          id: 'p2',
          montant: 60000,
          datePaiement: '2026-05-10',
          moyenPaiement: 'T-Money / Flooz',
          recuNumero: 'REC-2026-0510',
        ),
      ],
    ),

    'A9X2-5M8K': CandidatPortalData(
      entreprise: const AutoEcoleInfo(
        nom: 'Auto-École Saint Edmond',
        telephone: '+228 91 88 02 75',
        email: 'saintedmondofficiel@gmail.com',
      ),
      candidat: const CandidatDetails(
        id: '2',
        codeAcces: 'A9X2-5M8K',
        nom: 'AGBEKO',
        prenom: 'Afi',
        contact: '+228 91 XX XX XX',
        categoriePermis: 'B',
        langue: 'FRANCAIS',
        typeFormation: 'Formation Accélérée',
        statut: 'INSCRIT',
        dateInscription: '2026-05-03',
        nbConduitesPrevues: 20,
        nbConduitesEffectuees: 12,
        nbConduitesRestantes: 8,
        dateExamenCode: '2026-10-25',
        statutExamenCode: 'PROGRAMME',
        dateExamenConduite: '2026-11-15',
        statutExamenConduite: 'NON_PROGRAMME',
        montantTotal: 100000,
        montantPaye: 60000,
        montantRestant: 40000,
        estSolde: false,
      ),
      seances: [
        SeanceCandidat(
          id: 's10',
          typeSeance: 'CONDUITE',
          dateHeure: DateTime.now().add(const Duration(days: 2, hours: 4)),
          dureeMinutes: 60,
          moniteurNom: 'Moniteur Komi',
          statut: 'PLANIFIE',
          notes: 'Travail des créneaux et demi-tour sur route étroite',
        ),
        SeanceCandidat(
          id: 's11',
          typeSeance: 'CONDUITE',
          dateHeure: DateTime.now().add(const Duration(days: 5, hours: 6)),
          dureeMinutes: 60,
          moniteurNom: 'Moniteur Komi',
          statut: 'PLANIFIE',
          notes: 'Circulation sur voie rapide et ronds-points complexes',
        ),
        SeanceCandidat(
          id: 's9',
          typeSeance: 'CONDUITE',
          dateHeure: DateTime.now().subtract(const Duration(days: 3)),
          dureeMinutes: 60,
          moniteurNom: 'Moniteur Séna',
          statut: 'EFFECTUE',
          notes: 'Démarrage en côte et gestion du point de patinage',
        ),
      ],
      paiements: const [
        PaiementCandidat(
          id: 'p10',
          montant: 40000,
          datePaiement: '2026-05-03',
          moyenPaiement: 'Espèces',
          recuNumero: 'REC-2026-0503',
        ),
        PaiementCandidat(
          id: 'p11',
          montant: 20000,
          datePaiement: '2026-06-15',
          moyenPaiement: 'T-Money',
          recuNumero: 'REC-2026-0615',
        ),
      ],
    ),

    'M4P7-9T2B': CandidatPortalData(
      entreprise: const AutoEcoleInfo(
        nom: 'Auto-École Saint Edmond',
        telephone: '+228 91 88 02 75',
        email: 'saintedmondofficiel@gmail.com',
      ),
      candidat: const CandidatDetails(
        id: '3',
        codeAcces: 'M4P7-9T2B',
        nom: 'MENSAH',
        prenom: 'Yao',
        contact: '+228 92 XX XX XX',
        categoriePermis: 'C',
        langue: 'FRANCAIS',
        typeFormation: 'Permis Poids Lourd (Cat. C)',
        statut: 'NON_ADMIS',
        dateInscription: '2026-05-20',
        nbConduitesPrevues: 25,
        nbConduitesEffectuees: 25,
        nbConduitesRestantes: 0,
        dateExamenCode: '2026-07-10',
        statutExamenCode: 'ADMIS',
        dateExamenConduite: '2026-08-20',
        statutExamenConduite: 'AJOURNE',
        montantTotal: 150000,
        montantPaye: 150000,
        montantRestant: 0,
        estSolde: true,
      ),
      seances: [
        SeanceCandidat(
          id: 's20',
          typeSeance: 'CONDUITE',
          dateHeure: DateTime.now().add(const Duration(days: 3, hours: 2)),
          dureeMinutes: 90,
          moniteurNom: 'Moniteur Fofo',
          statut: 'PLANIFIE',
          notes: 'Séance de rattrapage conduite - Manœuvres camion remorque',
        ),
      ],
      paiements: const [
        PaiementCandidat(
          id: 'p20',
          montant: 150000,
          datePaiement: '2026-05-20',
          moyenPaiement: 'Virement',
          recuNumero: 'REC-2026-0520',
        ),
      ],
    ),
  };

  /// Normalisation et vérification du code à 8 caractères (ex: K7B9-4X2M ou K7B94X2M)
  static String normaliserCode(String codeBrut) {
    String clean = codeBrut.trim().toUpperCase().replaceAll(' ', '').replaceAll('-', '');
    if (clean.length == 8) {
      return '${clean.substring(0, 4)}-${clean.substring(4, 8)}';
    }
    return codeBrut.trim().toUpperCase();
  }

  /// Authentification du candidat via son code d'accès
  static Future<CandidatPortalData?> authentifierParCode(String codeBrut) async {
    final code = normaliserCode(codeBrut);

    // Simulation de délai réseau
    await Future.delayed(const Duration(milliseconds: 650));

    // Vérification dans la base
    CandidatPortalData? data = _mockDatabase[code];

    // Si non trouvé dans le dictionnaire prédéfini, générer un profil dynamique pour n'importe quel code au format XXXX-XXXX
    if (data == null && code.length == 9 && code.contains('-')) {
      data = CandidatPortalData(
        entreprise: const AutoEcoleInfo(
          nom: 'Auto-École Pro Partenaire',
          telephone: '+228 90 00 00 00',
          email: 'contact@autoecolepro.tg',
        ),
        candidat: CandidatDetails(
          id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
          codeAcces: code,
          nom: 'CANDIDAT',
          prenom: 'Inscrit',
          contact: '+228 90 00 00 00',
          categoriePermis: 'B',
          langue: 'FRANCAIS',
          typeFormation: 'Formation Standard',
          statut: 'INSCRIT',
          dateInscription: DateTime.now().toIso8601String().split('T')[0],
          nbConduitesPrevues: 20,
          nbConduitesEffectuees: 4,
          nbConduitesRestantes: 16,
          dateExamenCode: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
          statutExamenCode: 'PROGRAMME',
          dateExamenConduite: null,
          statutExamenConduite: 'NON_PROGRAMME',
          montantTotal: 120000,
          montantPaye: 60000,
          montantRestant: 60000,
          estSolde: false,
        ),
        seances: [
          SeanceCandidat(
            id: 's_auto',
            typeSeance: 'CONDUITE',
            dateHeure: DateTime.now().add(const Duration(days: 2, hours: 9)),
            dureeMinutes: 60,
            moniteurNom: 'Moniteur Principal',
            statut: 'PLANIFIE',
            notes: 'Prochaine leçon : Contrôles et trajectoires',
          ),
        ],
        paiements: const [
          PaiementCandidat(
            id: 'p_auto',
            montant: 60000,
            datePaiement: '2026-10-01',
            moyenPaiement: 'Espèces',
            recuNumero: 'REC-AUTO-01',
          ),
        ],
      );
    }

    if (data != null) {
      await _sauvegarderSession(code, data);
      return data;
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
    } catch (_) {}
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

  /// Ouvre WhatsApp avec un message pré-rempli pour le secrétariat
  static Future<bool> contacterAutoEcoleWhatsApp({
    required String telephone,
    required String nomCandidat,
    required String codeAcces,
    String? sujet,
  }) async {
    final cleanPhone = telephone.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = "Bonjour l'Auto-École, je suis $nomCandidat (Code d'accès: $codeAcces). ${sujet ?? 'Je souhaite avoir un renseignement sur mon planning.'}";
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