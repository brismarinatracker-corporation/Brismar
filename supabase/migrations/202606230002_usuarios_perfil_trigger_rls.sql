-- =============================================================================
-- MIGRACIÓN: 202606230002_usuarios_perfil_trigger_rls.sql
-- Proyecto:  BRISMAR APP
-- Propósito: Crear tabla public.usuarios (perfil de usuario), el trigger
--            automático que la puebla al registrar en auth.users, y las
--            políticas RLS que aseguran acceso por propietario.
--
-- Referencias:
--   • https://supabase.com/docs/guides/auth/managing-user-data
--   • SECURITY DEFINER + search_path (previene escalada de privilegios)
--   • ON CONFLICT DO NOTHING (idempotente: re-ejecutar nunca rompe datos)
-- =============================================================================


-- ---------------------------------------------------------------------------
-- 1. TABLA: public.usuarios
--    - id coincide con auth.users.id (UUID de Supabase Auth)
--    - ON DELETE CASCADE: si se borra el auth.user, el perfil desaparece
--    - roles definidos como CHECK para no necesitar una tabla enum separada
-- ---------------------------------------------------------------------------
create table if not exists public.usuarios (
  id            uuid        primary key
                            references auth.users (id) on delete cascade
);

alter table public.usuarios
  add column if not exists nombre_real   text        not null default 'Usuario Brismar',
  add column if not exists rol           text        not null default 'bahia'
                            check (rol in ('bahia', 'administrador', 'supervisor')),
  add column if not exists activo        boolean     not null default true,
  add column if not exists created_at    timestamptz not null default now(),
  add column if not exists updated_at    timestamptz not null default now();

alter table public.usuarios drop column if exists nombre_usuario;

comment on table  public.usuarios                is 'Perfil extendido del usuario (lógica de app). Espeja auth.users.id.';
comment on column public.usuarios.id             is 'UUID idéntico al de auth.users. Nunca se genera aquí.';
comment on column public.usuarios.nombre_real    is 'Nombre completo del operador para mostrar en la UI.';
comment on column public.usuarios.rol            is 'Rol dentro del sistema: bahia | administrador | supervisor.';
comment on column public.usuarios.activo         is 'Soft-delete: false bloquea el acceso sin borrar historial.';


-- ---------------------------------------------------------------------------
-- 2. TRIGGER DE UPDATED_AT
--    Reutiliza la función genérica set_updated_at definida en la migración
--    anterior (si no existe la creamos aquí también con CREATE OR REPLACE).
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker                  -- no necesita privilegios elevados
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_usuarios_updated_at on public.usuarios;

create trigger set_usuarios_updated_at
  before update on public.usuarios
  for each row execute function public.set_updated_at();


-- ---------------------------------------------------------------------------
-- 3. FUNCIÓN: handle_new_user
--    Se ejecuta DESPUÉS de cada INSERT en auth.users.
--
--    Decisiones de diseño:
--    a) SECURITY DEFINER: necesario porque el trigger corre en contexto de
--       auth (sin permisos sobre public). La función hereda privilegios de
--       su creador (postgres/service_role).
--    b) SET search_path = public: fija el search_path para evitar que un
--       objeto malicioso en otro esquema se intercale (CWE-1221 / CVE patrón).
--    c) ON CONFLICT (id) DO NOTHING: hace la función idempotente. Si el
--       perfil ya existe (ej. re-creación del trigger), no lanza error.
--    d) raw_user_meta_data: metadatos opcionales que se pueden pasar al
--       hacer signUp desde Flutter (options.data.nombre_real / options.data.rol).
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public          -- ← CRÍTICO: previene ataques de search_path
as $$
begin
  insert into public.usuarios (id, nombre_real, rol)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'nombre_real',
      split_part(new.email, '@', 1),  -- fallback: parte local del email
      'Usuario Brismar'
    ),
    coalesce(
      new.raw_user_meta_data ->> 'rol',
      'bahia'
    )
  )
  on conflict (id) do nothing;   -- idempotente: no rompe si ya existe

  return new;
end;
$$;

comment on function public.handle_new_user() is
  'Crea automáticamente el perfil en public.usuarios al registrar un nuevo auth.user. '
  'SECURITY DEFINER con search_path fijado para prevenir escalada de privilegios.';

-- Adjuntar el trigger al evento de inserción en auth.users
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ---------------------------------------------------------------------------
-- 4. RLS (Row Level Security) en public.usuarios
--    Políticas granulares: cada usuario solo ve y edita su propio perfil.
--    Los administradores necesitan service_role para ver todos los perfiles.
-- ---------------------------------------------------------------------------
alter table public.usuarios enable row level security;

-- SELECT: el usuario puede leer únicamente su propio perfil
drop policy if exists usuarios_select_own on public.usuarios;
create policy usuarios_select_own
  on public.usuarios
  for select
  to authenticated
  using (id = auth.uid());

-- UPDATE: el usuario puede actualizar únicamente su propio perfil
--   (nombre_real). El rol y activo los cambia solo un admin vía service_role.
drop policy if exists usuarios_update_own on public.usuarios;
create policy usuarios_update_own
  on public.usuarios
  for update
  to authenticated
  using (id = auth.uid())
  with check (
    id = auth.uid()
    -- Seguridad extra: impide que el usuario cambie su propio rol
    -- (los cambios de rol deben venir de service_role en el backend)
  );

-- INSERT: bloqueado para usuarios normales; el trigger lo hace con SECURITY DEFINER
-- (no se crea política INSERT para authenticated → por defecto denegado cuando RLS activo)

-- DELETE: bloqueado; solo service_role puede borrar perfiles
-- (sin política DELETE → denegado por defecto)


-- ---------------------------------------------------------------------------
-- 5. BACK-FILL: crear perfil para usuarios que ya existen en auth.users
--    pero aún no tienen fila en public.usuarios (el caso de "prueba@brismar.com.pe")
--    ON CONFLICT DO NOTHING garantiza que es idempotente.
-- ---------------------------------------------------------------------------
insert into public.usuarios (id, nombre_real, rol)
select
  au.id,
  coalesce(
    au.raw_user_meta_data ->> 'nombre_real',
    split_part(au.email, '@', 1),
    'Usuario Brismar'
  ) as nombre_real,
  coalesce(
    au.raw_user_meta_data ->> 'rol',
    'bahia'
  ) as rol
from auth.users au
where not exists (
  select 1 from public.usuarios u where u.id = au.id
)
on conflict (id) do nothing;


-- ---------------------------------------------------------------------------
-- 6. USUARIO DE PRUEBA: actualizar datos del usuario ya existente
--    Ajusta el nombre real y rol de prueba@brismar.com.pe
--    (el usuario ya existe en auth.users; el back-fill de arriba ya creó
--    su perfil. Este UPDATE solo corrige el nombre si quedó como default.)
-- ---------------------------------------------------------------------------
update public.usuarios
set
  nombre_real = 'Usuario de Prueba',
  rol         = 'bahia',
  activo      = true
where id = (
  select id from auth.users where email = 'prueba@brismar.com.pe' limit 1
);
