-- =====================================================
-- AutoÉcole Pro - Migration 0002 : Durcissement & Sécurité Avancée
-- =====================================================

-- 1. Table d'audit pour la traçabilité des opérations sensibles (Anti-fraude)
create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  entreprise_id uuid references entreprises(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null,
  table_cible text not null,
  action text not null check (action in ('INSERT', 'UPDATE', 'DELETE', 'AUTH', 'EXPORT')),
  donnees_anciennes jsonb,
  donnees_nouvelles jsonb,
  adresse_ip text,
  cree_le timestamptz not null default now()
);

create index if not exists idx_audit_entreprise on audit_logs(entreprise_id, cree_le desc);
alter table audit_logs enable row level security;

-- Seul le DG et le Super Admin peuvent consulter les logs d'audit de leur entreprise
create policy "dg_select_audit_logs" on audit_logs for select
  using (public.is_dg() and entreprise_id = public.current_entreprise_id());

create policy "super_admin_select_audit_logs" on audit_logs for select
  using (public.is_super_admin());

-- 2. Fonction de journalisation automatique sur les tables financières
create or replace function public.trg_audit_logger() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  eid uuid;
begin
  if tg_op = 'DELETE' then
    eid := old.entreprise_id;
    insert into audit_logs (entreprise_id, user_id, table_cible, action, donnees_anciennes)
    values (eid, auth.uid(), tg_table_name, tg_op, to_jsonb(old));
    return old;
  elsif tg_op = 'UPDATE' then
    eid := new.entreprise_id;
    insert into audit_logs (entreprise_id, user_id, table_cible, action, donnees_anciennes, donnees_nouvelles)
    values (eid, auth.uid(), tg_table_name, tg_op, to_jsonb(old), to_jsonb(new));
    return new;
  elsif tg_op = 'INSERT' then
    eid := new.entreprise_id;
    insert into audit_logs (entreprise_id, user_id, table_cible, action, donnees_nouvelles)
    values (eid, auth.uid(), tg_table_name, tg_op, to_jsonb(new));
    return new;
  end if;
  return null;
end $$;

-- Triggers d'audit sur les paiements et dépenses
drop trigger if exists audit_paiements on paiements_candidats;
create trigger audit_paiements
  after insert or update or delete on paiements_candidats
  for each row execute function public.trg_audit_logger();

drop trigger if exists audit_depenses on depenses;
create trigger audit_depenses
  after insert or update or delete on depenses
  for each row execute function public.trg_audit_logger();

drop trigger if exists audit_candidats on candidats;
create trigger audit_candidats
  after update or delete on candidats
  for each row execute function public.trg_audit_logger();

-- 3. Procédure stockée atomique pour l'inscription d'un candidat sécurisée
create or replace function public.inscrire_candidat(
  p_annexe_id uuid,
  p_nom text,
  p_prenom text,
  p_contact text,
  p_email text,
  p_adresse text,
  p_sexe sexe,
  p_langue langue,
  p_categorie categorie_permis,
  p_duree_mois int,
  p_montant_total int,
  p_montant_paye int,
  p_date_inscription date
) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_ent_id uuid;
  v_cand_id uuid;
begin
  -- Vérification des privilèges
  if not (public.is_staff() or public.is_super_admin()) then
    raise exception 'Accès non autorisé pour inscrire un candidat.';
  end if;

  v_ent_id := public.current_entreprise_id();
  if v_ent_id is null and not public.is_super_admin() then
    raise exception 'Entreprise introuvable pour cet utilisateur.';
  end if;

  -- Validation stricte des données
  if trim(p_nom) = '' or trim(p_prenom) = '' or trim(p_contact) = '' then
    raise exception 'Le nom, prénom et contact téléphonique sont obligatoires.';
  end if;

  if p_montant_total < 0 or p_montant_paye < 0 or p_montant_paye > p_montant_total then
    raise exception 'Montant total ou payé invalide (le montant payé ne peut dépasser le montant total).';
  end if;

  -- Insertion du candidat
  insert into candidats (
    entreprise_id, annexe_id, nom, prenom, contact, email, adresse,
    sexe, langue, categorie, duree_mois, montant_total, montant_paye,
    date_inscription, statut
  ) values (
    v_ent_id, p_annexe_id, trim(upper(p_nom)), trim(initcap(p_prenom)),
    trim(p_contact), nullif(trim(p_email), ''), trim(p_adresse),
    p_sexe, p_langue, p_categorie, p_duree_mois, p_montant_total,
    0,
    p_date_inscription, 'INSCRIT'
  ) returning id into v_cand_id;

  -- Si un premier paiement est effectué
  if p_montant_paye > 0 then
    insert into paiements_candidats (
      entreprise_id, candidat_id, montant, date, note
    ) values (
      v_ent_id, v_cand_id, p_montant_paye, p_date_inscription, 'Premier versement à l''inscription'
    );
  end if;

  return v_cand_id;
end $$;
