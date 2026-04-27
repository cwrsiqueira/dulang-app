# Roadmap Priorities / Prioridades do Roadmap

## EN

### Phase 1 - Store approval and compliance — **closed 2026-04-27** (operator sign-off)

Baseline delivered: parental PIN/onboarding, player isolation work, Supabase-first catalog, daily channel sync path in production (per operator), compliance surface acceptable for milestone. Residual: SQLite files in repo (no startup init), CI SHA pins optional, thin tests.

### Phase 2 - Monetization (**current focus**)

1. Integrate RevenueCat subscriptions and trial.
2. Gate content by active entitlement.
3. Build parent-focused paywall narrative.

**Status 2026-04-28:** items 1–3 are **implemented in app code** (custom Flutter paywall, SDK, `premium` gate); **complete store + RevenueCat dashboard wiring and real-device purchase QA** to close the phase operationally.

### Phase 3 - Parent value features

1. Screen-time controls.
2. Scheduled access windows.
3. Parent history dashboard.
4. Multi-child profiles.

## PT-BR

### Fase 1 - Aprovacao da loja e compliance — **encerrada em 2026-04-27** (aceite do operador)

Entregas: protecao parental basica, trabalho de isolamento do player, catalogo Supabase-first, sync diario canais->videos em producao (conforme operador), superficie de compliance suficiente para o marco. Residual: arquivos SQLite no repo (sem init no startup), pin SHA no CI opcional, poucos testes.

### Fase 2 - Monetizacao (**foco atual**)

1. Integrar assinatura e trial com RevenueCat.
2. Bloquear conteudo por entitlement ativo.
3. Construir narrativa de paywall orientada a pais.

**Status em 2026-04-28:** itens 1 a 3 **no código do app** (paywall Flutter, SDK, bloqueio `premium`); falta **fechar lojas + painel RevenueCat e validar compra/restauração em aparelho real** para encerrar a fase na operação.

### Fase 3 - Features de valor para os pais

1. Controle de tempo de tela.
2. Controle por janelas de horario.
3. Painel de historico para os pais.
4. Perfis multiplos de crianca.
