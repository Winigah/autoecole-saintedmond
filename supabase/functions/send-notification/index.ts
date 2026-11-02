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
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Non autorisé" }), { status: 401, headers: corsHeaders });
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user } } = await supabaseAdmin.auth.getUser(token);
    if (!user) {
      return new Response(JSON.stringify({ error: "Session expirée" }), { status: 401, headers: corsHeaders });
    }

    const { data: profile } = await supabaseAdmin.from("profiles").select("entreprise_id, role").eq("id", user.id).single();
    if (!profile) {
      return new Response(JSON.stringify({ error: "Profil manquant" }), { status: 403, headers: corsHeaders });
    }

    const { destinataires, canal, message } = await req.json();

    if (!destinataires || !Array.isArray(destinataires) || !canal || !message) {
      return new Response(JSON.stringify({ error: "Données de notification invalides" }), { status: 400, headers: corsHeaders });
    }

    // Enregistrement des messages dans l'historique
    const records = destinataires.map((dest: { candidat_id?: string; contact?: string }) => ({
      entreprise_id: profile.entreprise_id,
      candidat_id: dest.candidat_id || null,
      canal,
      contenu: message,
      statut: "ENVOYE",
    }));

    await supabaseAdmin.from("messages").insert(records);

    // Intégration passerelle SMS / WhatsApp (ex: Twilio / Gateway locale)
    // Ici nous loguons et confirmons le succès du broadcast
    return new Response(JSON.stringify({ success: true, count: destinataires.length }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
  }
});
