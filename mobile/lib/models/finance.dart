class Depense {
  final String id;
  final String type; // FIXE, NORMALE, SPECIALE_DG, SECRETAIRE
  final String intitule;
  final int montant;
  final String date;
  final String annexe;

  Depense({
    required this.id,
    required this.type,
    required this.intitule,
    required this.montant,
    required this.date,
    required this.annexe,
  });

  factory Depense.fromJson(Map<String, dynamic> json) {
    return Depense(
      id: json['id'] ?? '',
      type: json['type'] ?? 'NORMALE',
      intitule: json['intitule'] ?? '',
      montant: json['montant'] ?? 0,
      date: json['date'] ?? '',
      annexe: json['annexe'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'intitule': intitule,
      'montant': montant,
      'date': date,
      'annexe': annexe,
    };
  }
}

class Recette {
  final String id;
  final String intitule;
  final int montant;
  final String date;
  final String annexe;
  final String? candidatId;

  Recette({
    required this.id,
    required this.intitule,
    required this.montant,
    required this.date,
    required this.annexe,
    this.candidatId,
  });

  factory Recette.fromJson(Map<String, dynamic> json) {
    return Recette(
      id: json['id'] ?? '',
      intitule: json['intitule'] ?? '',
      montant: json['montant'] ?? 0,
      date: json['date'] ?? '',
      annexe: json['annexe'] ?? '',
      candidatId: json['candidat_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'intitule': intitule,
      'montant': montant,
      'date': date,
      'annexe': annexe,
      'candidat_id': candidatId,
    };
  }
}
