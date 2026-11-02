class AutoEcoleInfo {
  final String nom;
  final String telephone;
  final String email;
  final String? logoUrl;

  const AutoEcoleInfo({
    required this.nom,
    required this.telephone,
    required this.email,
    this.logoUrl,
  });

  factory AutoEcoleInfo.fromJson(Map<String, dynamic> json) {
    return AutoEcoleInfo(
      nom: json['nom'] ?? 'Auto-École Pro',
      telephone: json['telephone'] ?? '+228 90 00 00 00',
      email: json['email'] ?? 'contact@autoecole.com',
      logoUrl: json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'telephone': telephone,
    'email': email,
    'logo_url': logoUrl,
  };
}

class CandidatDetails {
  final String id;
  final String codeAcces;
  final String nom;
  final String prenom;
  final String contact;
  final String categoriePermis;
  final String langue;
  final String typeFormation;
  final String statut;
  final String dateInscription;
  final String? photoUrl;
  final int nbConduitesPrevues;
  final int nbConduitesEffectuees;
  final int nbConduitesRestantes;
  final String? dateExamenCode;
  final String statutExamenCode;
  final String? dateExamenConduite;
  final String statutExamenConduite;
  final int montantTotal;
  final int montantPaye;
  final int montantRestant;
  final bool estSolde;

  const CandidatDetails({
    required this.id,
    required this.codeAcces,
    required this.nom,
    required this.prenom,
    required this.contact,
    required this.categoriePermis,
    required this.langue,
    required this.typeFormation,
    required this.statut,
    required this.dateInscription,
    this.photoUrl,
    required this.nbConduitesPrevues,
    required this.nbConduitesEffectuees,
    required this.nbConduitesRestantes,
    this.dateExamenCode,
    required this.statutExamenCode,
    this.dateExamenConduite,
    required this.statutExamenConduite,
    required this.montantTotal,
    required this.montantPaye,
    required this.montantRestant,
    required this.estSolde,
  });

  String get nomComplet => '$nom $prenom';

  double get progressionPermis {
    double p = 0.0;
    // 40% pour la conduite
    if (nbConduitesPrevues > 0) {
      p += (nbConduitesEffectuees / nbConduitesPrevues).clamp(0.0, 1.0) * 0.40;
    }
    // 30% pour l'examen de code
    if (statutExamenCode == 'ADMIS') {
      p += 0.30;
    } else if (statutExamenCode == 'PROGRAMME') {
      p += 0.15;
    }
    // 30% pour l'examen de conduite
    if (statutExamenConduite == 'ADMIS') {
      p += 0.30;
    } else if (statutExamenConduite == 'PROGRAMME') {
      p += 0.15;
    }
    return p.clamp(0.0, 1.0);
  }

  factory CandidatDetails.fromJson(Map<String, dynamic> json) {
    final prev = json['nb_conduites_prevues'] as int? ?? 20;
    final eff = json['nb_conduites_effectuees'] as int? ?? 0;
    final total = json['montant_total'] as int? ?? 0;
    final paye = json['montant_paye'] as int? ?? 0;

    return CandidatDetails(
      id: json['id'] ?? '',
      codeAcces: json['code_acces'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      contact: json['contact'] ?? '',
      categoriePermis: json['categorie_permis'] ?? 'B',
      langue: json['langue'] ?? 'FRANCAIS',
      typeFormation: json['type_formation'] ?? 'Formation Normale',
      statut: json['statut'] ?? 'INSCRIT',
      dateInscription: json['date_inscription'] ?? '',
      photoUrl: json['photo_url'],
      nbConduitesPrevues: prev,
      nbConduitesEffectuees: eff,
      nbConduitesRestantes: (prev - eff).clamp(0, prev),
      dateExamenCode: json['date_examen_code'],
      statutExamenCode: json['statut_examen_code'] ?? 'NON_PROGRAMME',
      dateExamenConduite: json['date_examen_conduite'],
      statutExamenConduite: json['statut_examen_conduite'] ?? 'NON_PROGRAMME',
      montantTotal: total,
      montantPaye: paye,
      montantRestant: (total - paye).clamp(0, total),
      estSolde: paye >= total && total > 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code_acces': codeAcces,
    'nom': nom,
    'prenom': prenom,
    'contact': contact,
    'categorie_permis': categoriePermis,
    'langue': langue,
    'type_formation': typeFormation,
    'statut': statut,
    'date_inscription': dateInscription,
    'photo_url': photoUrl,
    'nb_conduites_prevues': nbConduitesPrevues,
    'nb_conduites_effectuees': nbConduitesEffectuees,
    'date_examen_code': dateExamenCode,
    'statut_examen_code': statutExamenCode,
    'date_examen_conduite': dateExamenConduite,
    'statut_examen_conduite': statutExamenConduite,
    'montant_total': montantTotal,
    'montant_paye': montantPaye,
  };
}

class SeanceCandidat {
  final String id;
  final String typeSeance; // 'CODE' ou 'CONDUITE'
  final DateTime dateHeure;
  final int dureeMinutes;
  final String moniteurNom;
  final String statut; // 'PLANIFIE', 'EFFECTUE', 'ANNULE'
  final String? notes;

  const SeanceCandidat({
    required this.id,
    required this.typeSeance,
    required this.dateHeure,
    required this.dureeMinutes,
    required this.moniteurNom,
    required this.statut,
    this.notes,
  });

  bool get estEffectue => statut == 'EFFECTUE';
  bool get estConduite => typeSeance == 'CONDUITE';

  factory SeanceCandidat.fromJson(Map<String, dynamic> json) {
    return SeanceCandidat(
      id: json['id'] ?? '',
      typeSeance: json['type_seance'] ?? 'CONDUITE',
      dateHeure: DateTime.tryParse(json['date_heure'] ?? '') ?? DateTime.now(),
      dureeMinutes: json['duree_minutes'] as int? ?? 60,
      moniteurNom: json['moniteur_nom'] ?? 'Moniteur Certifié',
      statut: json['statut'] ?? 'PLANIFIE',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type_seance': typeSeance,
    'date_heure': dateHeure.toIso8601String(),
    'duree_minutes': dureeMinutes,
    'moniteur_nom': moniteurNom,
    'statut': statut,
    'notes': notes,
  };
}

class PaiementCandidat {
  final String id;
  final int montant;
  final String datePaiement;
  final String moyenPaiement;
  final String? recuNumero;

  const PaiementCandidat({
    required this.id,
    required this.montant,
    required this.datePaiement,
    required this.moyenPaiement,
    this.recuNumero,
  });

  factory PaiementCandidat.fromJson(Map<String, dynamic> json) {
    return PaiementCandidat(
      id: json['id'] ?? '',
      montant: json['montant'] as int? ?? 0,
      datePaiement: json['date_paiement'] ?? '',
      moyenPaiement: json['moyen_paiement'] ?? 'Espèces',
      recuNumero: json['recu_numero'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'montant': montant,
    'date_paiement': datePaiement,
    'moyen_paiement': moyenPaiement,
    'recu_numero': recuNumero,
  };
}

class CandidatPortalData {
  final AutoEcoleInfo entreprise;
  final CandidatDetails candidat;
  final List<SeanceCandidat> seances;
  final List<PaiementCandidat> paiements;

  const CandidatPortalData({
    required this.entreprise,
    required this.candidat,
    required this.seances,
    required this.paiements,
  });

  factory CandidatPortalData.fromJson(Map<String, dynamic> json) {
    final seancesJson = json['seances'] as List<dynamic>? ?? [];
    final paiementsJson = json['paiements'] as List<dynamic>? ?? [];

    return CandidatPortalData(
      entreprise: AutoEcoleInfo.fromJson(json['entreprise'] as Map<String, dynamic>? ?? {}),
      candidat: CandidatDetails.fromJson(json['candidat'] as Map<String, dynamic>? ?? {}),
      seances: seancesJson.map((s) => SeanceCandidat.fromJson(s as Map<String, dynamic>)).toList(),
      paiements: paiementsJson.map((p) => PaiementCandidat.fromJson(p as Map<String, dynamic>)).toList(),
    );
  }
}
