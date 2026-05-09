# Supabase Functions - Dulang

## Ordem de execução (importante)

1. **Primeiro:** rode `supabase_daily_sync_contract.sql` no SQL Editor do Supabase.
2. **Depois:** publique a função `youtube-daily-sync`.
3. **Depois:** configure o agendamento diário de madrugada.

Sem o passo 1, a função pode falhar porque depende de:

- colunas extras em `channels`/`videos`;
- tabela `sync_runs`;
- funções `mark_stale_videos_inactive` e `purge_inactive_videos`.

## Variáveis de ambiente (secrets)

No projeto Supabase, configure:

- `YOUTUBE_API_KEY`
- `SUPABASE_URL` (normalmente já disponível no runtime)
- `SUPABASE_SERVICE_ROLE_KEY` (normalmente já disponível no runtime)

## `validate-access-code` (códigos de acesso premium)

1. Rode a migration `supabase/migrations/20260508120000_access_codes.sql` no SQL Editor (ou use o arquivo como referência).
2. `supabase functions deploy validate-access-code --no-verify-jwt`
3. Insira códigos na tabela `access_codes` (ver [`docs/ACCESS_CODES_SUPABASE.md`](../../docs/ACCESS_CODES_SUPABASE.md)).

### Segurança adicional aplicada

- validação estrita de formato (`A-Z0-9`, 8 a 32 caracteres);
- limitação de tentativas por cliente/IP (janela curta) para reduzir brute force.

## Deploy (exemplo via CLI)

```bash
supabase functions deploy youtube-daily-sync
```

## Agendamento diário (madrugada)

Use cron no Supabase para chamar a função 1x por dia, por exemplo:

- `0 3 * * *` (03:00 todos os dias)

## Teste manual pós-deploy

```bash
supabase functions invoke youtube-daily-sync
```

Depois valide no banco:

- `sync_runs` (status da execução);
- `channels.last_synced_at` e `last_sync_status`;
- `videos.last_seen_at`, `is_active`, `deactivated_at`.
