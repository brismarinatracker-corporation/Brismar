create table if not exists public.registro_embarcaciones (
  id uuid primary key,
  usuario_id uuid not null references auth.users (id) on delete restrict,
  nombre_embarcacion text not null,
  producto text not null,
  placa_carro text,
  kilos numeric(10, 2) not null,
  precio_por_kilo numeric(10, 2) not null,
  fecha date not null,
  hora text not null,
  muelle_inicio text not null,
  gasto_facturacion numeric(10, 2) not null default 0,
  gasto_personal numeric(10, 2) not null default 0,
  gasto_apoyo numeric(10, 2) not null default 0,
  gasto_agua numeric(10, 2) not null default 0,
  gasto_clorox numeric(10, 2) not null default 0,
  gasto_flete numeric(10, 2) not null default 0,
  gasto_hielo numeric(10, 2) not null default 0,
  gasto_otros numeric(10, 2) not null default 0,
  observaciones text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.registro_embarcaciones
  add column if not exists usuario_id uuid,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

-- Eliminar TODAS las políticas RLS existentes antes de cambiar tipos
-- (PostgreSQL no permite ALTER COLUMN tipo en columnas usadas por políticas)
do $$
declare
  pol record;
begin
  for pol in
    select policyname
    from pg_policies
    where tablename = 'registro_embarcaciones'
      and schemaname = 'public'
  loop
    execute format(
      'drop policy if exists %I on public.registro_embarcaciones',
      pol.policyname
    );
  end loop;
end;
$$;

alter table public.registro_embarcaciones
  alter column id type uuid using id::uuid,
  alter column usuario_id type uuid using usuario_id::uuid,
  alter column kilos type numeric(10, 2) using kilos::numeric(10, 2),
  alter column precio_por_kilo type numeric(10, 2) using precio_por_kilo::numeric(10, 2),
  alter column gasto_facturacion type numeric(10, 2) using gasto_facturacion::numeric(10, 2),
  alter column gasto_personal type numeric(10, 2) using gasto_personal::numeric(10, 2),
  alter column gasto_apoyo type numeric(10, 2) using gasto_apoyo::numeric(10, 2),
  alter column gasto_agua type numeric(10, 2) using gasto_agua::numeric(10, 2),
  alter column gasto_clorox type numeric(10, 2) using gasto_clorox::numeric(10, 2),
  alter column gasto_flete type numeric(10, 2) using gasto_flete::numeric(10, 2),
  alter column gasto_hielo type numeric(10, 2) using gasto_hielo::numeric(10, 2),
  alter column gasto_otros type numeric(10, 2) using gasto_otros::numeric(10, 2);

do $$
begin
  if exists (
    select 1
    from public.registro_embarcaciones
    where usuario_id is null
  ) then
    raise exception
      'registro_embarcaciones contiene filas sin usuario_id; asignar propietario real antes de activar RLS.';
  end if;
end;
$$;

alter table public.registro_embarcaciones
  alter column usuario_id set not null;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_registro_embarcaciones_updated_at
on public.registro_embarcaciones;

create trigger set_registro_embarcaciones_updated_at
before update on public.registro_embarcaciones
for each row
execute function public.set_updated_at();

alter table public.registro_embarcaciones enable row level security;

drop policy if exists registro_embarcaciones_select_own
on public.registro_embarcaciones;
create policy registro_embarcaciones_select_own
on public.registro_embarcaciones
for select
to authenticated
using (usuario_id = auth.uid());

drop policy if exists registro_embarcaciones_insert_own
on public.registro_embarcaciones;
create policy registro_embarcaciones_insert_own
on public.registro_embarcaciones
for insert
to authenticated
with check (usuario_id = auth.uid());

drop policy if exists registro_embarcaciones_update_own
on public.registro_embarcaciones;
create policy registro_embarcaciones_update_own
on public.registro_embarcaciones
for update
to authenticated
using (usuario_id = auth.uid())
with check (usuario_id = auth.uid());

drop policy if exists registro_embarcaciones_delete_own
on public.registro_embarcaciones;
create policy registro_embarcaciones_delete_own
on public.registro_embarcaciones
for delete
to authenticated
using (usuario_id = auth.uid());
