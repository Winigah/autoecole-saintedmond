-- =====================================================
-- AutoÉcole Pro - Migration 0004 : Portail Candidat
-- Authentification par Code Unique (8 caractères) & Suivi
-- =====================================================

-- 1. Ajout des colonnes de suivi sur la table candidats
alter table candidats 
  add column if not null code_acces varchar(10) unique,
  add column if not null type_formation varchar(50) default 'Formation Normale',
  add column if not null nb_conduites_prevues int default 20 check (nb_conduites_prevues >= 0),
  add column if not null nb_conduites_effectuees int default 0 check (nb_conduites_effectuees >= 0),
  add column date_examen_code timestamptz,
  add column if not null statut_examen_code varchar(30) default 'NON_PROGRAMME' check (statut_examen_code in ('NON_PROGRAMME', 'PROGRAMME', 'ADMIS', 'AJOURNE')),
  add column date_examen_conduite timestamptz,
  add column if not null statut_examen_conduite varchar(30) default 'NON_PROGRAMME' check (statut_examen_conduite in ('NON_PROGRAMME', 'PROGRAMME', 'ADMIS', 'AJOURNE')),
  add column photo_url text;

create index if not exists idx_candidats_code_acces on candidats(code_acces);

-- 2. Table des Séances Pédagogiques (Code & Conduite)
create table if not exists seances_candidat (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null references entreprises(id) on delete cascade,
  candidat_id uuid not null references candidats(id) on delete cascade,
  type_seance varchar(20) not null check (type_seance in ('CODE', 'CONDUITE')),
  date_heure timestamptz not null,
  duree_minutes int not null default 60 check (duree_minutes > 0),
  moniteur_nom varchar(100),
  statut varchar(20) not null default 'PLANIFIE' check (statut in ('PLANIFIE', 'EFFECTUE', 'ANNULE', 'ABSENT')),
  notes text,
  cree_le timestamptz not null default now()
);

create index if not exists idx_seances_candidat on seances_candidat(candidat_id, date_heure);
create index if not exists idx_seances_entreprise on seances_candidat(entreprise_id);

-- RLS pour les séances
alter table seances_candidat enable row level security;

create policy "seances_tenant_isolation" on seances_candidat
  for all using (entreprise_id = public.current_entreprise_id());

-- 3. Fonction génératrice de code alphanumérique unique lisible (8 caractères: 4-4)
-- Alphabet sans caractères ambigus (pas de 0, O, 1, I, etc.)
create or replace function public.generer_code_acces_candidat()
returns text
language plpgsql
as $$
declare
  v_chars text := '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  v_code text;
  v_exists boolean;
  v_part1 text;
  v_part2 text;
  i int;
begin
  loop
    v_part1 := '';
    v_part2 := '';
    for i in 1..4 loop
      v_part1 := v_part1 || substr(v_chars, floor(random() * length(v_chars) + 1)::int, 1);
      v_part2 := v_part2 || substr(v_chars, floor(random() * length(v_chars) + 1)::int, 1);
    end loop;
    v_code := v_part1 || '-' || v_part2;

    select exists(select 1 from candidats where code_acces = v_code) into v_exists;
    if not v_exists then
      return v_code;
    end if;
  end loop;
end;
$$;

-- 4. Trigger d'attribution automatique du code à l'inscription
create or replace function public.trg_auto_generer_code_candidat()
returns trigger
language plpgsql
as $$
begin
  if new.code_acces is null or trim(new.code_acces) = '' then
    new.code_acces := public.generer_code_acces_candidat();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_candidats_set_code on candidats;
create trigger trg_candidats_set_code
  before insert on candidats
  for each row execute function public.trg_auto_generer_code_candidat();

-- Remplir les codes pour les candidats existants qui n'en ont pas
do $$
declare
  r record;
begin
  for r in select id from candidats where code_acces is null loop
    update candidats set code_acces = public.generer_code_acces_candidat() where id = r.id;
  end loop;
end;
$$;

-- 5. Procédure RPC Sécurisée d'Authentification Candidat (Lecture Seule)
-- Accessible sans compte auth Supabase classique, protégée contre les fuites
create or replace function public.authentifier_candidat_par_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_candidat record;
  v_entreprise record;
  v_seances jsonb;
  v_paiements jsonb;
  v_clean_code text;
begin
  v_clean_code := upper(trim(replace(p_code, ' ', '')));
  
  -- Si le candidat a saisi 8 caractères sans tiret, on insère le tiret au milieu
  if length(v_clean_code) = 8 and position('-' in v_clean_code) = 0 then
    v_clean_code := substr(v_clean_code, 1, 4) || '-' || substr(v_clean_code, 5, 4);
  end if;

  select * into v_candidat
  from candidats
  where code_acces = v_clean_code;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Code d''accès invalide. Vérifiez le code fourni par votre auto-école.'
    );
  end if;

  -- Informations publiques de l'auto-école
  select id, nom, slug, telephone, email, logo_url into v_entreprise
  from entreprises
  where id = v_candidat.entreprise_id;

  -- Séances du candidat
  select coalesce(jsonb_agg(s order by s.date_heure asc), '[]'::jsonb) into v_seances
  from (
    select id, type_seance, date_heure, duree_minutes, moniteur_nom, statut, notes
    from seances_candidat
    where candidat_id = v_candidat.id
  ) s;

  -- Versements du candidat
  select coalesce(jsonb_agg(p order by p.date_paiement desc), '[]'::jsonb) into v_paiements
  from (
    select id, montant, date_paiement, moyen_paiement, recu_numero
    from paiements_candidats
    where candidat_id = v_candidat.id
  ) p;

  return jsonb_build_object(
    'success', true,
    'entreprise', jsonb_build_object(
      'nom', v_entreprise.nom,
      'telephone', v_entreprise.telephone,
      'email', v_entreprise.email,
      'logo_url', v_entreprise.logo_url
    ),
    'candidat', jsonb_build_object(
      'id', v_candidat.id,
      'code_acces', v_candidat.code_acces,
      'nom', v_candidat.nom,
      'prenom', v_candidat.prenom,
      'contact', v_candidat.contact,
      'categorie_permis', v_candidat.categorie,
      'langue', v_candidat.langue,
      'type_formation', v_candidat.type_formation,
      'statut', v_candidat.statut,
      'date_inscription', v_candidat.date_inscription,
      'photo_url', v_candidat.photo_url,
      'nb_conduites_prevues', v_candidat.nb_conduites_prevues,
      'nb_conduites_effectuees', v_candidat.nb_conduites_effectuees,
      'nb_conduites_restantes', greatest(0, v_candidat.nb_conduites_prevues - v_candidat.nb_conduites_effectuees),
      'date_examen_code', v_candidat.date_examen_code,
      'statut_examen_code', v_candidat.statut_examen_code,
      'date_examen_conduite', v_candidat.date_examen_conduite,
      'statut_examen_conduite', v_candidat.statut_examen_conduite,
      'montant_total', v_candidat.montant_total,
      'montant_paye', v_candidat.montant_paye,
      'montant_restant', greatest(0, v_candidat.montant_total - v_candidat.montant_paye),
      'est_solde', (v_candidat.montant_paye >= v_candidat.montant_total)
    ),
    'seances', v_seances,
    'paiements', v_paiements
  );
end;
$$;
