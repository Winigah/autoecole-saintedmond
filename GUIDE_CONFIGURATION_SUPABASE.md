# 🚀 Guide de Configuration Supabase — Auto-École Saint Edmond
### Vos clés restent 100% confidentielles sur votre ordinateur

Ce guide vous explique comment connecter votre application à votre propre base de données cloud Supabase en toute confidentialité.

---

## 1️⃣ Étape 1 : Créer votre projet Supabase (2 minutes)

1. Rendez-vous sur **[supabase.com](https://supabase.com)** et connectez-vous (ou créez un compte gratuit).
2. Cliquez sur **"New project"** :
   - **Name** : `autoecole-saintedmond`
   - **Database Password** : choisissez un mot de passe sécurisé (notez-le précieusement)
   - **Region** : `West Europe` (ou la région la plus proche)
3. Cliquez sur **"Create new project"** et patientez ~1 minute pendant la création.

---

## 2️⃣ Étape 2 : Créer les tables en 1 clic

Dans le tableau de bord de votre projet Supabase :
1. Dans le menu de gauche, cliquez sur **"SQL Editor"** (l'icône `>_`).
2. Cliquez sur **"New query"**.
3. Ouvrez le fichier suivant qui se trouve sur votre ordinateur :
   `AutoEcoleSaintEdmond/supabase_schema.sql`
4. Copiez l'intégralité du texte et collez-le dans l'éditeur SQL de Supabase.
5. Cliquez sur le bouton vert **"Run"** en bas à droite.
6. ✅ Vos tables (`candidats`, `depenses`, `recettes`, `annexes`, `presences`) sont prêtes avec sécurité RLS et synchronisation temps réel !

---

## 3️⃣ Étape 3 : Récupérer vos clés API

1. Dans le menu de gauche de Supabase, cliquez sur l'icône d'engrenage **Project Settings** puis sur **API** (ou **API Settings**).
2. Vous verrez deux informations :
   - **Project URL** (ex: `https://abcdefghijklm.supabase.co`)
   - **Project API Keys** -> `anon` / `public` (une longue clé)

---

## 4️⃣ Étape 4 : Activer le Cloud sur votre Web App

1. Allez dans le dossier :
   `AutoEcoleSaintEdmond/web`
2. Vous y trouverez un fichier exemple nommé `.env.example`.
3. Créez un fichier nommé `.env` dans ce même dossier `web` avec le contenu suivant :

```env
VITE_SUPABASE_URL=https://votre-projet.supabase.co
VITE_SUPABASE_ANON_KEY=votre-cle-anon-publique
```

4. Relancez l'application web (`npm run dev`).
5. ✅ En haut à droite, le badge passera automatiquement à **🟢 En ligne (Cloud)** !

---

## 5️⃣ Étape 5 : Activer la synchronisation sur l'App Mobile

Sur l'application mobile Flutter :
- Soit vous renseignez l'URL et la clé dans les paramètres de l'application mobile.
- Soit vous pouvez les inscrire dans `mobile/lib/services/supabase_config.dart` dans les variables prévues.

---

## 🛡️ Fonctionnement Offline-First garanti

- **Même sans internet** : l'application web et l'application mobile continuent de fonctionner à 100%.
- Les inscriptions, dépenses et recettes sont enregistrées localement sans aucun blocage.
- **Dès que la connexion internet revient** : toutes les opérations sont automatiquement envoyées au cloud sans doublon.
