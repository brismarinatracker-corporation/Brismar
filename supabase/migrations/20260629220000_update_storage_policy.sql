-- Migración para permitir UPSERT en Storage (INSERT + UPDATE)

CREATE POLICY "Usuarios autenticados pueden actualizar fotos de zarpes"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING ( bucket_id = 'camaras-zarpes' );
