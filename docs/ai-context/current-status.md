# Current Status / Status Atual

Last updated: 2026-04-27

## Phase 1 closure / Encerramento da Fase 1

**EN:** Phase 1 (store readiness + compliance baseline) is **closed by operator sign-off on 2026-04-27**: production channel sync, Supabase access posture, and player compliance checks are treated as **done** for this milestone. **Next engineering focus:** Phase 2 — RevenueCat (configuration and end-to-end subscription flow), starting next session.

**PT-BR:** A **Fase 1** (baseline de loja + compliance) foi **encerrada com aceite do operador em 2026-04-27**: sync de canais em produção, postura de acesso no Supabase e validações do player consideradas **feitas** para este marco. **Próximo foco de engenharia:** **Fase 2 — RevenueCat** (configuração e fluxo ponta a ponta de assinatura), na próxima sessão.

**Still tracked as follow-up (not blocking the Phase 1 milestone label):** SQLite legacy modules remain in the repo (bootstrap removed from `main.dart`); GitHub Actions in `deploy_android.yml` still use version tags instead of SHA pins; automated tests remain thin; consider versioning Supabase RLS policies in SQL migrations when convenient.

**Ainda em acompanhamento (não bloqueia o rótulo de Fase 1):** módulos legados SQLite continuam no repositório (bootstrap removido do `main.dart`); o workflow `deploy_android.yml` ainda usa tags de versão nas actions em vez de pin por SHA; testes automatizados seguem ralos; vale versionar políticas RLS do Supabase em migrações SQL quando couber.

## Device QA / QA em dispositivo

**EN:** Primary manual device QA is on **Android** from the main Windows dev machine (`flutter run` is enough on USB). **iOS** builds and running on a **physical iPhone** require **macOS**, **Xcode**, and Apple code signing; they are **not** available from Windows only. iPhone tests are done on a **Mac mini** when that machine is in use; same project, `flutter run` with the iOS device selected on the Mac.

**PT-BR:** O QA manual principal no aparelho é no **Android** a partir do Windows (basta `flutter run` com USB). **iOS** (compilar e rodar no **iPhone** físico) exige **macOS**, **Xcode** e assinatura Apple; **não dá** para fazer isso só no Windows. Testes no iPhone ficam para o **Mac mini** quando essa máquina estiver em uso; é o mesmo projeto, no Mac: `flutter run` com o dispositivo iOS escolhido.

## Snapshot Matrix / Matriz de Snapshot

| Area | Status | Notes |
|---|---|---|
| Supabase in feed/player | Stable | Primary catalog and playback path; operator sign-off for Phase 1 |
| SQLite legacy removal | Partial | No SQLite bootstrap on startup; legacy `lib/backend/sqlite` and references remain — cleanup backlog |
| Parental PIN + onboarding | Implemented (basic) | Works; advanced controls remain Phase 3 |
| Player hardening | Stable for Phase 1 | Restrictions in place; periodic policy re-check on store updates |
| Video navigation from list | Fixed | Player state keyed by video id; device QA as needed per release |
| Video back navigation | Fixed | safePop + fullscreen overlay reset |
| RevenueCat monetization | **Next** | Phase 2: configure SDK, offerings, paywall, entitlement gating |
| Channel sync automation | Stable for Phase 1 | Daily Edge path + contract; operator confirms prod/cron |
| Home channel grid visuals | Done | Thumbnail from most recent active video per channel + gradient overlay (`dulang_widget`) |
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

### Priority gaps

- **Phase 2:** RevenueCat end-to-end (trial, purchase, restore, entitlement gating) — next execution block.
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

1. **RevenueCat:** dashboard + SDK wiring, offerings, paywall UX, restore purchases, gate catalog or premium rows by entitlement.
2. Remove dead SQLite imports/paths after grep-based audit (bootstrap already removed).
3. Optionally pin GitHub Actions by SHA in `deploy_android.yml`.
4. Add a small automated test set around parental gate and catalog read boundaries.

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

### Gaps prioritarios

- **Fase 2:** RevenueCat ponta a ponta (trial, compra, restaurar, bloqueio por entitlement) — proximo bloco de execucao.
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
