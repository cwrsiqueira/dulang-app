# Roadmap Priorities / Prioridades do Roadmap

## EN

### Phase 1 - Store approval and compliance — **closed 2026-04-27** (operator sign-off)

Baseline delivered: parental PIN/onboarding, player isolation work, Supabase-first catalog, daily channel sync path in production (per operator), compliance surface acceptable for milestone. Residual: SQLite files in repo (no startup init), CI SHA pins optional, thin tests.

### Phase 2 - Monetization (**current focus**)

1. Integrate RevenueCat subscriptions and trial.
2. Gate content by active entitlement.
3. Build parent-focused paywall narrative.
4. Subscriber path to **store subscription management** (`managementURL` / native screens), not the acquisition paywall.

**Status 2026-04-28:** items 1–4 are **implemented in app code** (custom Flutter paywall with sticky CTA, SDK, entitlement `dulang_premium_entitlement` gate, `DulangSubscriptionManageWidget`); **complete store + RevenueCat dashboard wiring and real-device purchase QA** to close the phase operationally. Use [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](../CHECKLIST_TESTE_SANDBOX_PLAY.md) before validating purchase/cancel/restore on Android. **Operator note:** Internal testing opt-in can show **Play Store “Item not found”** for some Google accounts even when the release is **Available to testers** — keep primary QA on a known-good account until Play-side propagation/eligibility stabilizes.

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
4. Caminho do assinante para **gestão na loja** (`managementURL` / telas nativas), sem reexibir a paywall de aquisição.

**Status em 2026-04-28:** itens 1 a 4 **no código do app** (paywall Flutter com CTA fixo, SDK, bloqueio por entitlement `dulang_premium_entitlement`, tela **Gerenciar assinatura**); falta **fechar lojas + painel RevenueCat e validar compra/restauração/cancelamento/mudança de plano em aparelho real** para encerrar a fase na operação. Use [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](../CHECKLIST_TESTE_SANDBOX_PLAY.md) antes de validar compra/cancelamento/restauração no Android. **Nota de operação:** o opt-in do **Teste interno** pode cair em **“Item not found”** na Play Store para algumas contas Google mesmo com release **Disponível para testers** — manter QA principal numa conta que já instala até a Play estabilizar propagação/elegibilidade.

### Fase 3 - Features de valor para os pais

1. Controle de tempo de tela.
2. Controle por janelas de horario.
3. Painel de historico para os pais.
4. Perfis multiplos de crianca.
