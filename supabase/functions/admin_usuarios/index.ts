import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    const body = await req.json();
    const { action, payload } = body;

    if (action === 'create_user') {
      const { email, password, nombre, dni, rol, sede, foto_perfil, fecha_nacimiento } = payload;
      
      const { data: authData, error: authError } = await supabaseClient.auth.admin.createUser({
        email: email,
        password: password,
        email_confirm: true,
      });

      if (authError) throw authError;

      const uid = authData.user.id;

      const { error: dbError } = await supabaseClient.from('usuarios').insert([{
        id: uid,
        nombre_real: nombre,
        dni: dni,
        correo: email,
        rol: rol,
        bahia: sede,
        foto_perfil: foto_perfil || null,
        fecha_nacimiento: fecha_nacimiento || null
      }]);

      if (dbError) {
        // Rollback
        await supabaseClient.auth.admin.deleteUser(uid);
        throw dbError;
      }

      return new Response(JSON.stringify({ success: true, uid }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    if (action === 'update_user') {
      const { uid, email, password, nombre, dni, rol, sede, foto_perfil, fecha_nacimiento } = payload;
      
      const updateAuth: any = {};
      if (email) updateAuth.email = email;
      if (password) updateAuth.password = password;

      if (Object.keys(updateAuth).length > 0) {
        const { error: authError } = await supabaseClient.auth.admin.updateUserById(uid, updateAuth);
        if (authError) throw authError;
      }

      const dbPayload: any = {
        nombre_real: nombre,
        dni: dni,
        correo: email,
        rol: rol,
        bahia: sede,
      };
      
      if (foto_perfil !== undefined) dbPayload.foto_perfil = foto_perfil;
      if (fecha_nacimiento !== undefined) dbPayload.fecha_nacimiento = fecha_nacimiento;

      const { error: dbError } = await supabaseClient.from('usuarios').update(dbPayload).eq('id', uid);

      if (dbError) throw dbError;

      return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    if (action === 'enable_user' || action === 'disable_user') {
      return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    return new Response(JSON.stringify({ error: 'Action not valid' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});
