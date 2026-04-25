# Current Status / Status Atual

Last updated: 2026-04-25

## Snapshot Matrix / Matriz de Snapshot

| Area | Status | Notes |
|---|---|---|
| Supabase in feed/player | Partial to stable | Main consumption flow migrated, cleanup still pending |
| SQLite legacy removal | Pending | Legacy modules still present |
| Parental PIN + onboarding | Implemented (basic) | Works, but advanced controls are pending |
| Player hardening | Partial | Important restrictions exist; keep validating policy details |
| Video navigation from list | Fixed (needs device QA) | Second tap on same route now recreates player state; list fetch memoized per screen |
| Video back navigation | Fixed (needs device QA) | Use GoRouter safePop and reset fullscreen wrapper overlay to avoid black screen returning home |
| RevenueCat monetization | Pending | Dependency present, end-to-end flow missing |
| Channel sync automation | Pending | Needs backend/app operational closure |
| Parent value features | Pending | Time control, schedule, history, profiles |
| Tests and reliability | Low coverage | Expand before high-risk releases |
| Security posture | Improving | Key handling improved, PIN storage hardened, release hardening enabled; RLS and SHA-pinned actions still pending |

## EN

### Implemented or partially implemented

- Supabase is already used in primary feed and video flows.
- Basic parental flow exists: first-run onboarding and 4-digit PIN.
- Institutional pages exist (about/contact/terms).
- YouTube player has key restrictions (controls minimized and related behavior constrained).
- Video screen navigation hardened: route rebuilds player state per selected video id and player reacts to url changes.
- Video screen exit hardened: back navigation uses GoRouter safe pop and clears YouTube fullscreen overlay state to prevent a blank home screen.

### Priority gaps

- RevenueCat end-to-end not completed (trial, purchase, restore, entitlement gating).
- Automated channel sync via YouTube Data API is not fully operational in app flow.
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

1. Define and ship RevenueCat core flow (trial, purchase, restore, gating).
2. Lock player compliance behavior and run targeted policy checklist.
3. Remove dead SQLite paths after confirming no active dependency remains.
4. Finalize channel sync pipeline (source, cadence, failure handling).
5. Add tests around parental gate and content access boundaries.

## PT-BR

### Implementado ou parcialmente implementado

- Supabase ja esta em uso no feed principal e fluxo de video.
- Fluxo parental basico existe: onboarding de primeira abertura e PIN de 4 digitos.
- Telas institucionais existem (sobre/contato/termos).
- Player do YouTube com restricoes importantes (controles reduzidos e relacionados limitados).
- Navegacao na tela de video endurecida: a rota recria o estado do player por id do video e o player reage a mudancas de `url`.
- Saida da tela de video endurecida: voltar usa safe pop do GoRouter e limpa overlay de fullscreen do YouTube para evitar tela inicial em branco.

### Gaps prioritarios

- RevenueCat ponta a ponta ainda incompleto (trial, compra, restaurar, bloqueio por entitlement).
- Sincronizacao automatica por canal via YouTube Data API ainda nao esta fechada no fluxo do app.
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
