-- =============================================================================
-- MIGRACIÓN: 20260630000400_add_sede_usuarios.sql
-- Propósito: Añadir columna sede a la tabla public.usuarios.
-- =============================================================================

ALTER TABLE public.usuarios 
  ADD COLUMN IF NOT EXISTS sede text NOT NULL DEFAULT 'Piura';

-- Actualizar trigger de sincronización para auth.users para que también mande sede
CREATE OR REPLACE FUNCTION public.sync_perfil_a_auth()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE auth.users
  SET raw_user_meta_data = 
      coalesce(raw_user_meta_data, '{}'::jsonb) || 
      jsonb_build_object(
        'name', NEW.nombre_real,
        'phone', coalesce(NEW.telefono, ''),
        'sede', coalesce(NEW.sede, 'Piura')
      )
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_perfil_updated ON public.usuarios;
CREATE TRIGGER on_perfil_updated
  AFTER INSERT OR UPDATE OF nombre_real, telefono, sede ON public.usuarios
  FOR EACH ROW EXECUTE FUNCTION public.sync_perfil_a_auth();

-- Backfill para asegurar que todos los usuarios tengan la metadata actualizada
UPDATE auth.users au
SET raw_user_meta_data = coalesce(au.raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('name', pu.nombre_real, 'phone', coalesce(pu.telefono, ''), 'sede', coalesce(pu.sede, 'Piura'))
FROM public.usuarios pu
WHERE au.id = pu.id;
