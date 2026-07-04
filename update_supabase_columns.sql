-- Ejecuta esto en el SQL Editor de tu Supabase

-- 1. Agrega el campo pesador que faltaba
ALTER TABLE cuadres ADD COLUMN pesador TEXT;

-- 2. Agrega los nuevos campos tipo y cuadrilla
ALTER TABLE cuadres ADD COLUMN tipo TEXT;
ALTER TABLE cuadres ADD COLUMN cuadrilla TEXT;

-- Listo! Ya puedes usar la app.
