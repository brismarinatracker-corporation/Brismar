DO $$
BEGIN
  -- Insertar el perfil público faltante para el administrador maestro
  INSERT INTO public.usuarios (id, nombre_real, rol)
  SELECT id, 'BrisGroup', 'administrador'
  FROM auth.users
  WHERE email = 'admin@brismar.com.pe'
  ON CONFLICT (id) DO NOTHING;
  
  -- Asegurar que la meta data en auth.users esté correcta para que se vea en el dashboard
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_build_object('name', 'BrisGroup', 'rol', 'administrador')
  WHERE email = 'admin@brismar.com.pe';
END $$;
