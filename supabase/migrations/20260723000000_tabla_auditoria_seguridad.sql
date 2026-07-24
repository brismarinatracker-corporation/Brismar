-- Migration: Crear tabla de auditoría inmutable de seguridad y triggers de auditoría
-- Fecha: 2026-07-23

-- 1. Crear la tabla inmutable timeline_audit_log
CREATE TABLE IF NOT EXISTS public.timeline_audit_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tabla_afectada TEXT NOT NULL,
    registro_id UUID NOT NULL,
    accion TEXT NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE')),
    usuario_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    creado_en TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 2. Habilitar RLS en timeline_audit_log
ALTER TABLE public.timeline_audit_log ENABLE ROW LEVEL SECURITY;

-- Política RLS: Solo lectura para administradores y supervisores autenticados
CREATE POLICY "Permitir lectura de auditoria a administradores y supervisores"
ON public.timeline_audit_log
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.usuarios u
        WHERE u.id = auth.uid()
        AND u.rol IN ('administrador', 'supervisor')
    )
);

-- Bloquear escrituras directas desde la API cliente (solo triggers de BD pueden insertar)
CREATE POLICY "Bloquear inserciones directas en auditoria"
ON public.timeline_audit_log
FOR INSERT
TO authenticated, anon
WITH CHECK (false);

-- 3. Función trigger para auditar cambios en tablas críticas
CREATE OR REPLACE FUNCTION public.fn_auditar_cambio_seguridad()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_id UUID;
    v_datos_anteriores JSONB := NULL;
    v_datos_nuevos JSONB := NULL;
    v_registro_id UUID;
BEGIN
    v_usuario_id := auth.uid();

    IF (TG_OP = 'DELETE') THEN
        v_datos_anteriores := to_jsonb(OLD);
        v_registro_id := OLD.id;
    ELSIF (TG_OP = 'UPDATE') THEN
        v_datos_anteriores := to_jsonb(OLD);
        v_datos_nuevos := to_jsonb(NEW);
        v_registro_id := NEW.id;
    ELSIF (TG_OP = 'INSERT') THEN
        v_datos_nuevos := to_jsonb(NEW);
        v_registro_id := NEW.id;
    END IF;

    INSERT INTO public.timeline_audit_log (
        tabla_afectada,
        registro_id,
        accion,
        usuario_id,
        datos_anteriores,
        datos_nuevos,
        creado_en
    ) VALUES (
        TG_TABLE_NAME,
        v_registro_id,
        TG_OP,
        v_usuario_id,
        v_datos_anteriores,
        v_datos_nuevos,
        now()
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Triggers en tablas críticas si existen
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'zarpes') THEN
        DROP TRIGGER IF EXISTS tr_auditoria_zarpes ON public.zarpes;
        CREATE TRIGGER tr_auditoria_zarpes
        AFTER INSERT OR UPDATE OR DELETE ON public.zarpes
        FOR EACH ROW EXECUTE FUNCTION public.fn_auditar_cambio_seguridad();
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'cuadres') THEN
        DROP TRIGGER IF EXISTS tr_auditoria_cuadres ON public.cuadres;
        CREATE TRIGGER tr_auditoria_cuadres
        AFTER INSERT OR UPDATE OR DELETE ON public.cuadres
        FOR EACH ROW EXECUTE FUNCTION public.fn_auditar_cambio_seguridad();
    END IF;
END $$;
