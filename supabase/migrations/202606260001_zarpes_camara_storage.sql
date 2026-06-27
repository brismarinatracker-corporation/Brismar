-- Migración: Flujo 08 - Zarpes de Cámara con Foto
-- Fecha: 2026-06-26

-- 1. Crear tabla zarpes
CREATE TABLE IF NOT EXISTS public.zarpes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placa_camara TEXT NOT NULL,
    chofer TEXT NOT NULL,
    muelle_partida TEXT NOT NULL,
    foto_url_evidencia TEXT NOT NULL,
    fecha_zarpe TIMESTAMPTZ NOT NULL DEFAULT now(),
    creado_por UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Habilitar RLS en zarpes
ALTER TABLE public.zarpes ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para zarpes
CREATE POLICY "Zarpes visibles para todos los autenticados" 
    ON public.zarpes FOR SELECT 
    TO authenticated 
    USING (true);

CREATE POLICY "Usuarios autenticados pueden insertar zarpes" 
    ON public.zarpes FOR INSERT 
    TO authenticated 
    WITH CHECK (auth.uid() = creado_por);

-- 2. Configurar Supabase Storage para fotos de Zarpes
INSERT INTO storage.buckets (id, name, public) 
VALUES ('camaras-zarpes', 'camaras-zarpes', true)
ON CONFLICT (id) DO NOTHING;

-- Políticas de Storage para el bucket camaras-zarpes
-- A) Lectura Pública
CREATE POLICY "Imágenes de zarpe de cámara son públicas"
    ON storage.objects FOR SELECT
    TO public
    USING ( bucket_id = 'camaras-zarpes' );

-- B) Inserción Autenticada
CREATE POLICY "Cualquier usuario autenticado puede subir fotos de zarpes"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK ( bucket_id = 'camaras-zarpes' );
