-- ==============================================================================
-- AUTO-ÉCOLE SAINT EDMOND — GESTION DU PLANNING & SÉANCES PERSONNALISÉES
-- À exécuter dans le SQL Editor de Supabase (https://supabase.com/dashboard)
-- ==============================================================================

-- 1. CRÉATION DE LA TABLE DES SÉANCES INDIVIDUELLES
CREATE TABLE IF NOT EXISTS public.seances (
    id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    candidat_id TEXT NOT NULL,
    type_seance TEXT NOT NULL DEFAULT 'CONDUITE' CHECK (type_seance IN ('CODE', 'CONDUITE')),
    date_heure TEXT NOT NULL, -- Format ISO : '2026-11-25T14:30:00'
    duree_minutes INTEGER NOT NULL DEFAULT 60 CHECK (duree_minutes > 0),
    moniteur_nom TEXT DEFAULT 'Moniteur Saint Edmond',
    statut TEXT NOT NULL DEFAULT 'PLANIFIE' CHECK (statut IN ('PLANIFIE', 'EFFECTUE', 'ANNULE', 'ABSENT')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. INDEX POUR LES PERFORMANCES (RECHERCHE RAPIDE PAR ÉLÈVE & DATE)
CREATE INDEX IF NOT EXISTS idx_seances_candidat_id ON public.seances(candidat_id);
CREATE INDEX IF NOT EXISTS idx_seances_date_heure ON public.seances(date_heure);

-- 3. SÉCURITÉ : ROW LEVEL SECURITY (RLS)
ALTER TABLE public.seances ENABLE ROW LEVEL SECURITY;

-- Politique d'accès complet pour l'application avec la clé anon
DROP POLICY IF EXISTS "Acces complet seances" ON public.seances;
CREATE POLICY "Acces complet seances" ON public.seances FOR ALL USING (true) WITH CHECK (true);

-- 4. TRIGGER POUR AUTO-UPDATE DU CHAMP 'updated_at'
DROP TRIGGER IF EXISTS set_seances_updated_at ON public.seances;
CREATE TRIGGER set_seances_updated_at
BEFORE UPDATE ON public.seances
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 5. ACTIVATION DU REALTIME (SYNCHRONISATION EN TEMPS RÉEL)
DO $$
BEGIN
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.seances;
    EXCEPTION
        WHEN duplicate_object THEN NULL;
    END;
END $$;
