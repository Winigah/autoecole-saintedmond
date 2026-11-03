import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_config.dart';

class RevisionDocStaff {
  final String id;
  final String titre;
  final String description;
  final String categorie;
  final String urlPdf;
  final String dateAjout;
  final String? taille;

  RevisionDocStaff({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.urlPdf,
    required this.dateAjout,
    this.taille,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'description': description,
    'categorie': categorie,
    'url_pdf': urlPdf,
    'date_ajout': dateAjout,
    'taille': taille,
  };

  factory RevisionDocStaff.fromJson(Map<String, dynamic> json) => RevisionDocStaff(
    id: json['id'] ?? '',
    titre: json['titre'] ?? '',
    description: json['description'] ?? '',
    categorie: json['categorie'] ?? 'CODE',
    urlPdf: json['url_pdf'] ?? '',
    dateAjout: json['date_ajout'] ?? '',
    taille: json['taille'] ?? 'PDF',
  );
}

class RevisionServiceStaff {
  static const String _keyCachedDocs = 'staff_revision_docs_v1';

  static Map<String, String> get _headers => {
    'apikey': SupabaseConfig.anonKey,
    'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Prefer': 'return=representation',
  };

  /// Récupère la liste des cours et fiches partagés aux élèves
  static Future<List<RevisionDocStaff>> fetchDocuments() async {
    try {
      final url = Uri.parse('${SupabaseConfig.url}/rest/v1/presences?type=eq.SUPPORT_REVISION&order=created_at.desc');
      final res = await http.get(url, headers: _headers).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        final docs = <RevisionDocStaff>[];
        for (final row in list) {
          try {
            final rawJson = row['staff_name']?.toString() ?? '{}';
            final meta = jsonDecode(rawJson) as Map<String, dynamic>;
            docs.add(RevisionDocStaff(
              id: row['id']?.toString() ?? '',
              titre: meta['titre']?.toString() ?? 'Support de Révision',
              description: meta['description']?.toString() ?? '',
              categorie: meta['categorie']?.toString() ?? 'CODE',
              urlPdf: meta['url_pdf']?.toString() ?? '',
              dateAjout: row['date']?.toString() ?? '',
              taille: meta['taille']?.toString() ?? 'PDF',
            ));
          } catch (_) {}
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyCachedDocs, jsonEncode(docs.map((d) => d.toJson()).toList()));
        return docs;
      }
    } catch (e) {
      debugPrint('Avis chargement supports de révision: $e');
    }

    // Récupérer depuis le cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_keyCachedDocs);
      if (saved != null) {
        final List<dynamic> list = jsonDecode(saved);
        return list.map((j) => RevisionDocStaff.fromJson(j)).toList();
      }
    } catch (_) {}

    return [];
  }

  /// Ajoute un nouveau cours / support PDF visible instantanément par les élèves
  static Future<bool> addDocument({
    required String titre,
    required String description,
    required String categorie,
    required String urlPdf,
    String? taille,
  }) async {
    final docId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final meta = {
      'titre': titre.trim(),
      'description': description.trim(),
      'categorie': categorie.toUpperCase().trim(),
      'url_pdf': urlPdf.trim(),
      'taille': (taille != null && taille.trim().isNotEmpty) ? taille.trim() : 'PDF',
    };

    final payload = {
      'id': docId,
      'date': dateStr,
      'candidat_id': 'ALL',
      'staff_name': jsonEncode(meta),
      'type': 'SUPPORT_REVISION',
      'present': true,
    };

    try {
      final url = Uri.parse('${SupabaseConfig.url}/rest/v1/presences');
      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur ajout support: $e');
      return false;
    }
  }

  /// Supprime un document de révision
  static Future<bool> deleteDocument(String id) async {
    try {
      final safeId = Uri.encodeComponent(id);
      final url = Uri.parse('${SupabaseConfig.url}/rest/v1/presences?id=eq.$safeId');
      final res = await http.delete(url, headers: _headers).timeout(const Duration(seconds: 8));
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('Erreur suppression support: $e');
      return false;
    }
  }
}
