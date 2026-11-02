-- ==============================================================================
-- BASE DE DONNÉES CLOUD SUPABASE — AUTO-ÉCOLE SAINT EDMOND (LOMÉ, TOGO)
-- Siège unique : Tokoin Ramco (Von Boutique LG face Ambassade de Belgique)
-- Schéma SQL avec sécurité RLS, triggers d'horodatage et synchronisation Realtime
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABLE DES ANNEXES
CREATE TABLE IF NOT EXISTS public.annexes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Insertion du Siège officiel par défaut
INSERT INTO public.annexes (nom)
VALUES ('Tokoin Ramco (Siège)')
ON CONFLICT (nom) DO NOTHING;

-- 3. TABLE DES CANDIDATS
CREATE TABLE IF NOT EXISTS public.candidats (
    id TEXT PRIMARY KEY,
    nom TEXT NOT NULL,
    prenom TEXT NOT NULL,
    contact TEXT NOT NULL,
    email TEXT,
    adresse TEXT,
    annexe TEXT NOT NULL DEFAULT 'Tokoin Ramco (Siège)',
    categorie TEXT NOT NULL DEFAULT 'B',
    langue TEXT NOT NULL DEFAULT 'FRANCAIS',
    sexe TEXT NOT NULL DEFAULT 'MASCULIN',
    montant_total INTEGER NOT NULL DEFAULT 0,
    montant_paye INTEGER NOT NULL DEFAULT 0,
    date_inscription TEXT NOT NULL,
    duree_formation_mois INTEGER DEFAULT 3,
    statut TEXT NOT NULL DEFAULT 'INSCRIT',
    code_acces TEXT,
    photo_url TEXT,
    type_formation TEXT DEFAULT 'COMPLETE',
    nb_conduites_prevues INTEGER DEFAULT 12,
    nb_conduites_effectuees INTEGER DEFAULT 0,
    date_examen_code TEXT,
    statut_examen_code TEXT DEFAULT 'NON_PROGRAMME',
    date_examen_conduite TEXT,
    statut_examen_conduite TEXT DEFAULT 'NON_PROGRAMME',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. TABLE DES DÉPENSES
CREATE TABLE IF NOT EXISTS public.depenses (
    id TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'NORMALE', -- 'NORMALE', 'FIXE', 'SPECIALE_DG', 'SECRETAIRE'
    intitule TEXT NOT NULL,
    annexe TEXT NOT NULL DEFAULT 'Tokoin Ramco (Siège)',
    montant INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. TABLE DES RECETTES
CREATE TABLE IF NOT EXISTS public.recettes (
    id TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    intitule TEXT NOT NULL,
    annexe TEXT NOT NULL DEFAULT 'Tokoin Ramco (Siège)',
    montant INTEGER NOT NULL DEFAULT 0,
    candidat_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. TABLE DES PRÉSENCES
CREATE TABLE IF NOT EXISTS public.presences (
    id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    date TEXT NOT NULL,
    candidat_id TEXT,
    staff_name TEXT,
    type TEXT NOT NULL, -- 'CANDIDAT' ou 'STAFF'
    present BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. FONCTION & TRIGGER POUR AUTO-UPDATE DU CHAMP 'updated_at'
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_candidats_updated_at ON public.candidats;
CREATE TRIGGER set_candidats_updated_at
BEFORE UPDATE ON public.candidats
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_depenses_updated_at ON public.depenses;
CREATE TRIGGER set_depenses_updated_at
BEFORE UPDATE ON public.depenses
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_recettes_updated_at ON public.recettes;
CREATE TRIGGER set_recettes_updated_at
BEFORE UPDATE ON public.recettes
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 8. SÉCURITÉ : ROW LEVEL SECURITY (RLS)
-- Active la sécurité sur chaque table
ALTER TABLE public.annexes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.depenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recettes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.presences ENABLE ROW LEVEL SECURITY;

-- Politiques ouvertes pour l'application avec la clé publique (anon)
CREATE POLICY "Acces complet annexes" ON public.annexes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acces complet candidats" ON public.candidats FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acces complet depenses" ON public.depenses FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acces complet recettes" ON public.recettes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acces complet presences" ON public.presences FOR ALL USING (true) WITH CHECK (true);

-- 9. ACTIVATION DU REALTIME (SYNCHRONISATION EN TEMPS RÉEL)
-- Permet à l'application web et mobile d'être informées instantanément de chaque changement
DO $$
BEGIN
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.annexes, public.candidats, public.depenses, public.recettes, public.presences;
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END;
END $$;
