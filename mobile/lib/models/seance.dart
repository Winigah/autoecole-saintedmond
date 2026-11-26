class Seance {
  final String id;
  final String candidatId;
  final String typeSeance; // 'CODE' ou 'CONDUITE'
  final String dateHeure; // ISO text '2026-11-25T14:30:00'
  final int dureeMinutes;
  final String moniteurNom;
  final String statut; // 'PLANIFIE', 'EFFECTUE', 'ANNULE'
  final String? notes;

  Seance({
    required this.id,
    required this.candidatId,
    this.typeSeance = 'CONDUITE',
    required this.dateHeure,
    this.dureeMinutes = 60,
    this.moniteurNom = 'Moniteur Saint Edmond',
    this.statut = 'PLANIFIE',
    this.notes,
  });

  bool get estEffectue => statut == 'EFFECTUE';
  bool get estConduite => typeSeance == 'CONDUITE';

  factory Seance.fromJson(Map<String, dynamic> json) {
    return Seance(
      id: json['id'] ?? '',
      candidatId: json['candidat_id'] ?? '',
      typeSeance: json['type_seance'] ?? 'CONDUITE',
      dateHeure: json['date_heure'] ?? DateTime.now().toIso8601String(),
      dureeMinutes: json['duree_minutes'] as int? ?? 60,
      moniteurNom: json['moniteur_nom'] ?? 'Moniteur Saint Edmond',
      statut: json['statut'] ?? 'PLANIFIE',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidat_id': candidatId,
      'type_seance': typeSeance,
      'date_heure': dateHeure,
      'duree_minutes': dureeMinutes,
      'moniteur_nom': moniteurNom,
      'statut': statut,
      if (notes != null) 'notes': notes,
    };
  }
}
