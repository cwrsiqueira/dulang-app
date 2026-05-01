# Roadmap Priorities / Prioridades do Roadmap

## EN

### Phase 1 - Store approval and compliance — **closed 2026-04-27** (operator sign-off)

Baseline delivered: parental PIN/onboarding, player isolation work, Supabase-first catalog, daily channel sync path in production (per operator), compliance surface acceptable for milestone. Residual: SQLite files in repo (no startup init), CI SHA pins optional, thin tests.

### Phase 2 - Monetization (**current focus**)

1. Integrate RevenueCat subscriptions and trial.
2. Gate content by active entitlement.
3. Build parent-focused paywall narrative.
4. Subscriber path to **store subscription management** (`managementURL` / native screens), not the acquisition paywall.
5. **Freemium plan (1h/day, lifetime, email required)** — resolves Play reviewer access without backdoor.

**Status 2026-04-30:** items 1–5 implemented in app code. Three-tier model: **Free** (1h/day, email capture → Brevo via Supabase Edge Function `register-free-plan`; gates Favorites, History, multi-profile add/delete, dark themes, custom time controls) / **Monthly** / **Annual**. Router gate post-onboarding: no plan → paywall with `isGate: true` (no back button). `FreemiumService` singleton tracks daily usage independently from `ParentalService`. `environment.json` removed from git tracking (now gitignored); Brevo API key stays server-side only. Debug panel in Configurações (kDebugMode only): bypass premium + reset freemium state. **Pending: device QA of full freemium + premium flows with debug panel.**

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
5. **Plano freemium (1h/dia, vitalício, email obrigatório)** — resolve acesso do revisor da Play sem backdoor.

**Status em 2026-04-30:** itens 1 a 5 implementados no app. Modelo de 3 tiers: **Gratuito** (1h/dia, captura de email → Brevo via Edge Function Supabase `register-free-plan`; bloqueia Favoritos, Histórico, add/delete de perfis, temas escuro/sistema, controles de horário) / **Mensal** / **Anual**. Gate de rota pós-onboarding: sem plano → paywall com `isGate: true` (sem botão voltar). `FreemiumService` rastreia uso diário separado do `ParentalService`. `environment.json` removido do rastreamento git (agora no .gitignore); chave Brevo fica só no servidor. Painel debug em Ajustes (somente `kDebugMode`): bypass premium + reset freemium. **Pendente: QA em aparelho dos fluxos freemium e premium com o painel debug.**

### Fase 3 - Features de valor para os pais

1. Controle de tempo de tela.
2. Controle por janelas de horario.
3. Painel de historico para os pais.
4. Perfis multiplos de crianca.
