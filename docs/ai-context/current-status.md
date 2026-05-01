# Current Status / Status Atual

Last updated: 2026-05-01

## Phase 1 closure / Encerramento da Fase 1

**EN:** Phase 1 (store readiness + compliance baseline) remains **closed by operator sign-off on 2026-04-27** (unchanged).

**PT-BR:** A **Fase 1** permanece **encerrada com aceite do operador em 2026-04-27** (sem mudança).

## Phase 2 progress / Andamento da Fase 2 (2026-04-28)

**EN:** **App-side Phase 2 (updated 2026-04-28):** **No mandatory app login** — catalog and paywall are open after onboarding; purchases restore via **store account** + RevenueCat; RevenueCat SDK via **`SubscriptionService`** with entitlement **`dulang_premium_entitlement`** (anonymous RC user per install; no Supabase `logIn` coupling); **custom Flutter paywall** (`DulangPremiumWidget`, sticky CTA); **direct paywall** when tapping premium content without entitlement; **subscription management** (`DulangSubscriptionManageWidget` + `managementURL`) for subscribers; **parental PIN** still gates settings; **change parental PIN** uses **device biometrics / device PIN** (`local_auth`) before saving. **Manage subscription UX (2026-04-28):** friendlier plan labels + clearer recurring price line; store copy conditional (**Google Play** vs **App Store**); **Restore purchases** removed from manage screen (kept on paywall). **Root Android back:** removed legacy snackbar PIN gate on hardware back from the main shell (`NavBarPage`); normal back behavior resumes when the router cannot pop. **Play Console ops:** 7-day trial offers created per plan; **License testing** must have the tester email list **selected** (checkbox) + **Save** — otherwise purchases behave like production. **Internal testing caveat (operator 2026-04-28):** a second Google account can show **Play Store “Item not found”** on the opt-in download even when the release is “Available to testers”; workaround is to keep QA on the known-good tester account until Play propagation/account eligibility stabilizes, or retry later. **Still required outside the repo / on consoles:** default offering package wiring sanity-check, `REVENUECAT_IOS_KEY` (or dart-define), and **device QA** for cancel/change-plan + sandbox confirmation on Android (Windows) and iOS (Mac mini). Supabase remains for data APIs as configured; Auth optional. **Repo version for latest Play upload:** `pubspec.yaml` **`1.0.38+38`**.

**Plain-language ops guide (stores + subscription + parental PIN limits):** [`docs/PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`](../PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md).
**Play sandbox QA checklist:** [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](../CHECKLIST_TESTE_SANDBOX_PLAY.md).
**Play Store listing copy (pt-BR, policy-aligned):** [`docs/play-store-listing-dulang.md`](../play-store-listing-dulang.md).

**PT-BR:** **Fase 2 no app (atualizado em 2026-04-28):** **sem login obrigatório no app** — catálogo e assinatura após onboarding; compras na **conta da loja** + restaurar compras; SDK RevenueCat em **`SubscriptionService`** com entitlement **`dulang_premium_entitlement`** (usuário anônimo RC por instalação); **paywall Flutter** (`DulangPremiumWidget`, CTA fixo); **paywall direta** ao tocar conteúdo premium sem direito; **Gerenciar assinatura** (`DulangSubscriptionManageWidget` + `managementURL`) para quem já tem Premium; **PIN parental** protege Ajustes; **alterar PIN parental** com **`local_auth`**. **UX Gerenciar assinatura (2026-04-28):** rótulos de plano mais amigáveis + linha de preço/recorrência mais clara; texto da loja condicional (**Google Play** vs **App Store**); **Restaurar compras** removido da tela de gestão (permanece no paywall). **Botão voltar (Android) na casca principal:** removido o fluxo legado de banner/PIN ao voltar na raiz (`NavBarPage`); o back volta ao comportamento normal quando o router não pode dar pop. **Operação Play Console:** ofertas de trial de 7 dias criadas por plano; em **Teste de licença** a lista de e-mails precisa estar **marcada** + **Salvar alterações** — senão a compra tende a ser tratada como produção. **Observação de teste interno (operador 2026-04-28):** uma segunda conta Google pode cair em **“Item not found”** ao baixar pelo link de opt-in mesmo com release **Disponível para testers**; seguir QA com a conta que já funciona até estabilizar propagação/elegibilidade, ou tentar de novo depois. **Ainda falta fora do repositório:** conferência fina de oferta padrão/pacotes no RevenueCat, **`REVENUECAT_IOS_KEY`**, **QA em aparelho** (cancelar/mudar plano + confirmar sandbox). Supabase para APIs de dados; Auth opcional. **Versão no repo para upload Play mais recente:** `pubspec.yaml` **`1.0.38+38`**.

**Guia operacional em linguagem simples (lojas + assinatura + PIN):** [`docs/PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`](../PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md) — inclui **Parte 2b** (conta de serviço Google + JSON no RevenueCat, AAB em teste interno) e **Parte 2c** (Famílias/WebView, 16 KB, API 35 / `targetSdk`).
**Checklist sandbox Play (compra/cancelamento/restore em teste):** [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](../CHECKLIST_TESTE_SANDBOX_PLAY.md).
**Textos da ficha (Play Store, pt-BR):** [`docs/play-store-listing-dulang.md`](../play-store-listing-dulang.md).

## Freemium QA em progresso (2026-05-01)

**PT-BR:** Bugs corrigidos em sessão de QA: gates de conteúdo (vídeo/canal/home) não permitiam acesso freemium → corrigido (`dulang_widget`, `dulang_video_widget`, `canal_videos_widget`); paywall mostrava card free para usuário já enrolled → corrigido; spinner eterno no bottom sheet → corrigido (Brevo chamado antes do pop); email não chegava no Brevo → slug da Edge Function era `hyper-function` (não `register-free-plan`) + toggle JWT desativado. Fluxo de onboarding corrigido: perfil criado durante o onboarding antes de `setOnboardingDone()` → paywall → enroll → home. **Pendentes:** tema escuro ativo mas Aparência mostra claro; crash ao tocar no tema claro; botão voltar invisível na tela Sobre. Prints de debug temporários em `free_plan_email_sheet.dart` — remover antes do release.

## Freemium plan + security (2026-04-30)

**EN:** Three-tier model implemented: **Free** (1h/day, lifetime, email capture) / **Monthly** / **Annual**. `FreemiumService` singleton (`lib/features/subscription/freemium_service.dart`) — `isEnrolled`, `enroll(email)`, `addUsedMinutes`, `isUnderDailyLimit`, `reset()`. Email captured via `FreePlanEmailSheet` bottom sheet (LGPD consent + Brevo integration). Brevo API key kept server-side: Supabase Edge Function `register-free-plan` (`supabase/functions/register-free-plan/index.ts`) — receives email, calls Brevo API using `BREVO_API_KEY` / `BREVO_LIST_ID` secrets. Router gate post-onboarding: no plan (not enrolled + no premium) → `DulangPremiumWidget(isGate: true)` (no back button, router auto-redirects on enroll/purchase). `FreemiumService` added to router `refreshListenable`. Feature gates for free tier: Favoritos → `PremiumGateScreen`; Histórico → `PremiumGateScreen`; Aparência → light theme only (dark/system locked); Horários → locked screen with upgrade CTA; Perfis → rename allowed, add/delete blocked. NavBar usage ticker also accrues to `FreemiumService` when free plan active; `_checkParentalLimits` checks freemium daily limit separately, shows distinct overlay with upgrade CTA when 1h reached. Security: `environment.json` gitignored + removed from git tracking (`git rm --cached`); Brevo key never in client. Debug panel in Configurações (`kDebugMode` only, tree-shaken in release): bypass premium toggle (`SubscriptionService.debugToggleBypass`) + reset freemium state (`FreemiumService.reset()`). **Repo version: `1.0.40+40`.**

**PT-BR:** Modelo de 3 tiers implementado: **Gratuito** (1h/dia, vitalício, email obrigatório) / **Mensal** / **Anual**. `FreemiumService` singleton — rastreia enroll e uso diário separado do `ParentalService`. Email via bottom sheet `FreePlanEmailSheet` (consentimento LGPD + Brevo). Chave Brevo fica só no servidor: Edge Function Supabase `register-free-plan` recebe o email e chama a API Brevo com secrets `BREVO_API_KEY` / `BREVO_LIST_ID`. Gate pós-onboarding: sem plano → paywall com `isGate: true` (sem back button; router redireciona ao enroll/compra). Bloqueios free: Favoritos e Histórico → `PremiumGateScreen`; Aparência → somente tema claro; Horários → tela bloqueada com CTA; Perfis → renomear liberado, add/delete bloqueado. NavBar ticker também credita minutos no `FreemiumService` quando plano free ativo; overlay distinto ao atingir 1h com CTA de upgrade. Segurança: `environment.json` no .gitignore e removido do rastreamento git; chave Brevo nunca no cliente. Painel debug em Ajustes (somente `kDebugMode`, removido em release): bypass premium + reset freemium. **Versão no repo: `1.0.40+40`.**

## Play policy / reprovação recente (contexto operacional)

**EN:** On **2026-03-02**, Google Play flagged the app under **Families Policy Requirements: WebViews**. The stated issue is that apps that **primarily aggregate content that does not belong to the developer** are not allowed in this configuration. Play’s remediation guidance is: remove violating presentation; provide **proof of ownership** (official branding + professional support contact); and/or add **substantial first-party product value** beyond a thin third‑party video wrapper. This must stay aligned with store listing claims and the actual child-facing UX (no open web; curated catalog; minimal player chrome). Canonical capture: `docs/ai-context/decisions-log.md` (2026-03-02 entry).

**PT-BR:** Em **2026-03-02**, a Google Play sinalizou o app por **Requisitos da Política para famílias: WebViews**. O texto do problema indica que **não são permitidos apps que coletam principalmente conteúdo que não pertence ao desenvolvedor**. A orientação de correção inclui remover o conteúdo violador; apresentar **prova de titularidade** (marca/logo oficiais + contato profissional); e/ou acrescentar **valor de produto** para não ser apenas um invólucro de consumo de vídeo de terceiros. Isso precisa permanecer coerente com a ficha da loja e com a UX real para crianças (sem web aberta; catálogo curador; player enxuto). Registro canônico: `docs/ai-context/decisions-log.md` (entrada 2026-03-02).

**Still tracked as follow-up (not blocking the Phase 1 milestone label):** SQLite legacy modules remain in the repo (bootstrap removed from `main.dart`); GitHub Actions in `deploy_android.yml` still use version tags instead of SHA pins; automated tests remain thin; consider versioning Supabase RLS policies in SQL migrations when convenient.

**Ainda em acompanhamento (não bloqueia o rótulo de Fase 1):** módulos legados SQLite continuam no repositório (bootstrap removido do `main.dart`); o workflow `deploy_android.yml` ainda usa tags de versão nas actions em vez de pin por SHA; testes automatizados seguem ralos; vale versionar políticas RLS do Supabase em migrações SQL quando couber.

## Device QA / QA em dispositivo

**EN:** Primary manual device QA is on **Android** from the main Windows dev machine (`flutter run` is enough on USB). **iOS** builds and running on a **physical iPhone** require **macOS**, **Xcode**, and Apple code signing; they are **not** available from Windows only. iPhone tests are done on a **Mac mini** when that machine is in use; same project, `flutter run` with the iOS device selected on the Mac.

**PT-BR:** O QA manual principal no aparelho é no **Android** a partir do Windows (basta `flutter run` com USB). **iOS** (compilar e rodar no **iPhone** físico) exige **macOS**, **Xcode** e assinatura Apple; **não dá** para fazer isso só no Windows. Testes no iPhone ficam para o **Mac mini** quando essa máquina estiver em uso; é o mesmo projeto, no Mac: `flutter run` com o dispositivo iOS escolhido.

## Snapshot Matrix / Matriz de Snapshot

| Area | Status | Notes |
|---|---|---|
| Supabase in feed/player | Stable | Catalog/reads; **no mandatory Auth** in app shell (2026-04-29); operator sign-off for Phase 1 |
| SQLite legacy removal | Partial | No SQLite bootstrap on startup; legacy `lib/backend/sqlite` and references remain — cleanup backlog |
| Parental PIN + onboarding | Implemented (basic) | Works; advanced controls remain Phase 3 |
| Player hardening | Stable for Phase 1 | Restrictions in place; periodic policy re-check on store updates; **Families/WebViews policy rejection (2026-03-02)** must stay mitigated via curation story + no open web + evidence pack |
| Video navigation from list | Fixed | Player state keyed by video id; device QA as needed per release |
| Video back navigation | Fixed | safePop + fullscreen overlay reset |
| RevenueCat monetization | **In progress** | SDK + entitlement gate + paywall (`DulangPremiumWidget`, CTA fixo) + **Gerenciar assinatura** (`DulangSubscriptionManageWidget`, `CustomerInfo.managementURL` → loja) + UX de gestão revisada; trial Play por plano criado; falta QA de cancelamento/mudança de plano + confirmação sandbox estável em todas as contas de teste; iOS key + QA iPhone ainda em aberto |
| Channel sync automation | Stable for Phase 1 | Daily Edge path + contract; operator confirms prod/cron |
| Home channel grid visuals | Done | Thumbnail from most recent active video per channel + gradient overlay (`dulang_widget`) |
| Child profiles UX | Done | Single screen “Quem está assistindo?”: select + add + rename/delete via menu; legacy `/perfisGerenciar` opens same screen |
| Settings polish | Done | Ajustes: item **Dulang Premium** / **Gerenciar assinatura** conforme entitlement; tela de gestão com link nativo da loja; alterar PIN parental enxuto + link de ajuda; Aparência: seleção de tema alinhada ao `themePreference` do `MyApp` |
| Parent value features | Pending | Time control, schedule, history, profiles (Phase 3) |
| Tests and reliability | Low coverage | Expand before high-risk releases |
| Security posture | Improving | Keys/PIN/release hardening; version RLS in repo + SHA-pin CI when scheduled |

## EN

### Implemented or partially implemented

- Supabase is already used in primary feed and video flows.
- App bootstrap no longer initializes `SQLiteManager`; runtime startup is now aligned with Supabase-first flow.
- Basic parental flow exists: first-run onboarding and 4-digit PIN.
- Institutional pages exist (about/contact/terms).
- YouTube player has key restrictions (controls minimized and related behavior constrained).
- Video screen navigation hardened: route rebuilds player state per selected video id and player reacts to url changes.
- Video screen exit hardened: back navigation uses GoRouter safe pop and clears YouTube fullscreen overlay state to prevent a blank home screen.
- Catalog fetch now uses timeout + retry and Home has explicit recovery states (error retry and empty-catalog refresh).
- Daily sync contract defined in repo (`supabase_daily_sync_contract.sql`) with inactivation + TTL cleanup model.
- Home **Channels** grid: background thumbnail from the newest active video per channel (`published_at`) with gradient overlay for readability (`dulang_widget`).
- **Phase 2 (2026-04-28 → 2026-04-29):** RevenueCat `SubscriptionService` + `Purchases.configure` / `CustomerInfo` / purchase + restore; entitlement **`dulang_premium_entitlement`** gates playback and listas premium; `DulangPremiumWidget` two-plan paywall (store prices); `REVENUECAT_*` and `YOUTUBE_API_KEY` support `--dart-define` (see `environment_values.dart`). **2026-04-29:** removed mandatory **Supabase Auth** / `/login` route and router redirect; removed **sign-out** tile; RC no longer `logIn` with Supabase user id.
- **UX assinatura (2026-04-27 → 2026-04-30):** sem entitlement ativo, toque em conteúdo premium abre **direto a paywall** (`PremiumPaywallRedirectScaffold`); com entitlement, **Ajustes** abre **Gerenciar assinatura** (`DulangSubscriptionManageWidget`: plano atual + **Abrir na loja** via `managementURL` do RevenueCat). Paywall com **rodapé fixo** (CTA sempre visível); sem override de Premium em debug. **Aparência:** tema usa `MyApp.themePreference` (evita dessincronia com `SharedPreferences`). **Alterar PIN:** fluxo curto + `DeviceAuthHelp`; teclado PIN com debounce + `InkWell` para feedback visual. Ops: [`PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`](../PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md).

### Priority gaps

- **Phase 2 (operations):** finish RevenueCat + store product setup, default offering (monthly + annual packages), iOS public SDK key, then validate trial → paid → restore on real devices; unblock/verify **Internal testing** install for all QA Google accounts (see [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](../CHECKLIST_TESTE_SANDBOX_PLAY.md)).
- **Phase 2 (product follow-up):** social login (Google / Apple) if replacing email-only — not implemented yet.
- Advanced parental features are pending:
  - Screen-time limits
  - Time-window access control
  - Robust parent history
  - Child profiles

### Technical debt and risks

- Legacy FlutterFlow/SQLite code still coexists with Supabase migration path.
- Project structure diverges from desired feature-based architecture.
- README is still generic and not enough for technical onboarding.
- Limited test coverage.

### Security posture

- `YOUTUBE_API_KEY` was removed from versioned client asset and is now injected by `dart-define`; provider-side restrictions are still pending.
- Supabase RLS/policy definitions are not clearly versioned in repository migrations.
- Parental PIN storage migrated to secure storage with hashed verification (legacy plaintext migration included).
- Android release hardening is enabled (`minify`, `shrink`, CI obfuscation).
- CI workflow still needs stronger supply-chain hardening (actions pinned by SHA).

### Suggested next execution steps

1. **RevenueCat + stores:** wire products and default offering; confirm entitlement id `dulang_premium_entitlement`; run purchase/restore QA on Android and iOS.
2. **Supabase Auth (optional):** only if you add cloud accounts later; not required for catalog + billing flow above.
3. Remove dead SQLite imports/paths after grep-based audit (bootstrap already removed).
4. Optionally pin GitHub Actions by SHA in `deploy_android.yml`.
5. Add a small automated test set around parental gate and catalog read boundaries.

## PT-BR

### Implementado ou parcialmente implementado

- Supabase ja esta em uso no feed principal e fluxo de video.
- Bootstrap do app nao inicializa mais `SQLiteManager`; startup em runtime agora segue fluxo Supabase-first.
- Fluxo parental basico existe: onboarding de primeira abertura e PIN de 4 digitos.
- Telas institucionais existem (sobre/contato/termos).
- Player do YouTube com restricoes importantes (controles reduzidos e relacionados limitados).
- Navegacao na tela de video endurecida: a rota recria o estado do player por id do video e o player reage a mudancas de `url`.
- Saida da tela de video endurecida: voltar usa safe pop do GoRouter e limpa overlay de fullscreen do YouTube para evitar tela inicial em branco.
- Busca de catalogo agora usa timeout + retry e a Home tem estados de recuperacao explicitos (erro com tentativa novamente e refresh para catalogo vazio).
- Contrato de sync diario definido no repositorio (`supabase_daily_sync_contract.sql`) com modelo de inativacao + limpeza por TTL.
- Grade **Canais** na Home: fundo com thumbnail do video ativo **mais recente** por canal (`published_at`), gradiente + texto legivel.
- **Fase 2 (2026-04-28 → 2026-04-29):** `SubscriptionService` (RevenueCat) com entitlement **`dulang_premium_entitlement`** e compra/restaurar; paywall em Flutter em `DulangPremiumWidget` (mensal/anual); **paywall direta** em toques premium e bloqueio em vídeo/canal; `--dart-define` para `REVENUECAT_*` e `YOUTUBE_API_KEY` em `environment_values.dart`. **2026-04-29:** removidos login obrigatório, rota `/login` e redirect no GoRouter; removido bloco “Sair da conta”; RevenueCat sem `logIn` com id do Supabase.
- **UX (2026-04-29 → 2026-04-30):** perfis na tela **Quem está assistindo?** (menu ⋮ renomear/excluir); **Gerenciar perfis** removida; paywall/gestão de assinatura conforme acima; **Alterar PIN parental** com `local_auth` e tela de ajuda; guia leigo [`PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`](../PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md).

### Gaps prioritarios

- **Fase 2 (operacao):** fechar produtos nas lojas + RevenueCat (oferta padrão, trial 7 dias, preço anual = 10 mensais), chave pública iOS, QA de compra/restauração/cancelamento/mudanca de plano em aparelho; desbloquear/validar instalacao do **Teste interno** para todas as contas Google de QA (ver [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](../CHECKLIST_TESTE_SANDBOX_PLAY.md)).
- **Fase 2 (produto depois):** login social (Google/Apple), se quiser sair só de e-mail — ainda nao implementado.
- Features parentais avancadas pendentes:
  - Limite de tempo de tela
  - Controle de horarios
  - Historico robusto para os pais
  - Perfis de crianca

### Dividas tecnicas e riscos

- Legado FlutterFlow/SQLite ainda convive com a migracao para Supabase.
- Estrutura atual diverge da arquitetura alvo baseada em features.
- README ainda generico e insuficiente para onboarding tecnico.
- Cobertura de testes limitada.

### Postura de seguranca

- `YOUTUBE_API_KEY` foi removida do asset versionado e agora entra via `dart-define`; ainda faltam restricoes no provedor.
- Definicoes de RLS/policies do Supabase nao estao claramente versionadas no repositorio.
- PIN parental migrou para storage seguro com validacao por hash (com migracao do legado).
- Hardening de release Android esta ativo (`minify`, `shrink`, ofuscacao no CI).
- Workflow de CI ainda precisa de hardening de supply chain (actions pinadas por SHA).
