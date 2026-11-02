import 'package:flutter/material.dart';

class QuestionQuiz {
  final int id;
  final String question;
  final List<String> options;
  final int reponseCorrecte;
  final String explication;
  final String categorie;

  const QuestionQuiz({
    required this.id,
    required this.question,
    required this.options,
    required this.reponseCorrecte,
    required this.explication,
    required this.categorie,
  });
}

class PanneauSignalisation {
  final String titre;
  final String description;
  final String categorie;
  final IconData icone;
  final Color couleur;

  const PanneauSignalisation({
    required this.titre,
    required this.description,
    required this.categorie,
    required this.icone,
    required this.couleur,
  });
}

class QuizDataBank {
  static const List<QuestionQuiz> questions = [
    QuestionQuiz(
      id: 1,
      question: "En l'absence de toute signalisation à un croisement, quelle règle de priorité s'applique ?",
      options: [
        "Priorité aux véhicules venant de gauche",
        "Priorité à droite stricte",
        "Priorité au véhicule le plus rapide",
        "Priorité au véhicule le plus lourd",
      ],
      reponseCorrecte: 1,
      explication: "En l'absence de panneaux ou de feux, la règle générale du code de la route est la priorité à droite.",
      categorie: "Priorités",
    ),
    QuestionQuiz(
      id: 2,
      question: "Quelle est la vitesse maximale autorisée en agglomération (ville) selon le code de la route ?",
      options: [
        "40 km/h",
        "50 km/h",
        "60 km/h",
        "70 km/h",
      ],
      reponseCorrecte: 1,
      explication: "En agglomération, pour la sécurité des piétons et des usagers vulnérables, la vitesse est limitée à 50 km/h sauf indication contraire.",
      categorie: "Vitesses",
    ),
    QuestionQuiz(
      id: 3,
      question: "Que signifie un panneau triangulaire bordé de rouge avec une flèche pointant vers le haut ?",
      options: [
        "Obligation d'aller tout droit",
        "Sens interdit",
        "Danger : rétrécissement de la voie",
        "Danger : priorité ponctuelle à la prochaine intersection",
      ],
      reponseCorrecte: 3,
      explication: "Le panneau triangulaire bordé de rouge annonce un danger. La flèche épaisse indique que vous êtes prioritaire au prochain carrefour.",
      categorie: "Signalisation",
    ),
    QuestionQuiz(
      id: 4,
      question: "Le port de la ceinture de sécurité est-il obligatoire pour tous les passagers à bord ?",
      options: [
        "Uniquement pour le conducteur",
        "Conducteur et passager avant seulement",
        "Obligatoire à l'avant et à l'arrière pour tous les occupants",
        "Uniquement sur autoroute",
      ],
      reponseCorrecte: 2,
      explication: "La ceinture de sécurité est obligatoire pour tous les occupants du véhicule, à l'avant comme à l'arrière.",
      categorie: "Sécurité",
    ),
    QuestionQuiz(
      id: 5,
      question: "En cas de panne sur la chaussée, quelle est la première mesure de sécurité à prendre ?",
      options: [
        "Appeler immédiatement un mécanicien",
        "Allumer les feux de détresse et placer le triangle de pré-signalisation",
        "Laisser le véhicule et courir chercher de l'aide",
        "Pousser seul le véhicule au milieu de la voie",
      ],
      reponseCorrecte: 1,
      explication: "Dès l'arrêt forcé, il faut allumer les feux de détresse (warning), enfiler le gilet rétro-réfléchissant et poser le triangle à au moins 30 mètres.",
      categorie: "Urgences",
    ),
    QuestionQuiz(
      id: 6,
      question: "Sur un rond-point giratoire muni du panneau 'Cédez le passage', qui a la priorité ?",
      options: [
        "Les véhicules qui entrent dans le rond-point",
        "Les véhicules déjà engagés sur l'anneau giratoire",
        "Les deux-roues en priorité",
        "Le véhicule le plus proche de la sortie",
      ],
      reponseCorrecte: 1,
      explication: "Sur un carrefour à sens giratoire, les véhicules qui circulent déjà sur l'anneau sont prioritaires par rapport à ceux qui s'y engagent.",
      categorie: "Priorités",
    ),
    QuestionQuiz(
      id: 7,
      question: "Quelle est la distance de sécurité minimale à maintenir par temps sec sur route hors agglomération ?",
      options: [
        "Au moins 1 seconde de réaction",
        "Au moins 2 secondes entre deux véhicules",
        "5 mètres exactement",
        "La moitié de la longueur du véhicule",
      ],
      reponseCorrecte: 1,
      explication: "La règle d'or est de maintenir au minimum 2 secondes d'intervalle avec le véhicule qui vous précède.",
      categorie: "Conduite défensive",
    ),
    QuestionQuiz(
      id: 8,
      question: "L'usage du téléphone portable tenu en main au volant est :",
      options: [
        "Toléré uniquement aux feux rouges",
        "Strictement interdit en circulation",
        "Autorisé si l'on roule à moins de 30 km/h",
        "Autorisé uniquement pour les SMS courts",
      ],
      reponseCorrecte: 1,
      explication: "L'usage du téléphone tenu en main au volant multiplie par 3 le risque d'accident et est formellement interdit par la loi.",
      categorie: "Sécurité",
    ),
    QuestionQuiz(
      id: 9,
      question: "Que devez-vous faire à la vue d'un feu orange fixe ?",
      options: [
        "Accélérer rapidement pour passer avant le rouge",
        "Klaxonner et maintenir sa vitesse",
        "S'arrêter obligatoirement, sauf impossibilité dans des conditions de sécurité suffisantes",
        "Reculer pour laisser la place aux piétons",
      ],
      reponseCorrecte: 2,
      explication: "Le feu orange impose l'arrêt. Le franchissement n'est toléré que si l'arrêt brusque risquait de provoquer une collision par l'arrière.",
      categorie: "Signalisation",
    ),
    QuestionQuiz(
      id: 10,
      question: "Quel est le taux légal maximal d'alcoolémie autorisé au volant ?",
      options: [
        "0,8 g/l de sang",
        "0,5 g/l de sang (et 0,2 g/l pour les jeunes conducteurs)",
        "1,2 g/l de sang",
        "Il n'y a pas de limite précise",
      ],
      reponseCorrecte: 1,
      explication: "La limite légale est de 0,5 g d'alcool par litre de sang (0,25 mg/l d'air expiré) pour les conducteurs confirmés.",
      categorie: "Réglementation",
    ),
    QuestionQuiz(
      id: 11,
      question: "La nuit sur une route éclairée en agglomération, quels feux devez-vous utiliser ?",
      options: [
        "Les feux de route (pleins phares)",
        "Les feux de croisement",
        "Uniquement les feux de position",
        "Aucun feu car la route est éclairée",
      ],
      reponseCorrecte: 1,
      explication: "En agglomération éclairée, il faut circuler avec les feux de croisement pour voir et être vu sans éblouir autrui.",
      categorie: "Éclairage",
    ),
    QuestionQuiz(
      id: 12,
      question: "Que signifie une ligne continue peinte au milieu de la chaussée ?",
      options: [
        "Dépassement autorisé si la voie est libre",
        "Interdiction absolue de la franchir ou de la chevaucher",
        "Zone de stationnement autorisée",
        "Voie réservée aux transports en commun",
      ],
      reponseCorrecte: 1,
      explication: "Une ligne continue est un mur infranchissable. Il est strictement interdit de la franchir ou de la chevaucher.",
      categorie: "Marquage au sol",
    ),
    QuestionQuiz(
      id: 13,
      question: "À quelle fréquence minimale devez-vous vérifier la pression des pneumatiques de votre voiture ?",
      options: [
        "Une fois par an lors du contrôle technique",
        "Au moins une fois par mois et avant un long trajet",
        "Uniquement lorsque le pneu semble dégonflé",
        "Tous les matins avant de démarrer",
      ],
      reponseCorrecte: 1,
      explication: "La pression des pneus doit être contrôlée au moins une fois par mois et impérativement à froid avant les longs trajets.",
      categorie: "Mécanique & Entretien",
    ),
    QuestionQuiz(
      id: 14,
      question: "Que devez-vous faire lorsqu'un véhicule de secours (ambulance, pompiers, police) approche avec gyrophare et sirène ?",
      options: [
        "Accélérer pour ne pas les gêner",
        "Faciliter immédiatement leur passage en serrant à droite ou en s'arrêtant",
        "Continuer sans changer de comportement",
        "Les suivre de très près pour profiter de leur priorité",
      ],
      reponseCorrecte: 1,
      explication: "Les véhicules prioritaires en intervention d'urgence ont la priorité absolue. Vous devez leur céder le passage immédiatement.",
      categorie: "Priorités",
    ),
    QuestionQuiz(
      id: 15,
      question: "Avant d'entamer un dépassement sur route, quelle est la première action à réaliser ?",
      options: [
        "Rétrograder en 2ème vitesse",
        "Contrôler les rétroviseurs et l'angle mort pour s'assurer qu'aucun véhicule ne vous dépasse déjà",
        "Mettre les feux de détresse",
        "Klaxonner longuement",
      ],
      reponseCorrecte: 1,
      explication: "La sécurité commence par la vision : contrôler le rétroviseur intérieur, l'extérieur gauche et l'angle mort avant de mettre son clignotant.",
      categorie: "Dépassement",
    ),
    QuestionQuiz(
      id: 16,
      question: "En cas d'aquaplanage (perte d'adhérence due à l'eau sur la chaussée), vous devez :",
      options: [
        "Freiner à fond et braquer vigoureusement",
        "Débrayer, garder les roues droites et relâcher doucement l'accélérateur sans freiner brusquement",
        "Tirer le frein à main",
        "Accélérer pour chasser l'eau sous les pneus",
      ],
      reponseCorrecte: 1,
      explication: "En cas d'aquaplanage, tout coup de volant ou freinage brutal provoque le tête-à-queue. Il faut maintenir les roues droites et relâcher l'accélérateur.",
      categorie: "Conditions difficiles",
    ),
    QuestionQuiz(
      id: 17,
      question: "À quelle distance maximale du trottoir devez-vous stationner en créneau le long de la chaussée ?",
      options: [
        "Moins de 20 centimètres",
        "Moins de 50 centimètres",
        "1 mètre",
        "Peu importe tant que le clignotant est allumé",
      ],
      reponseCorrecte: 0,
      explication: "Le stationnement doit s'effectuer le plus près possible du bord de la chaussée, idéalement à moins de 20 cm sans heurter la bordure.",
      categorie: "Stationnement",
    ),
    QuestionQuiz(
      id: 18,
      question: "Que signifie un panneau circulaire bleu avec un vélo blanc dessiné ?",
      options: [
        "Interdiction aux vélos",
        "Piste ou bande cyclable obligatoire pour les cyclistes",
        "Danger : traversée de cyclistes",
        "Vente de bicyclettes",
      ],
      reponseCorrecte: 1,
      explication: "Les panneaux ronds à fond bleu expriment une obligation. Ici, la piste est réservée et obligatoire pour les cyclistes.",
      categorie: "Signalisation",
    ),
    QuestionQuiz(
      id: 19,
      question: "Pour les motocyclistes et leurs passagers, le port du casque homologué est :",
      options: [
        "Recommandé mais facultatif en journée",
        "Obligatoire uniquement pour le conducteur",
        "Obligatoire pour le conducteur ET le passager en toutes circonstances",
        "Obligatoire uniquement hors agglomération",
      ],
      reponseCorrecte: 2,
      explication: "Le casque attaché et homologué est strictement obligatoire pour toute personne transportée sur un deux-roues motorisé.",
      categorie: "Sécurité",
    ),
    QuestionQuiz(
      id: 20,
      question: "Quelle est la note minimale pour réussir l'examen théorique officiel du Code de la Route ?",
      options: [
        "15 sur 20",
        "16 sur 20",
        "17 sur 20",
        "20 sur 20",
      ],
      reponseCorrecte: 1,
      explication: "Pour être déclaré admis, le candidat doit obtenir un minimum de 16/20 (soit au maximum 4 erreurs tolérées sur 20 questions).",
      categorie: "Examen",
    ),
  ];

  static const List<PanneauSignalisation> panneaux = [
    // Dangers
    PanneauSignalisation(
      titre: "Virage dangereux à droite",
      description: "Ralentir avant d'aborder la courbe pour éviter la sortie de route.",
      categorie: "Danger",
      icone: Icons.turn_right_rounded,
      couleur: Color(0xFFEF4444),
    ),
    PanneauSignalisation(
      titre: "Intersection avec priorité à droite",
      description: "Annonce un croisement où la priorité à droite s'applique obligatoirement.",
      categorie: "Danger",
      icone: Icons.close_rounded,
      couleur: Color(0xFFEF4444),
    ),
    PanneauSignalisation(
      titre: "Passage piétons",
      description: "Ralentir et céder le passage aux piétons engagés ou sur le point de s'engager.",
      categorie: "Danger",
      icone: Icons.directions_walk_rounded,
      couleur: Color(0xFFEF4444),
    ),
    PanneauSignalisation(
      titre: "Ralentisseur de type dos-d'âne",
      description: "Réduire la vitesse à 30 km/h pour préserver la mécanique et la sécurité.",
      categorie: "Danger",
      icone: Icons.waves_rounded,
      couleur: Color(0xFFEF4444),
    ),

    // Interdictions
    PanneauSignalisation(
      titre: "Sens interdit à tout véhicule",
      description: "Accès formellement prohibé. Danger immédiat de choc frontal.",
      categorie: "Interdiction",
      icone: Icons.do_not_disturb_on_total_silence_rounded,
      couleur: Color(0xFFDC2626),
    ),
    PanneauSignalisation(
      titre: "Limitation de vitesse 50 km/h",
      description: "Vitesse maximale autorisée. Tout dépassement est verbalisé.",
      categorie: "Interdiction",
      icone: Icons.speed_rounded,
      couleur: Color(0xFFDC2626),
    ),
    PanneauSignalisation(
      titre: "Interdiction de dépasser",
      description: "Dépassement interdit de tous les véhicules à moteur (sauf deux-roues sans side-car).",
      categorie: "Interdiction",
      icone: Icons.swap_horiz_rounded,
      couleur: Color(0xFFDC2626),
    ),
    PanneauSignalisation(
      titre: "Stationnement interdit",
      description: "Arrêt toléré pour déposer un passager, mais le stationnement prolongé est interdit.",
      categorie: "Interdiction",
      icone: Icons.not_interested_rounded,
      couleur: Color(0xFFDC2626),
    ),

    // Obligations
    PanneauSignalisation(
      titre: "Direction obligatoire tout droit",
      description: "Interdiction de tourner à gauche ou à droite à la prochaine intersection.",
      categorie: "Obligation",
      icone: Icons.arrow_upward_rounded,
      couleur: Color(0xFF2563EB),
    ),
    PanneauSignalisation(
      titre: "Contournement obligatoire par la droite",
      description: "Obligation de passer à droite du terre-plein ou de l'obstacle.",
      categorie: "Obligation",
      icone: Icons.arrow_outward_rounded,
      couleur: Color(0xFF2563EB),
    ),
    PanneauSignalisation(
      titre: "Piste cyclable obligatoire",
      description: "Voie réservée aux cycles. Interdite aux voitures et motos.",
      categorie: "Obligation",
      icone: Icons.directions_bike_rounded,
      couleur: Color(0xFF2563EB),
    ),
    PanneauSignalisation(
      titre: "Allumage des feux obligatoire",
      description: "Obligation d'allumer les feux de croisement (tunnel ou section sombre).",
      categorie: "Obligation",
      icone: Icons.lightbulb_outline_rounded,
      couleur: Color(0xFF2563EB),
    ),

    // Indications
    PanneauSignalisation(
      titre: "Voie sans issue (Cul-de-sac)",
      description: "La rue ne débouche sur aucun autre axe routier. Demi-tour requis pour sortir.",
      categorie: "Indication",
      icone: Icons.block_rounded,
      couleur: Color(0xFF0284C7),
    ),
    PanneauSignalisation(
      titre: "Poste de secours d'urgence",
      description: "Indique la présence d'un poste médical ou d'une borne d'appel d'urgence.",
      categorie: "Indication",
      icone: Icons.local_hospital_rounded,
      couleur: Color(0xFF0284C7),
    ),
    PanneauSignalisation(
      titre: "Poste de distribution de carburant",
      description: "Station-service ouverte sur l'itinéraire.",
      categorie: "Indication",
      icone: Icons.local_gas_station_rounded,
      couleur: Color(0xFF0284C7),
    ),
    PanneauSignalisation(
      titre: "Priorité ponctuelle",
      description: "Vous bénéficiez de la priorité de passage au prochain croisement.",
      categorie: "Indication",
      icone: Icons.shield_rounded,
      couleur: Color(0xFF0284C7),
    ),
  ];
}
