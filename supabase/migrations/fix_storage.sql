-- Asegurar políticas de Storage para avatars (INSERT y UPDATE)
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Avatar Images can be uploaded by authenticated users" ON storage.objects;
CREATE POLICY "Avatar Images can be uploaded by authenticated users" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Avatar Images can be updated by authenticated users" ON storage.objects;
CREATE POLICY "Avatar Images can be updated by authenticated users" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'avatars');
