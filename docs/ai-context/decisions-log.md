# Decisions Log / Log de Decisoes

## EN

### 2026-04-27 - Phase 1 closed; Phase 2 starts with RevenueCat

- Decision: treat **Phase 1** (store/compliance baseline) as **complete on 2026-04-27** by operator sign-off, then prioritize **RevenueCat** integration as the next engineering block.
- Why: catalog sync, access posture, and player behavior are sufficient to move on; monetization was always the next roadmap phase.
- Impact: context docs and backlog shift to subscription SDK, offerings, paywall, and entitlement gating; residual items (SQLite file cleanup, SHA-pinned actions, more tests) stay as non-blocking follow-ups.

### 2026-04-27 - Home channel grid: thumbnail from newest catalog video per channel

- Decision: use the **most recent `published_at`** among active `VideoRow`s per `channelName` as the **background image** for each channel tile (except “Todos”), with a dark gradient and white label text; fallback to solid tile if no URL.
- Why: stronger visual scan for children without storing channel avatars in Supabase; stable choice independent of `getVideos()` shuffle.
- Impact: `dulang_widget.dart` builds a per-channel representative map; UX aligns with the hero card’s imagery language.

### 2026-04-26 - Daily channel sync policy (nightly) with inactive-first handling

- Decision: operate channel-to-video sync once per day (night window), mark unavailable videos inactive first, and purge inactive records by TTL (90 days).
- Why: lower quota/cost and simpler operation for a curated child-safe catalog, while keeping auditability and rollback safety.
- Impact: sync design now depends on daily executor + metadata fields (`last_seen_at`, `deactivated_at`, sync logs); unavailable content leaves feed immediately via `is_active=false`.

### 2026-04-26 - Add Supabase Edge Function skeleton for daily YouTube sync

- Decision: add `supabase/functions/youtube-daily-sync/index.ts` as the operational executor skeleton for daily sync.
- Why: move from docs-only contract to executable path with explicit env, per-channel status update, and final inactivation/TTL calls.
- Impact: repository now contains deployable function baseline; production still requires secret setup and cron scheduling in Supabase.

### 2026-04-26 - Harden app-side catalog loading for sync instability

- Decision: add timeout + single retry in `SupabaseService` reads and explicit Home recovery UI for error and empty catalog states.
- Why: while channel-to-video sync is still being closed end-to-end, child-facing Home needs predictable behavior instead of silent failures.
- Impact: transient Supabase/network failures are retried once; Home now offers direct "try again" actions for load errors and empty catalog windows.

### 2026-04-26 - Remove SQLite bootstrap initialization from app startup

- Decision: stop calling `SQLiteManager.initialize()` in `main.dart`.
- Why: primary runtime read path is already Supabase-based; keeping SQLite init on startup adds unnecessary coupling while migration boundaries are being finalized.
- Impact: app startup no longer depends on SQLite initialization; legacy SQLite modules remain in repository and still need controlled cleanup.

### 2026-04-27 - Cap history and favorites in `FFAppState` (MRU, FIFO on overflow)

- Decision: keep at most `kMaxHistoryEntries` (100) and `kMaxFavorites` (60) in persisted lists. Newest item stays at index 0; when over capacity, the oldest items at the end of the list are dropped.
- Why: bound SharedPreferences size and keep UI lists manageable, aligned with typical mobile patterns.
- Impact: `initializePersistedState` trims existing oversized lists once; all mutating paths call the same caps. No UI change.

### 2026-04-28 - Revert Android native fullscreen channel for YouTube

- Decision: remove `MethodChannel` / `MainActivity` system-bar loop and Android-only Dart hooks; keep `flutter_flow_youtube_player` fullscreen overlay (black scaffold + `SystemChrome` as before the experiment).
- Why: on target API 36 the native approach still did not hide bars reliably in the field; avoid ongoing maintenance risk while child-safety navigation in the player stays unchanged.
- Impact: `MainActivity` is a plain `FlutterActivity` again; no `androidx.core` dependency added for this purpose.

### 2026-04-28 - Phase 2: login required, RevenueCat entitlement, Flutter paywall (no RC paywall UI)

- Decision: after parental onboarding, require **Supabase Auth** session before the main shell; gate Home/Favorites/History on RevenueCat entitlement **`premium`** (includes store free trial when configured); implement **custom Flutter paywall** (`DulangPremiumWidget`) with monthly/annual packages from the default offering, annual pre-selected, pricing from the store via SDK—**not** RevenueCat’s hosted paywall UI (`purchases_ui_flutter`).
- Why: align with product (account + subscription only), keep brand/UI control, and use RevenueCat for receipts and `CustomerInfo` only.
- Impact: `GoRouter` redirect to `/login` when logged out (public exceptions: login, terms, about, contact); `SubscriptionService` configures SDK, `logIn`/`logOut` with Supabase `user.id`; `NavBarPage` shows `PremiumCatalogLockBody` when not entitled; `DulangVideoWidget` / `CanalVideosWidget` defensively block without entitlement; settings adds sign-out.

### 2026-04-28 - Child profiles: no silent "Perfil 1"; Netflix-style picker

- Decision: replace `ensureDefaultProfile()` with `syncActiveProfileWithStoredList()` (never auto-create a profile). After onboarding the pending picker remains; `NavBarPage` also opens `SelecionarPerfil` when the stored profile list is empty.
- Why: the adult should name the child via the existing picker (`Nome da criança`) instead of a default label.
- Impact: first-time and “zero profiles” flows land on profile selection until at least one profile exists.

### 2026-04-26 - YouTube in-app fullscreen on Android: native system bar hide

- **Superseded 2026-04-28:** this approach was reverted (see above).

### 2026-04-25 - Cursor as primary development environment

- Decision: use Cursor as the main day-to-day environment.
- Why: stronger integrated workflow for coding + context continuity.
- Impact: project context must be portable and tool-agnostic.

### 2026-04-25 - Single source AI context in repo

- Decision: centralize all persistent project context in `docs/ai-context/`.
- Why: avoid duplicated and divergent memory files across tools.
- Impact: assistant-specific files should be thin pointers only.

### 2026-04-25 - Harden parental PIN and Android release build

- Decision: store parental PIN in secure storage with hashed verification and enable Android release hardening flags.
- Why: reduce plaintext secret exposure on device and make reverse engineering harder in production.
- Impact: onboarding/verification uses secure PIN migration path; release builds use minification, resource shrinking, and obfuscation in CI.

### 2026-04-25 - Fix video switching on same GoRouter route

- Decision: key `DulangVideoWidget` by selected video id and reload YouTube player when `url` changes.
- Why: GoRouter can reuse `State` across navigations to the same route with different query params, leaving the old player controller attached.
- Impact: reliable multi-tap navigation from the list under the player; reduces black-screen risk when popping back.

### Historic technical decisions (carried from prior context)

- Use Supabase to replace static local SQLite for dynamic content updates.
- Use RevenueCat for subscription management and trial handling.
- Keep app safe for children, with strict parental and policy constraints.

## PT-BR

### 2026-04-27 - Fase 1 encerrada; Fase 2 comeca pelo RevenueCat

- Decisao: considerar a **Fase 1** (baseline loja/compliance) **concluida em 2026-04-27** por aceite do operador e priorizar em seguida a integracao **RevenueCat**.
- Motivo: sync de catalogo, postura de acesso e player estao suficientes para avancar; monetizacao ja era a proxima fase do roadmap.
- Impacto: documentacao e backlog passam a focar SDK, offerings, paywall e bloqueio por entitlement; limpeza SQLite, pin SHA em actions e mais testes ficam como follow-up nao bloqueante.

### 2026-04-27 - Grade Canais na Home: thumb do video mais novo do catalogo por canal

- Decisao: usar o **`published_at` mais recente** entre `VideoRow` ativos por `channelName` como **imagem de fundo** do tile (exceto "Todos"), com gradiente escuro e texto branco; sem URL, manter tile solido.
- Motivo: leitura visual melhor para crianca sem persistir avatar de canal no Supabase; escolha estavel independente do shuffle em `getVideos()`.
- Impacto: `dulang_widget.dart` monta mapa representativo por canal; linguagem visual alinhada ao hero.

### 2026-04-26 - Politica de sync diario (madrugada) com tratamento inativo-primeiro

- Decisao: operar sync de canais->videos 1x por dia (janela noturna), marcar indisponiveis como inativos primeiro e limpar inativos por TTL (90 dias).
- Motivo: menor custo/quota e operacao mais simples para catalogo curado infantil, mantendo trilha de auditoria e seguranca de rollback.
- Impacto: desenho do sync passa a depender de executor diario + metadados (`last_seen_at`, `deactivated_at`, logs de sync); conteudo indisponivel sai do feed imediatamente via `is_active=false`.

### 2026-04-26 - Adicionar esqueleto de Edge Function Supabase para sync diario do YouTube

- Decisao: adicionar `supabase/functions/youtube-daily-sync/index.ts` como executor operacional base do sync diario.
- Motivo: sair de contrato apenas documental para caminho executavel com env explicito, status por canal e chamadas finais de inativacao/TTL.
- Impacto: o repositorio passa a ter baseline de funcao implantavel; em producao ainda depende de configurar secrets e cron no Supabase.

### 2026-04-26 - Endurecer carregamento do catalogo no app para instabilidade de sync

- Decisao: adicionar timeout + uma tentativa de retry nas leituras do `SupabaseService` e UI explicita de recuperacao na Home para erro e catalogo vazio.
- Motivo: enquanto o sync canal->video ainda esta sendo fechado ponta a ponta, a Home infantil precisa de comportamento previsivel em vez de falha silenciosa.
- Impacto: falhas transitórias de rede/Supabase ganham uma nova tentativa; a Home agora oferece acao direta de "tentar novamente" para erro de carga e janela de catalogo vazio.

### 2026-04-26 - Remover inicializacao de bootstrap SQLite no startup do app

- Decisao: parar de chamar `SQLiteManager.initialize()` no `main.dart`.
- Motivo: o caminho principal de leitura em runtime ja esta baseado em Supabase; manter init de SQLite no startup adiciona acoplamento desnecessario enquanto a fronteira de migracao e fechada.
- Impacto: o startup do app nao depende mais da inicializacao de SQLite; os modulos legados continuam no repositorio e ainda exigem limpeza controlada.

### 2026-04-28 - Reverter fullscreen nativo Android no YouTube

- Decisao: remover `MethodChannel` / loop no `MainActivity` e os ganchos Dart especificos de Android; manter overlay de fullscreen (fundo preto + `SystemChrome` como antes do experimento).
- Motivo: no aparelho ainda nao escondia as barras de forma confiavel com target API 36; reduz risco de manutencao sem mexer na delegacao de navegacao do player.
- Impacto: `MainActivity` volta a ser `FlutterActivity` simples; dependencia `androidx.core` extra removida.

### 2026-04-28 - Fase 2: login obrigatorio, entitlement RevenueCat, paywall Flutter (sem UI nativa RC)

- Decisao: apos onboarding parental, exigir **sessao Supabase Auth** antes do shell principal; bloquear Home/Favoritos/Historico pelo entitlement **`premium`** no RevenueCat (inclui teste gratis da loja quando configurado); paywall **custom em Flutter** (`DulangPremiumWidget`) com pacotes mensal/anual da oferta padrao, **anual pre-selecionado**, precos da loja via SDK — **sem** paywall hospedada do RevenueCat (`purchases_ui_flutter`).
- Motivo: alinhar produto (so conta + assinatura), manter controle de marca/UI e usar RevenueCat so para recibos e `CustomerInfo`.
- Impacto: `GoRouter` redireciona para `/login` sem sessao (excecoes publicas: login, termos, sobre, contato); `SubscriptionService` configura SDK e faz `logIn`/`logOut` com `user.id` do Supabase; `NavBarPage` mostra `PremiumCatalogLockBody` sem direito ativo; `DulangVideoWidget` / `CanalVideosWidget` bloqueiam sem entitlement; Ajustes ganha sair da conta.

### 2026-04-28 - Perfis infantis: sem "Perfil 1" automatico; picker estilo Netflix

- Decisao: trocar `ensureDefaultProfile()` por `syncActiveProfileWithStoredList()` (nunca cria perfil sozinho). Depois do onboarding continua o flag de picker; `NavBarPage` tambem abre `SelecionarPerfil` quando a lista persistida esta vazia.
- Motivo: o adulto nomeia a crianca no fluxo existente ("Nome da criança") em vez de um rotulo padrao.
- Impacto: primeiro uso e caso "zero perfis" vao para a selecao ate existir pelo menos um perfil.

### 2026-04-27 - Limite de historico e favoritos no `FFAppState` (MRU, FIFO no excesso)

- Decisao: no maximo `kMaxHistoryEntries` (100) e `kMaxFavorites` (60) nas listas persistidas. O item mais recente fica no indice 0; acima do teto, remove os itens mais antigos (fim da lista).
- Motivo: limitar tamanho no SharedPreferences e manter listas usaveis, alinhado a apps moveis comuns.
- Impacto: `initializePersistedState` recorta listas antigas demais na primeira carga; todos os metodos que alteram lista aplicam o teto. Sem mudanca de UI.

### 2026-04-26 - Fullscreen do YouTube no Android: esconder barras via nativo

- **Substituído em 2026-04-28:** abordagem revertida (ver entrada de reversão acima).

### 2026-04-25 - Cursor como ambiente principal

- Decisao: usar o Cursor como ambiente principal no dia a dia.
- Motivo: fluxo integrado mais forte para codigo + continuidade de contexto.
- Impacto: contexto do projeto precisa ser portatil e neutro para ferramentas.

### 2026-04-25 - Fonte unica de contexto de IA no repo

- Decisao: centralizar o contexto persistente em `docs/ai-context/`.
- Motivo: evitar memoria duplicada e divergente entre ferramentas.
- Impacto: arquivos especificos de assistente devem ser apenas ponteiros.

### 2026-04-25 - Endurecer PIN parental e build de release Android

- Decisao: armazenar PIN parental em storage seguro com validacao por hash e ativar hardening no release Android.
- Motivo: reduzir exposicao de segredo em texto puro no dispositivo e dificultar engenharia reversa em producao.
- Impacto: onboarding/validacao usa migracao segura de PIN; builds de release usam minificacao, shrink e ofuscacao no CI.

### 2026-04-25 - Corrigir troca de video na mesma rota do GoRouter

- Decisao: usar `Key` no `DulangVideoWidget` baseada no id do video e recarregar o player quando `url` mudar.
- Motivo: o GoRouter pode reutilizar `State` na mesma rota com query params diferentes, mantendo controller antigo do YouTube.
- Impacto: navegacao confiavel com multiplos toques na lista sob o player; reduz risco de tela preta ao voltar.

### Decisoes tecnicas historicas (herdadas do contexto anterior)

- Usar Supabase para substituir SQLite local estatico e permitir atualizacao dinamica.
- Usar RevenueCat para assinaturas e trial.
- Manter app seguro para criancas, com restricoes parentais e de politica.
