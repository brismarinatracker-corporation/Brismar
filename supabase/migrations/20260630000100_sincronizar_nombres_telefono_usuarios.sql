-- =============================================================================
-- MIGRACIÓN: 202606290001_sincronizar_nombres_telefono_usuarios.sql
-- Propósito: 
-- 1. Añadir 'telefono' a public.usuarios
-- 2. Asegurar que los nombres se vean en el Dashboard de Supabase (auth.users)
-- =============================================================================

-- 1. Añadir el teléfono (número) a la tabla de perfil público
ALTER TABLE public.usuarios 
  ADD COLUMN IF NOT EXISTS telefono text;

-- 2. Función para mantener sincronizado auth.users.raw_user_meta_data con public.usuarios
-- Supabase Dashboard lee la propiedad "name" o "full_name" de raw_user_meta_data para mostrar el "Display name"
CREATE OR REPLACE FUNCTION public.sync_perfil_a_auth()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Actualiza raw_user_meta_data agregando/modificando "name" y "phone" para el dashboard
  UPDATE auth.users
  SET raw_user_meta_data = 
      coalesce(raw_user_meta_data, '{}'::jsonb) || 
      jsonb_build_object(
        'name', NEW.nombre_real,
        'phone', coalesce(NEW.telefono, '')
      )
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$;

-- Trigger cuando se actualiza o inserta en public.usuarios (ej. desde el panel de admin web)
DROP TRIGGER IF EXISTS on_perfil_updated ON public.usuarios;
CREATE TRIGGER on_perfil_updated
  AFTER INSERT OR UPDATE OF nombre_real, telefono ON public.usuarios
  FOR EACH ROW EXECUTE FUNCTION public.sync_perfil_a_auth();

-- 3. Backfill: Actualizar los usuarios existentes para que aparezcan en el Dashboard
UPDATE auth.users au
SET raw_user_meta_data = coalesce(au.raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('name', pu.nombre_real, 'phone', coalesce(pu.telefono, ''))
FROM public.usuarios pu
WHERE au.id = pu.id;

