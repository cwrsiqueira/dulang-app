# Current Status / Status Atual

Last updated: 2026-04-25

## Snapshot Matrix / Matriz de Snapshot

| Area | Status | Notes |
|---|---|---|
| Supabase in feed/player | Partial to stable | Main consumption flow migrated, cleanup still pending |
| SQLite legacy removal | Pending | Legacy modules still present |
| Parental PIN + onboarding | Implemented (basic) | Works, but advanced controls are pending |
| Player hardening | Partial | Important restrictions exist; keep validating policy details |
| RevenueCat monetization | Pending | Dependency present, end-to-end flow missing |
| Channel sync automation | Pending | Needs backend/app operational closure |
| Parent value features | Pending | Time control, schedule, history, profiles |
| Tests and reliability | Low coverage | Expand before high-risk releases |
| Security posture | Needs hardening | Secrets governance, RLS versioning, mobile hardening, CI least privilege |

## EN

### Implemented or partially implemented

- Supabase is already used in primary feed and video flows.
- Basic parental flow exists: first-run onboarding and 4-digit PIN.
- Institutional pages exist (about/contact/terms).
- YouTube player has key restrictions (controls minimized and related behavior constrained).

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

- `YOUTUBE_API_KEY` currently exposed in versioned client asset and needs rotation/restrictions.
- Supabase RLS/policy definitions are not clearly versioned in repository migrations.
- Parental PIN is stored in plain local storage and should move to secure storage + hash model.
- Android release hardening flags are not fully enabled.
- CI workflow still needs explicit least-privilege permissions and stronger supply-chain hardening.

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

- `YOUTUBE_API_KEY` esta exposta em asset versionado do cliente e precisa de rotacao/restricoes.
- Definicoes de RLS/policies do Supabase nao estao claramente versionadas no repositorio.
- PIN parental esta em storage local simples e deve migrar para storage seguro + hash.
- Flags de hardening de release Android ainda nao estao totalmente ativas.
- Workflow de CI ainda precisa de menor privilegio explicito e hardening de supply chain.
