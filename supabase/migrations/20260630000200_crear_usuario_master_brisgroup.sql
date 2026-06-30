DO $$
DECLARE
  master_id uuid := gen_random_uuid();
BEGIN
  -- Verificar si el usuario ya existe para ser idempotente
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@brismar.com.pe') THEN
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password, 
      email_confirmed_at, raw_app_meta_data, raw_user_meta_data, 
      created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000', 
      master_id, 
      'authenticated', 
      'authenticated', 
      'admin@brismar.com.pe', 
      extensions.crypt('BrisGroup2026', extensions.gen_salt('bf')), 
      now(), 
      '{"provider":"email","providers":["email"]}', 
      '{"name":"BrisGroup", "rol": "administrador"}', 
      now(), 
      now(), '', '', '', ''
    );
    
    -- Insertar la identidad requerida por Supabase Auth
    INSERT INTO auth.identities (
      id, provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
    )
    VALUES (
      gen_random_uuid(),
      master_id::text,
      master_id, 
      format('{"sub":"%s","email":"%s"}', master_id::text, 'admin@brismar.com.pe')::jsonb, 
      'email', 
      now(), now(), now()
    );
  END IF;
END $$;
