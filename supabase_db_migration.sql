-- 1. Añadir columnas a la tabla existente para agrupar por empresa y guardar URLs de reportes.
ALTER TABLE public.registro_embarcaciones
ADD COLUMN IF NOT EXISTS empresa_id UUID,
ADD COLUMN IF NOT EXISTS url_pdf_cloud TEXT,
ADD COLUMN IF NOT EXISTS url_excel_cloud TEXT;

-- 2. Crear un Bucket de Storage en Supabase para guardar los reportes.
INSERT INTO storage.buckets (id, name, public)
VALUES ('reportes', 'reportes', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Políticas de Seguridad (RLS) para el bucket 'reportes'
-- Permitir a cualquier usuario autenticado subir archivos al bucket
CREATE POLICY "Permitir subida de reportes a usuarios autenticados"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'reportes');

-- Permitir a cualquier usuario autenticado leer los reportes
CREATE POLICY "Permitir lectura de reportes a usuarios autenticados"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'reportes');

-- 4. Ajustar RLS de la tabla `registro_embarcaciones` para que usuarios de la misma "empresa" se vean entre sí (Opcional)
-- Si no usas "empresa_id", ignora esta última política.
-- CREATE POLICY "Ver registros de misma empresa"
-- ON public.registro_embarcaciones FOR SELECT
-- TO authenticated
-- USING (empresa_id = auth.jwt()->>'empresa_id');
