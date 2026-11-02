import type { RoleUtilisateur } from '../types';

export interface UserAccount {
  id: string;
  identifiant: string;
  nom: string;
  role: RoleUtilisateur;
  motDePasse: string;
  annexe: string;
}

const STORAGE_KEY = 'autoecole_saint_edmond_users_v1';

export const DEFAULT_USERS: UserAccount[] = [
  {
    id: 'usr_dg',
    identifiant: 'dg@saintedmond.tg',
    nom: 'M. KALIBOU Edmond B.',
    role: 'DG',
    motDePasse: 'Edmond2026!',
    annexe: 'Tokoin Ramco (Siège)',
  },
  {
    id: 'usr_secretaire',
    identifiant: 'secretaire@saintedmond.tg',
    nom: 'Secrétariat Saint Edmond',
    role: 'SECRETAIRE',
    motDePasse: 'Secret2026!',
    annexe: 'Tokoin Ramco (Siège)',
  },
];

export function getStoredUsers(): UserAccount[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(DEFAULT_USERS));
      return DEFAULT_USERS;
    }
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed) || parsed.length === 0) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(DEFAULT_USERS));
      return DEFAULT_USERS;
    }
    return parsed;
  } catch {
    return DEFAULT_USERS;
  }
}

export function saveStoredUsers(users: UserAccount[]): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(users));
  } catch (err) {
    console.error('Erreur sauvegarde utilisateurs:', err);
  }
}

export function authenticateUser(
  identifiantSaisi: string,
  motDePasseSaisi: string
): { success: boolean; user?: UserAccount; error?: string } {
  const users = getStoredUsers();
  const cleanLogin = identifiantSaisi.trim().toLowerCase();
  
  const found = users.find((u) => {
    const uLogin = u.identifiant.toLowerCase();
    const uRole = u.role.toLowerCase();
    return uLogin === cleanLogin || uRole === cleanLogin || (u.role === 'DG' && (cleanLogin === 'edmond' || cleanLogin === 'dg'));
  });

  if (!found) {
    return {
      success: false,
      error: 'Identifiant introuvable. Utilisez les accès officiels fournis par la direction.',
    };
  }

  if (found.motDePasse !== motDePasseSaisi) {
    return {
      success: false,
      error: 'Mot de passe incorrect. Veuillez vérifier la saisie.',
    };
  }

  return { success: true, user: found };
}

export function updateUserPassword(
  role: RoleUtilisateur,
  ancienMdp: string,
  nouveauMdp: string
): { success: boolean; error?: string } {
  if (!nouveauMdp || nouveauMdp.length < 4) {
    return { success: false, error: 'Le nouveau mot de passe doit comporter au moins 4 caractères.' };
  }

  const users = getStoredUsers();
  const index = users.findIndex((u) => u.role === role);
  if (index === -1) {
    return { success: false, error: 'Compte introuvable pour ce rôle.' };
  }

  if (users[index].motDePasse !== ancienMdp) {
    return { success: false, error: 'L\'ancien mot de passe saisi est incorrect.' };
  }

  users[index].motDePasse = nouveauMdp;
  saveStoredUsers(users);
  return { success: true };
}
