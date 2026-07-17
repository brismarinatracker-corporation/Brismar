/// <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

/** Respuesta de error JSON con código HTTP */
const errorResponse = (message: string, status: number) =>
  new Response(JSON.stringify({ error: message }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status,
  });

/** Respuesta de éxito JSON */
const successResponse = (data: object) =>
  new Response(JSON.stringify(data), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 200,
  });

/**
 * Verifica que el JWT del caller pertenezca a un usuario con rol 'administrador'.
 * Usa un cliente con ANON_KEY para respetar RLS y leer solo la tabla 'usuarios'.
 * @throws Error si el JWT es inválido, no pertenece a un admin, o el usuario está inactivo.
 */
async function verificarRolAdministrador(req: Request): Promise<void> {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) throw new Error('Token de autorización requerido.');

  // Cliente con anon key para verificar identidad del caller bajo RLS
  const clienteVerificacion = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    {
      auth: { autoRefreshToken: false, persistSession: false },
      global: { headers: { Authorization: authHeader } },
    }
  );

  const { data: { user }, error } = await clienteVerificacion.auth.getUser();
  if (error || !user) throw new Error('JWT inválido o sesión expirada.');

  const { data: perfil, error: perfilError } = await clienteVerificacion
    .from('usuarios')
    .select('rol, activo')
    .eq('id', user.id)
    .single();

  if (perfilError || !perfil) throw new Error('No se encontró el perfil del usuario.');
  if (!perfil.activo) throw new Error('La cuenta está desactivada.');
  if (perfil.rol !== 'administrador') throw new Error('Acceso denegado: se requiere rol administrador.');
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // ─── GUARDIA DE SEGURIDAD: Solo administradores pueden pasar ───────────
    await verificarRolAdministrador(req);

    // Cliente con SERVICE_ROLE para operaciones privilegiadas
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    const body = await req.json();
    const { action, payload } = body;

    if (action === 'create_user') {
      return await _crearUsuario(supabaseAdmin, payload);
    }

    if (action === 'update_user') {
      return await _actualizarUsuario(supabaseAdmin, payload);
    }

    if (action === 'enable_user' || action === 'disable_user') {
      return await _alternarEstado(supabaseAdmin, payload, action === 'enable_user');
    }

    if (action === 'delete_user') {
      return await _eliminarUsuario(supabaseAdmin, payload);
    }

    return errorResponse('Acción no válida.', 400);

  } catch (error: any) {
    const status = error.message.includes('denegado') || error.message.includes('requerido')
      ? 403
      : 400;
    return errorResponse(error.message, status);
  }
});

/** Crea un usuario en Auth y en la tabla usuarios con rollback en caso de fallo. */
async function _crearUsuario(client: any, payload: any): Promise<Response> {
  const { email, password, nombre, dni, rol, sede, foto_perfil, fecha_nacimiento } = payload;

  const { data: authData, error: authError } = await client.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
  });

  if (authError) throw authError;

  const uid = authData.user.id;
  const { error: dbError } = await client.from('usuarios').insert([{
    id: uid,
    nombre_real: nombre,
    dni,
    correo: email,
    rol,
    bahia: sede,
    foto_perfil: foto_perfil || null,
    fecha_nacimiento: fecha_nacimiento || null,
    activo: true,
  }]);

  if (dbError) {
    await client.auth.admin.deleteUser(uid); // Rollback
    throw dbError;
  }

  return successResponse({ success: true, uid });
}

/** Actualiza datos de Auth y/o perfil de la tabla usuarios. */
async function _actualizarUsuario(client: any, payload: any): Promise<Response> {
  const { uid, email, password, nombre, dni, rol, sede, foto_perfil, fecha_nacimiento } = payload;

  const updateAuth: any = {};
  if (email) updateAuth.email = email;
  if (password) updateAuth.password = password;

  if (Object.keys(updateAuth).length > 0) {
    const { error: authError } = await client.auth.admin.updateUserById(uid, updateAuth);
    if (authError) throw authError;
  }

  const dbPayload: any = { nombre_real: nombre, dni, correo: email, rol, bahia: sede };
  if (foto_perfil !== undefined) dbPayload.foto_perfil = foto_perfil;
  if (fecha_nacimiento !== undefined) dbPayload.fecha_nacimiento = fecha_nacimiento;

  const { error: dbError } = await client.from('usuarios').update(dbPayload).eq('id', uid);
  if (dbError) throw dbError;

  return successResponse({ success: true });
}

/** Activa o desactiva un usuario en la tabla usuarios. */
async function _alternarEstado(client: any, payload: any, activar: boolean): Promise<Response> {
  const { uid } = payload;
  const { error } = await client.from('usuarios').update({ activo: activar }).eq('id', uid);
  if (error) throw error;
  return successResponse({ success: true });
}
/** Elimina un usuario permanentemente de Auth (y en cascada de la tabla usuarios). */
async function _eliminarUsuario(client: any, payload: any): Promise<Response> {
  const { uid } = payload;
  const { error } = await client.auth.admin.deleteUser(uid);
  if (error) throw error;
  return successResponse({ success: true });
}
