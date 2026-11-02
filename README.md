# AutoÉcole Pro

## Contenu actuel
- prototype/index.html : maquette cliquable (fausses données). Ouvrir dans un navigateur ou héberger sur Netlify/Vercel pour la montrer. NE PAS utiliser avec de vraies données.
- supabase/migrations/0001_init.sql : base de données complète (tables, sécurité par rôle RLS, triggers, vues de bilan).

## Mise en place de la base (Supabase)
1. Créer un projet sur https://supabase.com
2. SQL Editor > coller et exécuter 0001_init.sql
3. Authentication > créer votre utilisateur, puis dans SQL Editor :
   insert into profiles (id, nom, role) values ('<UUID_DE_VOTRE_USER>', 'Votre nom', 'SUPER_ADMIN');
4. Storage > créer les buckets : photos, logos, pubs, cours
5. Ajuster les prix dans la table plans_abonnement

## Reste à développer
1. Application Flutter (auth, menu, candidats, finances, tableau de bord)
2. Application web (Next.js + supabase-js)
3. Edge Functions : création de comptes secrétaire, SMS/WhatsApp/email, paiement d'abonnement
4. Export PDF
5. Tests de sécurité RLS avant mise en production
