class Candidat {
  final String id;
  final String nom;
  final String prenom;
  final String contact;
  final String? email;
  final String? adresse;
  final String annexe;
  final String categorie;
  final String langue;
  final String sexe;
  final int montantTotal;
  final int montantPaye;
  final String dateInscription;
  final int? dureeFormationMois;
  final String statut;

  final String? codeAcces;
  final String? photoUrl;

  Candidat({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.contact,
    this.email,
    this.adresse,
    required this.annexe,
    required this.categorie,
    required this.langue,
    required this.sexe,
    required this.montantTotal,
    required this.montantPaye,
    required this.dateInscription,
    this.dureeFormationMois,
    required this.statut,
    this.codeAcces,
    this.photoUrl,
  });

  int get resteAPayer => montantTotal - montantPaye;
  bool get estSolde => montantPaye >= montantTotal;

  factory Candidat.fromJson(Map<String, dynamic> json) {
    return Candidat(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      contact: json['contact'] ?? '',
      email: json['email'],
      adresse: json['adresse'],
      annexe: json['annexe'] ?? 'Tokoin Ramco (Siège)',
      categorie: json['categorie'] ?? 'B',
      langue: json['langue'] ?? 'FRANCAIS',
      sexe: json['sexe'] ?? 'MASCULIN',
      montantTotal: json['montant_total'] ?? 0,
      montantPaye: json['montant_paye'] ?? 0,
      dateInscription: json['date_inscription'] ?? '',
      dureeFormationMois: json['duree_formation_mois'],
      statut: json['statut'] ?? 'INSCRIT',
      codeAcces: json['code_acces'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'contact': contact,
      'email': email,
      'adresse': adresse,
      'annexe': annexe,
      'categorie': categorie,
      'langue': langue,
      'sexe': sexe,
      'montant_total': montantTotal,
      'montant_paye': montantPaye,
      'date_inscription': dateInscription,
      'duree_formation_mois': dureeFormationMois,
      'statut': statut,
      'code_acces': codeAcces,
      'photo_url': photoUrl,
    };
  }
}
