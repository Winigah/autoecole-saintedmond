-- GestAuto - migration initiale (Supabase / PostgreSQL)
-- Multi-tenant : chaque donnée métier porte un entreprise_id.

-- =====================================================
-- ENUMS
-- =====================================================
create type role_utilisateur  as enum ('SUPER_ADMIN','DG','SECRETAIRE','CANDIDAT');
create type langue            as enum ('EWE','FRANCAIS','ANGLAIS');
create type sexe              as enum ('MASCULIN','FEMININ');
create type categorie_permis  as enum ('A','B','C','D','E');
create type statut_candidat   as enum ('INSCRIT','ADMIS','NON_ADMIS');
create type type_depense      as enum ('NORMALE','FIXE','SPECIALE_DG','SECRETAIRE');
create type type_resultat     as enum ('CODE','CONDUITE');
create type canal_message     as enum ('SMS','WHATSAPP','EMAIL');
create type statut_abonnement as enum ('ACTIF','EXPIRE','EN_ATTENTE');
create type poste_employe     as enum ('DG','SECRETAIRE','MONITEUR','AUTRE');

-- =====================================================
-- TABLES DE BASE
-- =====================================================
create table entreprises (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  proprietaire text not null,
  logo_url text,
  telephone text,
  email text,
  cree_le timestamptz not null default now()
);

create table annexes (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null references entreprises(id) on delete cascade,
  nom text not null,
  quartier text not null
);
create index on annexes(entreprise_id);

-- Profil lié à auth.users (1 ligne par compte)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  entreprise_id uuid references entreprises(id) on delete cascade, -- null pour SUPER_ADMIN
  nom text not null,
  role role_utilisateur not null,
  photo_url text,
  actif boolean not null default true,
  cree_le timestamptz not null default now()
);
create index on profiles(entreprise_id);

-- =====================================================
-- FONCTIONS UTILITAIRES (utilisées par les policies RLS)
-- SECURITY DEFINER pour éviter la récursion sur profiles
-- =====================================================
create or replace function public.current_entreprise_id() returns uuid
language sql stable security definer set search_path = public as $$
  select entreprise_id from profiles where id = auth.uid()
$$;

create or replace function public.current_role_app() returns role_utilisateur
language sql stable security definer set search_path = public as $$
  select role from profiles where id = auth.uid() and actif
$$;

create or replace function public.is_super_admin() returns boolean
language sql stable as $$ select coalesce(public.current_role_app() = 'SUPER_ADMIN', false) $$;

create or replace function public.is_dg() returns boolean
language sql stable as $$ select coalesce(public.current_role_app() = 'DG', false) $$;

create or replace function public.is_staff() returns boolean  -- DG ou secrétaire
language sql stable as $$ select coalesce(public.current_role_app() in ('DG','SECRETAIRE'), false) $$;

-- =====================================================
-- ABONNEMENTS & PUBLICITÉS (gérés par le super admin)
-- =====================================================
create table plans_abonnement (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  duree_mois int not null,
  prix_fcfa int not null,
  actif boolean not null default true
);

create table abonnements (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null references entreprises(id) on delete cascade,
  plan_id uuid not null references plans_abonnement(id),
  debut date not null,
  fin date not null,
  statut statut_abonnement not null default 'EN_ATTENTE',
  reference_paiement text,
  cree_le timestamptz not null default now()
);
create index on abonnements(entreprise_id, statut);

create table publicites (
  id uuid primary key default gen_random_uuid(),
  image_url text not null,
  lien text,
  ordre int not null default 0,
  active boolean not null default true
);

-- Plans de départ (prix modifiables par le super admin)
insert into plans_abonnement (nom, duree_mois, prix_fcfa) values
  ('Mensuel', 1, 15000),
  ('Trimestriel', 3, 40000),
  ('Annuel', 12, 150000);

-- =====================================================
-- CANDIDATS
-- =====================================================
create table candidats (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  annexe_id uuid not null references annexes(id),
  nom text not null,
  prenom text not null,
  contact text not null,
  email text,
  adresse text not null,
  sexe sexe not null,
  langue langue not null,
  categorie categorie_permis not null,
  duree_mois int not null check (duree_mois between 1 and 12),
  montant_total int not null check (montant_total >= 0),
  montant_paye int not null default 0 check (montant_paye >= 0),
  date_inscription date not null,
  statut statut_candidat not null default 'INSCRIT',
  user_id uuid references auth.users(id), -- compte pour les cours en ligne (optionnel)
  cree_par uuid default auth.uid(),
  cree_le timestamptz not null default now()
);
create index on candidats(entreprise_id, annexe_id);
create index on candidats(entreprise_id, date_inscription);

create table paiements_candidats (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  candidat_id uuid not null references candidats(id) on delete cascade,
  montant int not null check (montant > 0),
  date date not null default current_date,
  note text
);
create index on paiements_candidats(candidat_id);

-- "Autres frais candidats" : un frais avec son intitulé
create table autres_frais (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  candidat_id uuid not null references candidats(id) on delete cascade,
  intitule text not null,
  montant int not null check (montant > 0),
  date date not null default current_date
);
create index on autres_frais(candidat_id);

-- =====================================================
-- FINANCES
-- =====================================================
create table depenses (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  annexe_id uuid references annexes(id),
  type type_depense not null,
  intitule text not null,
  montant int not null check (montant > 0),
  date date not null,
  cree_le timestamptz not null default now()
);
create index on depenses(entreprise_id, date);
create index on depenses(entreprise_id, type);

create table recettes (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  annexe_id uuid references annexes(id),
  intitule text not null,
  montant int not null check (montant > 0),
  date date not null,
  paiement_id uuid unique references paiements_candidats(id) on delete cascade,
  autre_frais_id uuid unique references autres_frais(id) on delete cascade,
  cree_le timestamptz not null default now()
);
create index on recettes(entreprise_id, date);

-- =====================================================
-- EMPLOYÉS & PRÉSENCES (séparées)
-- =====================================================
create table employes (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  annexe_id uuid references annexes(id),
  nom text not null,
  prenom text not null,
  poste poste_employe not null,
  contact text not null,
  salaire int,
  actif boolean not null default true
);
create index on employes(entreprise_id);

create table presences_employes (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  employe_id uuid not null references employes(id) on delete cascade,
  date date not null,
  present boolean not null,
  note text,
  unique (employe_id, date)
);

create table presences_candidats (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  candidat_id uuid not null references candidats(id) on delete cascade,
  date date not null,
  present boolean not null,
  note text,
  unique (candidat_id, date)
);

-- =====================================================
-- EXAMENS, RÉSULTATS, PERMIS
-- =====================================================
create table sessions_examen (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  intitule text not null,
  date_examen date not null,
  active boolean not null default true,
  cree_le timestamptz not null default now(),
  mis_a_jour_le timestamptz not null default now()
);
create index on sessions_examen(entreprise_id);

create table resultats (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  candidat_id uuid not null references candidats(id) on delete cascade,
  session_id uuid not null references sessions_examen(id) on delete cascade,
  type type_resultat not null,
  admis boolean not null,
  note text,
  unique (candidat_id, session_id, type)
);

create table permis_retires (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  candidat_id uuid not null unique references candidats(id) on delete cascade,
  date_retrait date not null,
  numero_permis text,
  observation text
);

-- =====================================================
-- MESSAGES
-- =====================================================
create table messages (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid not null default public.current_entreprise_id() references entreprises(id) on delete cascade,
  candidat_id uuid references candidats(id) on delete set null,
  canal canal_message not null,
  contenu text not null,
  statut text not null default 'ENVOYE',
  envoye_le timestamptz not null default now()
);
create index on messages(entreprise_id);

-- =====================================================
-- COURS EN LIGNE (contenu global, géré par le super admin)
-- =====================================================
create table cours (
  id uuid primary key default gen_random_uuid(),
  titre text not null,
  description text,
  ordre int not null default 0,
  publie boolean not null default true
);

create table lecons (
  id uuid primary key default gen_random_uuid(),
  cours_id uuid not null references cours(id) on delete cascade,
  titre text not null,
  type_media text not null check (type_media in ('VIDEO','PDF','QUIZ')),
  url text,
  contenu text,
  ordre int not null default 0
);

-- =====================================================
-- TRIGGERS MÉTIER
-- =====================================================

-- Paiement => recette automatique + cumul du montant payé
create or replace function trg_paiement_apres_insert() returns trigger
language plpgsql security definer set search_path = public as $$
declare c candidats%rowtype;
begin
  select * into c from candidats where id = new.candidat_id;
  update candidats set montant_paye = montant_paye + new.montant where id = c.id;
  insert into recettes (entreprise_id, annexe_id, intitule, montant, date, paiement_id)
  values (new.entreprise_id, c.annexe_id, 'Paiement - ' || c.nom || ' ' || c.prenom, new.montant, new.date, new.id);
  return new;
end $$;
create trigger paiement_apres_insert after insert on paiements_candidats
  for each row execute function trg_paiement_apres_insert();

-- Autre frais => recette automatique
create or replace function trg_autre_frais_apres_insert() returns trigger
language plpgsql security definer set search_path = public as $$
declare c candidats%rowtype;
begin
  select * into c from candidats where id = new.candidat_id;
  insert into recettes (entreprise_id, annexe_id, intitule, montant, date, autre_frais_id)
  values (new.entreprise_id, c.annexe_id, new.intitule || ' - ' || c.nom || ' ' || c.prenom, new.montant, new.date, new.id);
  return new;
end $$;
create trigger autre_frais_apres_insert after insert on autres_frais
  for each row execute function trg_autre_frais_apres_insert();

-- Inscription avec "Montant payé" > 0 => converti en premier paiement
-- (le formulaire envoie montant_paye ; on le remet à 0 puis le paiement le recrédite et crée la recette)
create or replace function trg_candidat_apres_insert() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.montant_paye > 0 then
    update candidats set montant_paye = 0 where id = new.id;
    insert into paiements_candidats (entreprise_id, candidat_id, montant, date, note)
    values (new.entreprise_id, new.id, new.montant_paye, new.date_inscription, 'Paiement à l''inscription');
  end if;
  return new;
end $$;
create trigger candidat_apres_insert after insert on candidats
  for each row execute function trg_candidat_apres_insert();

-- Date de mise à jour des sessions d'examen
create or replace function trg_touch_session() returns trigger language plpgsql as $$
begin new.mis_a_jour_le = now(); return new; end $$;
create trigger touch_session before update on sessions_examen
  for each row execute function trg_touch_session();

-- =====================================================
-- VUES (security_invoker => la RLS s'applique à l'appelant)
-- =====================================================
create view bilan_mensuel with (security_invoker = true) as
with r as (
  select entreprise_id, date_trunc('month', date)::date as mois, sum(montant) as revenus
  from recettes group by 1,2
), d as (
  select entreprise_id, date_trunc('month', date)::date as mois, sum(montant) as depenses
  from depenses group by 1,2
)
select coalesce(r.entreprise_id, d.entreprise_id) as entreprise_id,
       coalesce(r.mois, d.mois) as mois,
       coalesce(r.revenus, 0)  as revenus,
       coalesce(d.depenses, 0) as depenses,
       coalesce(r.revenus, 0) - coalesce(d.depenses, 0) as solde
from r full join d on r.entreprise_id = d.entreprise_id and r.mois = d.mois;

create view inscriptions_mensuelles with (security_invoker = true) as
select entreprise_id, date_trunc('month', date_inscription)::date as mois, count(*) as inscrits
from candidats group by 1,2;

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================
alter table entreprises         enable row level security;
alter table annexes             enable row level security;
alter table profiles            enable row level security;
alter table plans_abonnement    enable row level security;
alter table abonnements         enable row level security;
alter table publicites          enable row level security;
alter table candidats           enable row level security;
alter table paiements_candidats enable row level security;
alter table autres_frais        enable row level security;
alter table depenses            enable row level security;
alter table recettes            enable row level security;
alter table employes            enable row level security;
alter table presences_employes  enable row level security;
alter table presences_candidats enable row level security;
alter table sessions_examen     enable row level security;
alter table resultats           enable row level security;
alter table permis_retires      enable row level security;
alter table messages            enable row level security;
alter table cours               enable row level security;
alter table lecons              enable row level security;

-- Super admin : accès total partout
do $$
declare t text;
begin
  foreach t in array array[
    'entreprises','annexes','profiles','plans_abonnement','abonnements','publicites',
    'candidats','paiements_candidats','autres_frais','depenses','recettes','employes',
    'presences_employes','presences_candidats','sessions_examen','resultats',
    'permis_retires','messages','cours','lecons'
  ] loop
    execute format('create policy "super_admin_all" on %I for all using (public.is_super_admin()) with check (public.is_super_admin())', t);
  end loop;
end $$;

-- DG : accès total aux données de son entreprise
do $$
declare t text;
begin
  foreach t in array array[
    'annexes','candidats','paiements_candidats','autres_frais','depenses','recettes',
    'employes','presences_employes','presences_candidats','sessions_examen','resultats',
    'permis_retires','messages'
  ] loop
    execute format(
      'create policy "dg_all" on %I for all
         using (public.is_dg() and entreprise_id = public.current_entreprise_id())
         with check (public.is_dg() and entreprise_id = public.current_entreprise_id())', t);
  end loop;
end $$;

-- SECRÉTAIRE : uniquement enregistrer les inscriptions
-- (insert candidats + paiements + autres frais ; lecture des candidats/annexes pour l'interface)
create policy "secretaire_select_candidats" on candidats for select
  using (public.current_role_app() = 'SECRETAIRE' and entreprise_id = public.current_entreprise_id());
create policy "secretaire_insert_candidats" on candidats for insert
  with check (public.current_role_app() = 'SECRETAIRE' and entreprise_id = public.current_entreprise_id());
create policy "secretaire_insert_paiements" on paiements_candidats for insert
  with check (public.current_role_app() = 'SECRETAIRE' and entreprise_id = public.current_entreprise_id());
create policy "secretaire_insert_autres_frais" on autres_frais for insert
  with check (public.current_role_app() = 'SECRETAIRE' and entreprise_id = public.current_entreprise_id());
create policy "secretaire_select_annexes" on annexes for select
  using (public.current_role_app() = 'SECRETAIRE' and entreprise_id = public.current_entreprise_id());

-- Entreprise : DG et secrétaire lisent la leur ; le DG peut la modifier
create policy "staff_select_entreprise" on entreprises for select
  using (public.is_staff() and id = public.current_entreprise_id());
create policy "dg_update_entreprise" on entreprises for update
  using (public.is_dg() and id = public.current_entreprise_id())
  with check (public.is_dg() and id = public.current_entreprise_id());

-- Profils : chacun lit/modifie le sien ; le DG lit ceux de son entreprise
create policy "self_select_profile" on profiles for select using (id = auth.uid());
create policy "self_update_profile" on profiles for update
  using (id = auth.uid()) with check (id = auth.uid() and role = public.current_role_app());
create policy "dg_select_profiles" on profiles for select
  using (public.is_dg() and entreprise_id = public.current_entreprise_id());

-- Abonnements : le DG lit les siens (la création passe par une Edge Function après paiement)
create policy "dg_select_abonnements" on abonnements for select
  using (public.is_dg() and entreprise_id = public.current_entreprise_id());

-- Contenu global en lecture pour tout utilisateur connecté
create policy "auth_select_plans" on plans_abonnement for select to authenticated using (actif);
create policy "auth_select_pubs"  on publicites       for select to authenticated using (active);
create policy "auth_select_cours" on cours            for select to authenticated using (publie);
create policy "auth_select_lecons" on lecons          for select to authenticated using (true);

-- CANDIDAT (compte cours en ligne) : voit seulement sa fiche
create policy "candidat_self" on candidats for select
  using (public.current_role_app() = 'CANDIDAT' and user_id = auth.uid());
