-- ==============================================================================
-- Migración: 20260703_calcular_utilidad
-- Descripción: Crea una función RPC para calcular la utilidad neta de un cuadre
--              de pesca directamente en Supabase, sumando ventas y restando 
--              compras y gastos. De esta manera la lógica de negocio queda 
--              centralizada y disponible globalmente para BrisWeb y BrisAdmin.
-- ==============================================================================

CREATE OR REPLACE FUNCTION calcular_utilidad_cuadre(p_cuadre_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    v_total_ventas NUMERIC := 0;
    v_total_compras NUMERIC := 0;
    v_total_gastos NUMERIC := 0;
    v_utilidad_neta NUMERIC := 0;
BEGIN
    -- 1. Calcular Total de Ventas
    SELECT COALESCE(SUM(kilos * precio_unitario), 0)
    INTO v_total_ventas
    FROM ventas_cuadre
    WHERE cuadre_id = p_cuadre_id;

    -- 2. Calcular Total de Compras
    SELECT COALESCE(SUM(kilos * precio_unitario), 0)
    INTO v_total_compras
    FROM compras_cuadre
    WHERE cuadre_id = p_cuadre_id;

    -- 3. Calcular Total de Gastos
    SELECT COALESCE(SUM(cantidad * costo_unitario), 0)
    INTO v_total_gastos
    FROM gastos_cuadre
    WHERE cuadre_id = p_cuadre_id;

    -- 4. Calcular Utilidad Neta
    v_utilidad_neta := v_total_ventas - v_total_compras - v_total_gastos;

    -- Opcional: Si deseas que esta función actualice directamente la tabla de cuadres:
    -- UPDATE cuadres_web SET utilidad_neta = v_utilidad_neta WHERE id = p_cuadre_id;

    RETURN v_utilidad_neta;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ejemplo de uso desde Flutter:
-- await supabase.rpc('calcular_utilidad_cuadre', params: {'p_cuadre_id': cuadre.id});
