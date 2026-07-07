-- Ejecuta esto en el SQL Editor de tu Supabase

-- 1. Agrega el campo pesador que faltaba
ALTER TABLE cuadres ADD COLUMN pesador TEXT;

-- 2. Agrega los nuevos campos tipo y cuadrilla
ALTER TABLE cuadres ADD COLUMN tipo TEXT;
ALTER TABLE cuadres ADD COLUMN cuadrilla TEXT;

-- 3. Agrega el campo observaciones en la tabla zarpes
ALTER TABLE zarpes ADD COLUMN observaciones TEXT;

-- 4. Forzar la recarga del esquema en Supabase (evita el error PGRST204)
NOTIFY pgrst, 'reload schema';

-- Listo! Ya puedes usar la app.
