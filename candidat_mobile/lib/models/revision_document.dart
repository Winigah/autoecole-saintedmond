class RevisionDocument {
  final String id;
  final String titre;
  final String description;
  final String categorie; // CODE, CONDUITE, PANNEAUX, GENERAL
  final String urlPdf;
  final String dateAjout;
  final String? taille;

  RevisionDocument({
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

  factory RevisionDocument.fromJson(Map<String, dynamic> json) => RevisionDocument(
    id: json['id'] ?? '',
    titre: json['titre'] ?? '',
    description: json['description'] ?? '',
    categorie: json['categorie'] ?? 'CODE',
    urlPdf: json['url_pdf'] ?? '',
    dateAjout: json['date_ajout'] ?? '',
    taille: json['taille'] ?? 'PDF',
  );
}
