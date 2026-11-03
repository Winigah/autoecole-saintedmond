import type { RoleUtilisateur } from '../types';

export interface UserAccount {
  id: string;
  identifiant: string;
  nom: string;
  role: RoleUtilisateur;
  motDePasseHash: string;
  annexe: string;
}

const STORAGE_KEY = 'autoecole_saint_edmond_users_v2';
const LEGACY_STORAGE_KEY = 'autoecole_saint_edmond_users_v1';

/**
 * Fonction de hachage cryptographique SHA-256 synchrone et autonome.
 * Évite le stockage de mots de passe en clair dans le code ou le localStorage.
 */
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

// Comptes initiaux avec empreintes SHA-256 (aucun mot de passe en clair)
export const DEFAULT_USERS: UserAccount[] = [
  {
    id: 'usr_dg',
    identifiant: 'dg@saintedmond.tg',
    nom: 'M. KALIBOU Edmond B.',
    role: 'DG',
    motDePasseHash: '5679a7b31fab8c549392dc71dfaeadcd5c224e76ea6de9cea8182ab991eef3c9',
    annexe: 'Tokoin Ramco (Siège)',
  },
  {
    id: 'usr_secretaire',
    identifiant: 'secretaire@saintedmond.tg',
    nom: 'Secrétariat Saint Edmond',
    role: 'SECRETAIRE',
    motDePasseHash: '8262609c11ebba75e05137c9a4fba9f82960014ebb5111fb9d4eb0371e4b9a1b',
    annexe: 'Tokoin Ramco (Siège)',
  },
];

export function getStoredUsers(): UserAccount[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed) && parsed.length > 0) return parsed;
    }

    // Migration depuis l'ancienne clé v1 (si présente) avec conversion en hash
    const legacyRaw = localStorage.getItem(LEGACY_STORAGE_KEY);
    if (legacyRaw) {
      try {
        const legacy = JSON.parse(legacyRaw);
        if (Array.isArray(legacy) && legacy.length > 0) {
          const migrated: UserAccount[] = legacy.map((u: any) => ({
            id: u.id,
            identifiant: u.identifiant,
            nom: u.nom,
            role: u.role,
            motDePasseHash: u.motDePasseHash || (u.motDePasse ? hashPassword(u.motDePasse) : ''),
            annexe: u.annexe,
          }));
          localStorage.setItem(STORAGE_KEY, JSON.stringify(migrated));
          localStorage.removeItem(LEGACY_STORAGE_KEY);
          return migrated;
        }
      } catch {
        // Ignorer l'erreur de parsing legacy
      }
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

  const hashSaisi = hashPassword(motDePasseSaisi);
  // Vérification sécurisée par comparaison de hash SHA-256
  if (found.motDePasseHash !== hashSaisi) {
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

  const ancienHash = hashPassword(ancienMdp);
  if (users[index].motDePasseHash !== ancienHash) {
    return { success: false, error: "L'ancien mot de passe saisi est incorrect." };
  }

  users[index].motDePasseHash = hashPassword(nouveauMdp);
  saveStoredUsers(users);
  return { success: true };
}
