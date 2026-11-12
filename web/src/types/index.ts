export type RoleUtilisateur = 'SUPER_ADMIN' | 'DG' | 'SECRETAIRE' | 'CANDIDAT';
export type CategoriePermis = 'A' | 'B' | 'C' | 'D' | 'E';
export type StatutCandidat = 'INSCRIT' | 'ADMIS' | 'NON_ADMIS';
export type Langue = 'FRANCAIS' | 'EWE' | 'MINA' | 'MOBA' | 'KOTOKOLI' | 'KABYE' | 'ANGLAIS';
export type Sexe = 'MASCULIN' | 'FEMININ';
export type TypeDepense = 'NORMALE' | 'FIXE' | 'SPECIALE_DG' | 'SECRETAIRE';
export type TypeFormation = 'COMPLETE' | 'CONDUITE_SEULE' | 'CODE_SEUL' | 'RECYCLAGE';

export interface Candidat {
  id: string;
  nom: string;
  prenom: string;
  contact: string;
  email?: string;
  adresse?: string;
  annexe: string;
  categorie: CategoriePermis;
  langue: Langue;
  sexe: Sexe;
  montant_total: number;
  montant_paye: number;
  date_inscription: string;
  duree_formation_mois?: number;
  statut: StatutCandidat;
  code_acces?: string;
  type_formation?: TypeFormation;
  nb_conduites_prevues?: number;
  nb_conduites_effectuees?: number;
  date_examen_code?: string;
  statut_examen_code?: 'NON_PROGRAMME' | 'PROGRAMME' | 'ADMIS' | 'AJOURNE';
  date_examen_conduite?: string;
  statut_examen_conduite?: 'NON_PROGRAMME' | 'PROGRAMME' | 'ADMIS' | 'AJOURNE';
  photo_url?: string;
}

export interface Depense {
  id: string;
  date: string;
  type: TypeDepense;
  intitule: string;
  annexe: string;
  montant: number;
}

export interface Recette {
  id: string;
  date: string;
  intitule: string;
  annexe: string;
  montant: number;
  candidat_id?: string;
}

export interface BilanMois {
  mois: string;
  revenus: number;
  depenses: number;
  solde: number;
}
