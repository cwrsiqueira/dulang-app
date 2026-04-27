# Passo a passo: sync diário do YouTube no Supabase (bem simples)

Este arquivo é para você **seguir na ordem**, sem precisar voltar no chat.

---

## O que isso faz, em uma frase

O **Supabase** (servidor na nuvem) vai **atualizar a lista de vídeos** uma vez por dia, de madrugada. O aplicativo só **lê** essa lista — não precisa fazer nada sozinho no celular.

---

## O que você precisa ter em mãos antes de começar

1. Conta no **Supabase** e o projeto aberto no navegador.
2. O arquivo do seu computador: **`supabase_daily_sync_contract.sql`** (está na pasta do projeto Dulang).
3. A **chave da API do YouTube** (aquela que você já usa para o app funcionar).  
   - Guarde só para você. **Não** mande no WhatsApp, **não** cole no GitHub.

---

# Parte A — Preparar o banco de dados (você já deve ter feito o passo 1 do checklist)

## Passo A1 — Abrir o lugar certo no Supabase

1. Entre em [https://supabase.com](https://supabase.com) e abra o **projeto** do Dulang.
2. No menu **à esquerda**, clique em **SQL** (às vezes aparece como **SQL Editor**).
3. Você vai ver uma caixa grande de texto e um botão para **rodar** o comando (tipo **Run** ou **Executar**).

Esse lugar é só isso: **onde você cola texto de banco de dados e clica para rodar**.

## Passo A2 — Colar o arquivo do contrato

1. No seu computador, abra o arquivo **`supabase_daily_sync_contract.sql`** com o Bloco de Notas ou VS Code.
2. Selecione **tudo** (Ctrl+A), copie (Ctrl+C).
3. Volte no Supabase, na caixa do **SQL Editor**, cole (Ctrl+V).
4. Clique em **Run** / **Executar**.

Se aparecer erro, copie a mensagem de erro e guarde — mas o ideal é rodar sem erro.

**Pronto.** Essa parte prepara tabelas e funções que o sync usa.

---

# Parte B — Publicar a função que roda o sync (equivalente ao “deploy”)

A “função” aqui é um **pequeno programa** que fica no Supabase e pode ser chamado de fora.

## Passo B1 — Abrir o terminal na pasta do projeto

1. Abra o **PowerShell** ou o terminal do Cursor.
2. Vá para a pasta do projeto, por exemplo:

```text
cd c:\projetos\dulang-app
```

## Passo B2 — Entrar na sua conta do Supabase pela linha de comando

Rode **este** comando (ele abre o navegador para você logar):

```text
npx supabase login
```

## Passo B3 — Ligar o terminal ao seu projeto do Supabase

Você precisa do **código do projeto** (ref). No painel do Supabase:

1. Clique na **engrenagem** (Settings / Configurações).
2. Abra **General**.
3. Lá tem **Reference ID** — é um texto curto tipo `abcdxyz...`.

Depois rode (troque pelo seu código real):

```text
npx supabase link --project-ref SEU_REFERENCE_ID
```

## Passo B4 — Publicar a função

Rode:

```text
npx supabase functions deploy youtube-daily-sync
```

Espere terminar sem erro.

## Passo B5 — Guardar a chave do YouTube onde a função enxerga

Ainda no terminal, na pasta do projeto, rode (troque pela sua chave real):

```text
npx supabase secrets set YOUTUBE_API_KEY=SUA_CHAVE_DO_YOUTUBE_AQUI
```

**O que isso faz:** grava a chave num cofre do Supabase. A função lê de lá. Você **não** precisa colar essa chave dentro do código do app para esse passo.

---

# Parte C — Testar se a função funciona (antes de agendar)

No painel do Supabase:

1. Menu esquerdo → **Edge Functions**.
2. Clique na função **`youtube-daily-sync`**.
3. Procure um botão tipo **Test**, **Invoke** ou **Send request** (o nome muda).
4. Clique e veja se responde **ok** ou se mostra erro.

Se der erro, anote a mensagem.

Outro jeito pelo terminal:

```text
npx supabase functions invoke youtube-daily-sync
```

---

# Parte D — Agendar todo dia de madrugada (é aqui que você parou no item 4)

Você **não** achou aba “Schedule”. Tudo bem. Vamos fazer pelo **mesmo lugar do Passo A1** (SQL Editor).

## O que é esse “cron” / “pg_cron”?

- **Cron** = relógio que dispara **todo dia no mesmo horário**.
- **pg_cron** = nome da ferramenta que fica **dentro do banco** do Supabase para marcar esse horário.

Você **não** precisa instalar nada no Windows para isso: só colar um texto no **SQL Editor** e rodar.

## O que é “UTC” e por que falei disso?

O relógio do servidor do Supabase muitas vezes está em **UTC** (fuso de Londres).  
No Brasil, quando não está horário de verão, **Brasília = UTC menos 3 horas**.

Exemplo:

- Quer **3 da manhã em Brasília**?
- No UTC isso vira **6 da manhã** do mesmo dia.

Por isso o agendamento aparece como `0 6 * * *` nos exemplos abaixo.

Se no futuro você quiser outro horário, me diga o horário de Brasília que eu te digo o número certo — mas por agora use o exemplo.

## O que é “Bearer” e “SERVICE_ROLE_KEY”?

- **SERVICE_ROLE_KEY** é uma **chave muito poderosa** do seu projeto (fica no painel do Supabase).
- Ela aparece em: **Settings (engrenagem) → API → service_role** (às vezes escrito como “secret”).
- **Bearer** é só o formato que o sistema pede na frente dessa chave.

**Regra de ouro:** essa chave é **secreta**. Não coloque em lugar público. Só use **dentro do Supabase** neste passo.

## Passo D1 — Ativar extensões (uma vez só)

No **SQL Editor**, cole e rode:

```sql
create extension if not exists pg_cron;
create extension if not exists pg_net;
```

## Passo D2 — Criar o agendamento (cole, ajuste 2 coisas, rode)

No **SQL Editor**, cole o bloco abaixo.

**Você precisa trocar só 2 partes:**

1. A **URL** da função — deve ser igual à que aparece no topo da tela da função no painel (começa com `https://` e termina com `/youtube-daily-sync`).
2. O texto **`COLE_AQUI_A_SERVICE_ROLE_KEY`** — substitua pela chave que você copiou em **Settings → API → service_role** (sem aspas a mais, sem espaço no começo).

```sql
select cron.schedule(
  'youtube-daily-sync-diario',
  '0 6 * * *',
  $$
  select net.http_post(
    url := 'COLE_AQUI_A_URL_COMPLETA_DA_FUNCAO',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer COLE_AQUI_A_SERVICE_ROLE_KEY'
    ),
    body := '{}'::jsonb
  );
  $$
);
```

Clique em **Run**.

### Por que a chave fica “fixa” nesse texto?

Porque o agendador do banco **precisa** mandar um pedido autenticado para a função. **Não existe botão mágico** no painel que preencha isso sozinho hoje.

**O que você deve fazer na prática:**

- Use esse jeito **agora** para funcionar.
- **Não** commite esse SQL com a chave no GitHub.
- Guarde uma cópia **só sua** (bloco de notas privado, cofre de senhas).

Quando você quiser “o jeito mais seguro de cofre” (Vault), isso é um passo extra com mais cliques — **não é obrigatório** para o sync começar a rodar.

## Passo D3 — Ver se o agendamento foi criado

No **SQL Editor**, rode:

```sql
select jobid, jobname, schedule, active
from cron.job
where jobname = 'youtube-daily-sync-diario';
```

Se aparecer uma linha, **deu certo**.

---

# Parte E — Avisos do “Security Advisor” (o que fazer, sem “talvez”)

## E1 — Aviso das funções `mark_stale_videos_inactive` e `purge_inactive_videos`

**O que fazer:** rode de novo no **SQL Editor** o arquivo **`supabase_daily_sync_contract.sql`** (ele já foi ajustado no projeto para corrigir isso).

Ou seja: **mesmo passo do Passo A2**, de novo, para atualizar as funções.

## E2 — Aviso da função `rls_auto_enable` (perigosa para visitante)

**O que fazer (faça exatamente isto):**

No **SQL Editor**, cole e rode:

```sql
revoke execute on function public.rls_auto_enable() from public;
revoke execute on function public.rls_auto_enable() from anon;
revoke execute on function public.rls_auto_enable() from authenticated;
```

**Não faça** o “melhor ainda” agora — ignore isso. O que importa é **tirar a permissão** de quem não é administrador.

Se depois alguma ferramenta interna sua **parar** de funcionar por causa disso, a gente ajusta com calma — mas para o app infantil isso é **prioridade**.

## E3 — Aviso “Extension in Public” (extensão `pg_net` no lugar errado)

**Em português simples:** o painel avisa que a extensão `pg_net` está no schema `public`. A ideia seria “mudar de pasta” para `extensions`.

**Mas tem um detalhe importante:** no Supabase/Postgres, a `pg_net` **muitas vezes não aceita** o comando de mudar de pasta. Se você tentar, aparece exatamente este erro:

`extension "pg_net" does not support SET SCHEMA`

**O que fazer na prática (escolha 1):**

1) **Mais simples (recomendado agora):** **não faça nada** por causa desse aviso.  
   O sync já está funcionando. Esse aviso é mais “organização / boa prática” do que “buraco de segurança urgente” do tipo chave vazada.

2) **Só se você quiser insistir no aviso:** isso vira um trabalho **grande** (apagar e recriar a extensão com cuidado e remontar o agendamento). **Não recomendo** fazer sozinho sem backup e sem anotar o agendamento do cron.

**Importante:** eu removi do arquivo `supabase_daily_sync_contract.sql` o trecho que tentava mover a `pg_net`, porque ele **quebra** no seu caso.

## E4 — Info “RLS enabled no policy” na tabela `sync_runs`

**Em português simples:** a tabela `sync_runs` (log do sync) ficou com uma trava de segurança ligada (**RLS**), mas **sem regra** escrita. Isso gera aviso.

**O que fazer:** rode de novo o **`supabase_daily_sync_contract.sql`** atualizado. Ele agora:

- **desliga** essa trava nessa tabela interna;
- deixa só o **papel de serviço** (`service_role`) mexendo nela (é o que a função usa).

Isso é o comportamento certo para uma tabela de **log interno**, não para dados que o app da criança lê direto.

---

## Se você travar de novo

Me diga **em qual número de passo** você parou (A2, B4, D2, etc.) e **o que apareceu na tela** (ou copie o erro). Eu respondo em cima desse arquivo, sem depender do histórico do chat.
