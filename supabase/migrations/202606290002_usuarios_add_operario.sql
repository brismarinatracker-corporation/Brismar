ALTER TABLE public.usuarios DROP CONSTRAINT IF EXISTS usuarios_rol_check;
ALTER TABLE public.usuarios ADD CONSTRAINT usuarios_rol_check CHECK (rol in ('bahia', 'administrador', 'supervisor', 'operario'));
