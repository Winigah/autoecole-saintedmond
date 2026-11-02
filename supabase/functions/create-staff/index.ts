import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    // 1. Authentification de l'appelant (doit être DG ou SUPER_ADMIN)
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Non autorisé: En-tête manquant" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Utilisateur invalide" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Vérification du profil
    const { data: callerProfile, error: profileErr } = await supabaseAdmin
      .from("profiles")
      .select("role, entreprise_id")
      .eq("id", user.id)
      .single();

    if (profileErr || !callerProfile || (callerProfile.role !== "DG" && callerProfile.role !== "SUPER_ADMIN")) {
      return new Response(JSON.stringify({ error: "Action réservée à la Direction Générale" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const { email, password, nom, role, annexe_id } = body;

    if (!email || !password || !nom || !role) {
      return new Response(JSON.stringify({ error: "Champs requis manquants" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Un DG ne peut créer que des SECRETAIRE ou CANDIDAT pour son entreprise
    if (callerProfile.role === "DG" && role !== "SECRETAIRE" && role !== "CANDIDAT") {
      return new Response(JSON.stringify({ error: "Rôle non autorisé pour la création de personnel" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const targetEntrepriseId = callerProfile.role === "SUPER_ADMIN" ? body.entreprise_id : callerProfile.entreprise_id;

    // 2. Création du compte dans auth.users
    const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { nom, role },
    });

    if (createError) {
      return new Response(JSON.stringify({ error: createError.message }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. Création du profil public
    const { error: insertProfileErr } = await supabaseAdmin.from("profiles").insert({
      id: newUser.user.id,
      entreprise_id: targetEntrepriseId,
      nom,
      role,
      actif: true,
    });

    if (insertProfileErr) {
      // Rollback auth user
      await supabaseAdmin.auth.admin.deleteUser(newUser.user.id);
      return new Response(JSON.stringify({ error: "Erreur création profil: " + insertProfileErr.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ success: true, userId: newUser.user.id }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
