-- Agregar política para que los usuarios autenticados puedan actualizar zarpes
-- Esto es necesario para cambiar el estado a RECIBIDO_LAMBAYEQUE

CREATE POLICY "Usuarios autenticados pueden actualizar zarpes" 
    ON public.zarpes FOR UPDATE 
    TO authenticated 
    USING (true)
    WITH CHECK (true);
