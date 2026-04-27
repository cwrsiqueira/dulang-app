-- ============================================================
-- Dulang - Contrato de sync diário (canais -> vídeos)
-- ============================================================
-- Objetivo:
-- 1) rodar sync 1x por dia (madrugada) via job externo/Edge Function
-- 2) inativar vídeos indisponíveis (não deletar na hora)
-- 3) limpar inativos antigos por retenção (TTL)

-- ----------------------------
-- Metadados de sync por canal
-- ----------------------------
alter table if exists channels
  add column if not exists active boolean default true,
  add column if not exists last_synced_at timestamptz,
  add column if not exists last_sync_status text,
  add column if not exists last_sync_error text;

-- ----------------------------
-- Metadados de saúde por vídeo
-- ----------------------------
alter table if exists videos
  add column if not exists last_seen_at timestamptz,
  add column if not exists last_checked_at timestamptz,
  add column if not exists unavailable_reason text,
  add column if not exists deactivated_at timestamptz;

-- Unicidade/idempotência (upsert por youtube_video_id)
create unique index if not exists videos_youtube_video_id_uidx
  on videos (youtube_video_id);

create index if not exists videos_is_active_published_idx
  on videos (is_active, published_at desc);

create index if not exists videos_deactivated_at_idx
  on videos (deactivated_at);

create index if not exists channels_active_idx
  on channels (active);

-- -----------------------------------------
-- Log de execução de sync (observabilidade)
-- -----------------------------------------
create table if not exists sync_runs (
  id bigint generated always as identity primary key,
  source text not null default 'youtube_daily_sync',
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  status text not null default 'running',
  channels_processed int not null default 0,
  videos_inserted int not null default 0,
  videos_updated int not null default 0,
  videos_inactivated int not null default 0,
  error_count int not null default 0,
  notes text
);

create index if not exists sync_runs_started_at_idx
  on sync_runs (started_at desc);

-- sync_runs é só log interno do sync: não use RLS sem políticas (Advisor INFO).
alter table if exists public.sync_runs disable row level security;

revoke all on table public.sync_runs from PUBLIC;
revoke all on table public.sync_runs from anon, authenticated;
grant select, insert, update, delete on table public.sync_runs to service_role;

-- -------------------------------------------------------
-- Função: inativar vídeos "sumidos" do catálogo recente
-- -------------------------------------------------------
-- Regra recomendada:
-- - durante o sync, a Edge Function atualiza last_seen_at = now() para vídeos
--   vistos na API.
-- - ao fim da execução, chamar esta função.
create or replace function public.mark_stale_videos_inactive(
  p_stale_interval interval default interval '36 hours'
)
returns integer
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_count integer;
begin
  update videos
     set is_active = false,
         deactivated_at = coalesce(deactivated_at, now()),
         unavailable_reason = coalesce(unavailable_reason, 'not_seen_recent_sync'),
         last_checked_at = now()
   where is_active = true
     and (
       last_seen_at is null
       or last_seen_at < now() - p_stale_interval
     );

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

-- --------------------------------------------------------
-- Função: limpeza TTL de vídeos inativos (retenção histórica)
-- --------------------------------------------------------
create or replace function public.purge_inactive_videos(
  p_retention interval default interval '90 days'
)
returns integer
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  v_count integer;
begin
  delete from videos
   where is_active = false
     and coalesce(deactivated_at, published_at, now()) < now() - p_retention;

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

-- --------------------------------------------------------
-- Exemplo de chamada no final da rotina diária:
-- select public.mark_stale_videos_inactive(interval '36 hours');
-- select public.purge_inactive_videos(interval '90 days');
-- --------------------------------------------------------

-- ============================================================
-- Security Advisor: SECURITY DEFINER + RPC (rls_auto_enable)
-- ============================================================
-- Se o Advisor acusar `public.rls_auto_enable()` como SECURITY DEFINER
-- executável por `anon`/`authenticated`, rode no SQL Editor (ajuste o nome
-- se o schema for outro):
--
-- revoke execute on function public.rls_auto_enable() from public;
-- revoke execute on function public.rls_auto_enable() from anon;
-- revoke execute on function public.rls_auto_enable() from authenticated;
--
-- Se a função ainda for necessária para manutenção interna, conceda só ao
-- papel de serviço (não use isso no app Flutter com anon key):
-- grant execute on function public.rls_auto_enable() to service_role;
--
-- Idealmente: não exponha helpers administrativos em `public` com SECURITY
-- DEFINER; mova para schema interno ou rode via migration com role postgres.

-- ============================================================
-- Security Advisor: extensão pg_net no schema public (WARN)
-- ============================================================
-- O Postgres/Supabase costuma NÃO permitir:
--   alter extension pg_net set schema extensions;
-- (erro: extension "pg_net" does not support SET SCHEMA)
--
-- Ou seja: esse aviso do Advisor pode continuar aparecendo mesmo assim.
-- Para o Dulang isso não quebra o sync: é só recomendação de “organização”.
--
-- Caminho pesado (NÃO rode sem planejar com backup):
-- 1) anotar/remontar jobs do pg_cron que usam net.http_post
-- 2) drop extension pg_net cascade;
-- 3) create extension pg_net with schema extensions;
-- 4) recriar os jobs
