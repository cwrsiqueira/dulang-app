-- Códigos de acesso premium (uso único). Apenas a Edge Function (service_role) deve ler/escrever.
create table if not exists public.access_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  label text,
  used boolean not null default false,
  used_at timestamptz,
  created_at timestamptz not null default now(),
  constraint access_codes_code_key unique (code)
);

create index if not exists access_codes_code_idx on public.access_codes (code);

alter table public.access_codes enable row level security;

-- Sem políticas para anon/authenticated = nenhum acesso via PostgREST com JWT de app.
revoke all on public.access_codes from anon, authenticated;
grant select, insert, update, delete on public.access_codes to service_role;

comment on table public.access_codes is
  'Códigos de uso único para acesso premium validados pela Edge Function validate-access-code.';
