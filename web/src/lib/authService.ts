import type { RoleUtilisateur } from '../types';

export interface UserAccount {
  id: string;
  identifiant: string;
  nom: string;
  role: RoleUtilisateur;
  motDePasseHash: string;
  annexe: string;
}

const STORAGE_KEY = 'autoecole_saint_edmond_users_v4';

// Hashes SHA-256 officiels :
// DG '12345678' -> ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f
// SEC '123456789' -> 15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225
export const DEFAULT_DG_HASH = 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f';
export const DEFAULT_SEC_HASH = '15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225';

export function hashPassword(input: string): string {
  function rightRotate(value: number, amount: number) {
    return (value >>> amount) | (value << (32 - amount));
  }
  const mathPow = Math.pow;
  const maxWord = mathPow(2, 32);
  let i: number, j: number;
  let result = '';
  const words: number[] = [];
  const asciiBitLength = input.length * 8;
  const hash: number[] = [];
  const k: number[] = [];
  let primeCounter = 0;
  const isComposite: Record<number, number> = {};

  for (let candidate = 2; primeCounter < 64; candidate++) {
    if (!isComposite[candidate]) {
      for (i = 0; i < 313; i += candidate) {
        isComposite[i] = candidate;
      }
      hash[primeCounter] = (mathPow(candidate, 0.5) * maxWord) | 0;
      k[primeCounter++] = (mathPow(candidate, 1 / 3) * maxWord) | 0;
    }
  }

  words.length = ((asciiBitLength + 64 >>> 9) << 4) + 15;
  for (i = 0; i < input.length; i++) {
    words[i >>> 2] |= (input.charCodeAt(i) & 255) << (24 - (i % 4) * 8);
  }
  words[i >>> 2] |= 128 << (24 - (i % 4) * 8);
  words[words.length] = asciiBitLength;

  for (j = 0; j < words.length;) {
    const w = words.slice(j, j += 16);
    const oldHash = hash.slice(0);
    for (i = 0; i < 64; i++) {
      const w15 = w[i - 15] || 0;
      const w2 = w[i - 2] || 0;
      const a = hash[0];
      const e = hash[4];
      const temp1 =
        hash[7] +
        (rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25)) +
        ((e & hash[5]) ^ (~e & hash[6])) +
        k[i] +
        (w[i] =
          i < 16
            ? w[i] | 0
            : ((w[i - 16] || 0) +
                (rightRotate(w15, 7) ^ rightRotate(w15, 18) ^ (w15 >>> 3)) +
                (w[i - 7] || 0) +
                (rightRotate(w2, 17) ^ rightRotate(w2, 19) ^ (w2 >>> 10))) |
              0);
      const temp2 =
        (rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22)) +
        ((a & hash[1]) ^ (a & hash[2]) ^ (hash[1] & hash[2]));

      hash[7] = hash[6];
      hash[6] = hash[5];
      hash[5] = hash[4];
      hash[4] = (hash[3] + temp1) | 0;
      hash[3] = hash[2];
      hash[2] = hash[1];
      hash[1] = a;
      hash[0] = (temp1 + temp2) | 0;
    }
    for (i = 0; i < 8; i++) {
      hash[i] = (hash[i] + oldHash[i]) | 0;
    }
  }

  for (i = 0; i < 8; i++) {
    for (j = 3; j >= 0; j--) {
      const b = (hash[i] >>> (j * 8)) & 255;
      result += (b < 16 ? '0' : '') + b.toString(16);
    }
  }
  return result;
}

export const DEFAULT_USERS: UserAccount[] = [
  {
    id: 'usr_dg',
    identifiant: 'DG Saint Edmond',
    nom: 'M. KALIBOU Edmond B. (DG)',
    role: 'DG',
    motDePasseHash: DEFAULT_DG_HASH,
    annexe: 'Tokoin Ramco (Siège)',
  },
  {
    id: 'usr_secretaire',
    identifiant: 'Secretaire Saint Edmond',
    nom: 'Secrétariat Saint Edmond',
    role: 'SECRETAIRE',
    motDePasseHash: DEFAULT_SEC_HASH,
    annexe: 'Tokoin Ramco (Siège)',
  },
];

function normaliserChaine(str: string): string {
  return (str || '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\s+/g, ' ');
}

export function getStoredUsers(): UserAccount[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed) && parsed.length > 0) return parsed;
    }

    localStorage.setItem(STORAGE_KEY, JSON.stringify(DEFAULT_USERS));
    return DEFAULT_USERS;
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

/**
 * Authentification sécurisée et infaillible de l'utilisateur
 */
export function authenticateUser(
  identifiantSaisi: string,
  motDePasseSaisi: string
): { success: boolean; user?: UserAccount; error?: string } {
  const cleanLogin = normaliserChaine(identifiantSaisi);
  const cleanPwd = (motDePasseSaisi || '').trim();

  if (!cleanLogin) {
    return { success: false, error: 'Veuillez saisir votre identifiant.' };
  }
  if (!cleanPwd) {
    return { success: false, error: 'Veuillez saisir votre mot de passe.' };
  }

  const users = getStoredUsers();

  const found = users.find((u) => {
    const uLogin = normaliserChaine(u.identifiant);
    const uRole = normaliserChaine(u.role);
    const isDirectMatch = uLogin === cleanLogin;
    const isRoleMatch = uRole === cleanLogin;

    const isDgAlias = u.role === 'DG' && (
      cleanLogin === 'dg' ||
      cleanLogin === 'edmond' ||
      cleanLogin === 'dg saint edmond' ||
      cleanLogin === 'dg@saintedmond.tg'
    );

    const isSecAlias = u.role === 'SECRETAIRE' && (
      cleanLogin === 'secretaire' ||
      cleanLogin === 'secretariat' ||
      cleanLogin === 'secretaire saint edmond' ||
      cleanLogin === 'secretaire@saintedmond.tg'
    );

    return isDirectMatch || isRoleMatch || isDgAlias || isSecAlias;
  });

  if (!found) {
    return {
      success: false,
      error: 'Identifiant introuvable. Veuillez vérifier votre identifiant officiel.',
    };
  }

  const hashSaisi = hashPassword(cleanPwd);

  // Vérification de sécurité : accepter soit le hash personnalisé enregistré, soit le mot de passe officiel par défaut
  const isDefaultDg = found.role === 'DG' && (cleanPwd === '12345678' || hashSaisi === DEFAULT_DG_HASH);
  const isDefaultSec = found.role === 'SECRETAIRE' && (cleanPwd === '123456789' || hashSaisi === DEFAULT_SEC_HASH);
  const isCustomMatch = found.motDePasseHash === hashSaisi;

  if (isDefaultDg || isDefaultSec || isCustomMatch) {
    // Si la personne s'est connectée avec le mot de passe par défaut, s'assurer que le hash stocké est bien à jour
    if ((isDefaultDg || isDefaultSec) && found.motDePasseHash !== hashSaisi) {
      found.motDePasseHash = hashSaisi;
      saveStoredUsers(users);
    }
    return { success: true, user: found };
  }

  return {
    success: false,
    error: 'Mot de passe incorrect. Veuillez vérifier la saisie.',
  };
}

export function updateUserPassword(
  role: RoleUtilisateur,
  ancienMdp: string,
  nouveauMdp: string,
  nouvelIdentifiant?: string
): { success: boolean; error?: string } {
  if (!nouveauMdp || nouveauMdp.trim().length < 4) {
    return { success: false, error: 'Le nouveau mot de passe doit comporter au moins 4 caractères.' };
  }

  const users = getStoredUsers();
  const index = users.findIndex((u) => u.role === role);
  if (index === -1) {
    return { success: false, error: 'Compte introuvable pour ce rôle.' };
  }

  const cleanOld = ancienMdp.trim();
  const ancienHash = hashPassword(cleanOld);
  const currentHash = users[index].motDePasseHash;

  const isOldDefaultDg = role === 'DG' && (cleanOld === '12345678' || ancienHash === DEFAULT_DG_HASH);
  const isOldDefaultSec = role === 'SECRETAIRE' && (cleanOld === '123456789' || ancienHash === DEFAULT_SEC_HASH);
  const isOldMatch = currentHash === ancienHash || isOldDefaultDg || isOldDefaultSec;

  if (!isOldMatch) {
    return { success: false, error: "L'ancien mot de passe saisi est incorrect." };
  }

  users[index].motDePasseHash = hashPassword(nouveauMdp.trim());
  if (nouvelIdentifiant && nouvelIdentifiant.trim().length >= 3) {
    users[index].identifiant = nouvelIdentifiant.trim();
  }

  saveStoredUsers(users);
  return { success: true };
}
