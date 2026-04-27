# Channel Sync Operational Spec / Especificacao Operacional de Sync por Canal

Last updated: 2026-04-26

## Objetivo

Fechar o fluxo de sync **1x por dia de madrugada** para manter o catálogo atualizado com estabilidade e baixo custo de quota.

## Cadência

- Sync principal: **diário**, janela recomendada entre **02:00 e 04:00** (fuso do projeto).
- Execução manual opcional: endpoint/admin para "rodar agora" (uso pontual).

## Fonte e persistência

1. Ler canais ativos em `channels` (`active = true`).
2. Buscar vídeos do YouTube Data API por canal (janela incremental).
3. Fazer `upsert` em `videos` por `youtube_video_id`.
4. Atualizar `last_seen_at = now()` nos vídeos vistos no sync atual.
5. Ao final da execução:
   - `mark_stale_videos_inactive('36 hours')`
   - `purge_inactive_videos('90 days')`

## Regra de indisponibilidade

- Vídeo indisponível **não é deletado imediatamente**.
- Primeiro passo: `is_active = false` + `deactivated_at` + `unavailable_reason`.
- Limpeza definitiva via TTL (90 dias por padrão).

## Quantidade por execução (recomendação inicial)

- Seed inicial por canal: até 80 vídeos.
- Incremental diário por canal: até 20 vídeos.
- Limite global por job: ajustar por quota (ex.: 1000 vídeos processados por execução).

## Observabilidade

- Registrar cada run em `sync_runs`:
  - canais processados
  - vídeos inseridos/atualizados/inativados
  - erros
  - horário início/fim
- Atualizar `channels.last_synced_at`, `last_sync_status`, `last_sync_error`.

## Contrato SQL

Aplicar `supabase_daily_sync_contract.sql` para:

- colunas de metadados em `channels`/`videos`
- índices de consulta e unicidade
- tabela de auditoria `sync_runs`
- funções:
  - `public.mark_stale_videos_inactive(interval)`
  - `public.purge_inactive_videos(interval)`

## Estado atual

- Contrato de dados e operação definidos no repositório.
- Falta conectar/implantar o executor diário (Edge Function/Cron) no ambiente Supabase.
