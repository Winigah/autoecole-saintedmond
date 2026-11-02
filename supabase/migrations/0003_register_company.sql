-- =====================================================
-- AutoÉcole Pro - Migration 0003 : Inscription Nouvelle Entreprise (Onboarding)
-- =====================================================

-- Procédure stockée permettant l'inscription atomique d'une auto-école
-- et l'attribution automatique du rôle DG au créateur
create or replace function public.inscrire_nouvelle_entreprise(
  p_nom_entreprise text,
  p_proprietaire text,
  p_telephone text,
  p_email text,
  p_quartier_siege text,
  p_plan_id uuid default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user_id uuid;
  v_ent_id uuid;
  v_annexe_id uuid;
  v_default_plan uuid;
begin
  -- Récupération de l'utilisateur connecté via Supabase Auth
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Utilisateur non authentifié.';
  end if;

  -- Validation des champs obligatoires
  if trim(p_nom_entreprise) = '' or trim(p_proprietaire) = '' or trim(p_telephone) = '' then
    raise exception 'Le nom de l''entreprise, le propriétaire et le téléphone sont requis.';
  end if;

  -- 1. Création de l'entreprise
  insert into entreprises (nom, proprietaire, telephone, email)
  values (trim(p_nom_entreprise), trim(p_proprietaire), trim(p_telephone), nullif(trim(p_email), ''))
  returning id into v_ent_id;

  -- 2. Création de l'annexe principale / Siège
  insert into annexes (entreprise_id, nom, quartier)
  values (v_ent_id, 'Siège Principal', coalesce(nullif(trim(p_quartier_siege), ''), 'Centre-Ville'))
  returning id into v_annexe_id;

  -- 3. Mise à jour ou insertion du profil DG
  insert into profiles (id, entreprise_id, nom, role, actif)
  values (v_user_id, v_ent_id, trim(p_proprietaire), 'DG', true)
  on conflict (id) do update set
    entreprise_id = v_ent_id,
    nom = trim(p_proprietaire),
    role = 'DG',
    actif = true;

  -- 4. Initialisation d'une période d'essai gratuite de 14 jours
  if p_plan_id is null then
    select id into v_default_plan from plans_abonnement where actif limit 1;
  else
    v_default_plan := p_plan_id;
  end if;

  if v_default_plan is not null then
    insert into abonnements (entreprise_id, plan_id, debut, fin, statut, reference_paiement)
    values (v_ent_id, v_default_plan, current_date, current_date + interval '14 days', 'ACTIF', 'ESSAI_GRATUIT_14J');
  end if;

  -- 5. Journalisation d'audit
  insert into audit_logs (entreprise_id, user_id, table_cible, action, donnees_nouvelles)
  values (v_ent_id, v_user_id, 'entreprises', 'INSERT', jsonb_build_object(
    'nom', p_nom_entreprise,
    'proprietaire', p_proprietaire,
    'annexe_siege', v_annexe_id
  ));

  return jsonb_build_object(
    'success', true,
    'entreprise_id', v_ent_id,
    'annexe_id', v_annexe_id
  );
end $$;
