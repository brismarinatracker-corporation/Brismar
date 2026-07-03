-- Migración para crear tablas maestras de configuración y listados estáticos
-- Date: 2026-07-03

CREATE TABLE public.especies_pesca (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    activo BOOLEAN DEFAULT true,
    orden INT DEFAULT 0
);

CREATE TABLE public.tipos_gasto (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    activo BOOLEAN DEFAULT true,
    orden INT DEFAULT 0
);

-- RLS
ALTER TABLE public.especies_pesca ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tipos_gasto ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura publica de especies" ON public.especies_pesca FOR SELECT USING (true);
CREATE POLICY "Lectura publica de gastos" ON public.tipos_gasto FOR SELECT USING (true);

-- Inserción de valores por defecto
INSERT INTO public.especies_pesca (nombre, orden) VALUES
('POTA', 1),
('JUREL', 2),
('BONITO', 3),
('CABALLA', 4),
('PERICO', 5);

INSERT INTO public.tipos_gasto (nombre, orden) VALUES
('Flete', 1),
('Hielo', 2),
('Estiba', 3),
('Petróleo', 4),
('Descarga', 5),
('Víveres', 6),
('Pasajes', 7),
('Otros', 99);
