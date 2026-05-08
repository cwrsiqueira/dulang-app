# Códigos de acesso premium (uso único)

O app valida um **código alfanumérico** na Edge Function `validate-access-code`, que marca o registro como **usado** no Postgres. O **mesmo código não pode ser reutilizado** depois do primeiro sucesso. O flag “liberado” fica em `SharedPreferences` no aparelho.

## 1) Criar a tabela no Supabase

**Opção A — migration no repositório**

O arquivo [`supabase/migrations/20260508120000_access_codes.sql`](../supabase/migrations/20260508120000_access_codes.sql) cria a tabela `public.access_codes`, RLS sem políticas públicas e revoga `anon`/`authenticated`.

**Opção B — SQL Editor (cole e execute)**

```sql
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

revoke all on public.access_codes from anon, authenticated;
grant select, insert, update, delete on public.access_codes to service_role;
```

Ninguém lê a tabela pelo client do app (`anon`); só a Edge Function com `service_role`.

## 2) Publicar a Edge Function

Na pasta do projeto (com [Supabase CLI](https://supabase.com/docs/guides/cli) logado no projeto):

```bash
supabase functions deploy validate-access-code --no-verify-jwt
```

> `--no-verify-jwt`: o app chama com a `anon` key; a função não exige usuário logado.  
> `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` já existem no runtime das Edge Functions.

Teste local (opcional):

```bash
supabase functions invoke validate-access-code --body '{"code":"TESTE1"}'
```

## 3) Criar códigos (um por revisor / campanha)

No **SQL Editor** do Supabase:

```sql
insert into public.access_codes (code, label)
values
  ('DULANGREV2026', 'revisor-google-play'),
  ('DULANGMIDIA01', 'imprensa');
```

Use **apenas letras e números**; o app normaliza para **maiúsculas** e remove espaços. O valor em `code` deve ser **exatamente** o que você vai colocar nas instruções do Play Console.

Para listar códigos ainda não usados:

```sql
select code, label, used, used_at
from public.access_codes
where not used
order by created_at desc;
```

## 4) Texto sugerido — Play Console → Conteúdo do app → Instruções de acesso

Em inglês (revisor):

```
No paid signup required. Full app access with a one-time access code:

1. Complete onboarding: set a 4-digit PIN (e.g. 1234) and a child's name.
2. On the Premium screen, tap "Tenho um código de acesso" (I have an access code).
3. Enter this code: DULANGREV2026
4. Tap Confirm — all features unlock immediately.

Premium subscription features (Favorites, History, themes, schedules) are intentionally unavailable without an active entitlement or valid code.
```

Substitua `DULANGREV2026` pelo código que você inseriu no banco.

## 5) Desinstalar o app

- **Sim:** ao desinstalar, os dados locais do app somem; o usuário **perde o “flag” local** de acesso.
- O código **já foi consumido** no servidor (`used = true`), então **não pode usar o mesmo código de novo** nesse ou em outro aparelho.
- Para novo teste é preciso **inserir outro código** no Supabase ou **não marcar como revisão final** antes de consumir o único código do revisor (crie um código dedicado só para o Google).

## 6) App mostra “Erro de rede. Verifique a conexão e tente novamente.”

Essa mensagem vem do `catch` em `AccessCodeService.redeem` — ou seja, a chamada a **`functions.invoke('validate-access-code')`** falhou **antes** de interpretar `status` HTTP (não é “código inválido”).

Checklist para retomar amanhã:

| Verificar | Detalhe |
|-----------|---------|
| `environment.json` local | `SUPABASE_URL` e `SUPABASE_ANON_KEY` do **mesmo** projeto onde a função está deployada. |
| Edge Function | Função `validate-access-code` existe e foi publicada com **`--no-verify-jwt`**. |
| Rede / dispositivo | Wi‑Fi ou dados; firewall corporativo pode bloquear `*.supabase.co`. |
| `flutter run` | URL correta no bundle (arquivo `assets/environment_values/environment.json` presente). |

Para ver o erro real em debug: breakpoint ou `debugPrint` no `catch` de `redeem` temporariamente (`$e`).

**Após a falha de rede:** se depois o código “funciona” ao reiniciar, pode ser teste com HTTP 200 em uma tentativa posterior — confirmar no painel se a linha em `access_codes` foi marcada como `used` só quando a validação deu certo.
