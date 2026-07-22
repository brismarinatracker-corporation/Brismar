CREATE OR REPLACE FUNCTION public.sync_perfil_a_auth()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
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
  EXCEPTION WHEN OTHERS THEN
    -- Ignorar error para que el UPDATE en public.usuarios no sea abortado
  END;
  RETURN NEW;
END;
$$;

-- Asegurar políticas de Storage para avatars (INSERT y UPDATE)
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Avatar Images can be uploaded by authenticated users" ON storage.objects;
CREATE POLICY "Avatar Images can be uploaded by authenticated users" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Avatar Images can be updated by authenticated users" ON storage.objects;
CREATE POLICY "Avatar Images can be updated by authenticated users" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'avatars');
