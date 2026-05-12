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

**Status 2026-05-01:** items 1–5 implemented and QA-approved on Android (physical device, both freemium and premium flows). Three-tier model: **Free** (1h/day, email capture → Brevo via Supabase Edge Function `register-free-plan`; gates Favorites, History, multi-profile add/delete, dark themes, custom time controls) / **Monthly** / **Annual**. Router gate post-onboarding: no plan → paywall with `isGate: true` (no back button). `FreemiumService` singleton tracks daily usage independently from `ParentalService`. `environment.json` removed from git tracking (now gitignored); Brevo API key stays server-side only. Debug panel in Configurações (kDebugMode only): bypass premium + reset freemium state. **Status 2026-05-02:** app submitted to Play Store production review (version 1.0.43+43). Reviewer access via freemium plan — instructions submitted to Play Console ("Free Plan Access — No Login Required"). **Status 2026-05-07:** paywall purchase hardening + RC `$rc_*` mapping notes in `docs/ai-context/`; **`1.0.44+44`** pushed to `master` → GitHub Actions Android deploy (internal test track). **Billing QA:** validate purchases on **Play-installed** builds; `flutter run` alone is insufficient. **Status 2026-05-12 (TestFlight iOS, operator):** **Annual** IAP path validated; **crash** on background→foreground (frequent; **not reproduced on Android** so far) — **P0**; see numbered crash steps in `current-status.md`. **Update 2026-05-13:** **Monthly** paywall CTA disabled is **not a code bug** — App Store Connect currently has **annual-only** subscription per first-submission operator practice; add monthly product in ASC/RC after approval. Coupon + manage-subscription states OK; schedule gate smoke OK.

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

**Status em 2026-05-02:** app enviado para revisão de produção na Play Store (versão 1.0.43+43). Acesso do revisor via plano freemium — instruções submetidas no Play Console ("Free Plan Access — No Login Required", email `review@dulang.com`). **Status em 2026-05-07:** endurecimento da compra na paywall + notas de mapeamento **`$rc_*`** no RC em `docs/ai-context/`; **`1.0.44+44`** em `master` dispara deploy Android no CI (teste interno). **QA de billing:** testar compra com app **instalado pela Play**; só `flutter run` não basta. **Próximo:** App Store (iOS) conforme prioridade do operador. **Status em 2026-05-12 (TestFlight iOS, operador):** fluxo **anual** validado; **crash** frequente ao retomar do segundo plano (**P0**; **não percebido no Android** na mesma repro) — ver passos em `current-status.md`. **Atualização 2026-05-13:** botão **mensal** desabilitado **não é bug** — na ASC só existe assinatura **anual** no primeiro envio (operador segue orientação de **uma** assinatura primeiro; **mensal** depois da aprovação). Cupom + **Gerenciar assinatura** + horário: OK no smoke.

### Fase 3 - Features de valor para os pais

1. Controle de tempo de tela.
2. Controle por janelas de horario.
3. Painel de historico para os pais.
4. Perfis multiplos de crianca.
