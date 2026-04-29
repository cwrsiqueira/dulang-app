# AI Context Hub (Single Source of Truth)

This folder is the canonical context for the Dulang project across tools, machines, and AI assistants.

**Milestone (2026-04-27):** Phase 1 closed by operator sign-off. **Update (2026-04-28):** Phase 2 **app integration** (RevenueCat SDK, Flutter paywall with sticky CTA, direct paywall on premium taps, **Gerenciar assinatura** via store `managementURL`, entitlement gating, **no mandatory login**; parental PIN change via **device biometrics/PIN**) is in the repo; **manage subscription UX** refined; **Android root back** legacy PIN snackbar removed from main shell; **Play sandbox checklist** added at [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](../CHECKLIST_TESTE_SANDBOX_PLAY.md); **store/RevenueCat dashboard + device QA** (cancel/change plan + sandbox on all QA accounts) still open — see `current-status.md`.

## How to use

For any Portuguese aimed at humans or assistant replies in Portuguese, use **Brazilian Portuguese (pt-BR)** only—not European Portuguese (avoid *ficheiros*, *telemóvel*, *ecrã*—use *arquivo(s)*, *celular*, *tela*). Same rule in **`developer-profile.md`**, **`engineering-rules.md`**, and **always-applied Cursor rules**: `.cursor/rules/portugues-brasil.mdc`.

1. Read this file first.
2. Read `project-overview.md` for product and mission.
3. Read `current-status.md` for implementation snapshot.
4. Read `roadmap-priorities.md` for execution order.
5. Read `engineering-rules.md` for technical and safety constraints.
6. Read `developer-profile.md` for working style and constraints.
7. Read `decisions-log.md` for stable decisions and rationale.
8. Read `security-checklist.md`, `security-strategy.md`, and `security-incidents.md`.
9. Read `.cursor/rules/portugues-brasil.mdc` for assistant language enforcement (pt-BR only).

## Como usar (PT-BR)

Texto em português para pessoas e respostas de assistente: use **somente pt-BR** (não pt-PT; ex.: **arquivo(s)**, não *ficheiro(s)*). Detalhes em `developer-profile.md`, `engineering-rules.md` e `.cursor/rules/portugues-brasil.mdc` (**rules**, não só guideline).

**Marco (2026-04-27):** Fase 1 encerrada por aceite do operador. **Atualização (2026-04-28):** **integração da Fase 2 no app** (SDK RevenueCat, paywall Flutter com CTA fixo, paywall direta em toques premium, **Gerenciar assinatura** com link da loja via `managementURL`, bloqueio por entitlement, **sem login obrigatório**; troca de PIN parental com **biometria/PIN do aparelho**); **UX de Gerenciar assinatura** revisada; **voltar (Android) na casca principal** sem banner legado de PIN; **checklist sandbox Play** em [`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`](../CHECKLIST_TESTE_SANDBOX_PLAY.md); **lojas/RevenueCat + QA em aparelho** (cancelar/mudar plano + sandbox em todas as contas de QA) ainda em aberto — veja `current-status.md`.

1. Comece por este arquivo.
2. Leia `project-overview.md` para produto e missão.
3. Leia `current-status.md` para snapshot de implementação.
4. Leia `roadmap-priorities.md` para ordem de execução.
5. Leia `engineering-rules.md` para regras técnicas e de segurança.
6. Leia `developer-profile.md` para perfil e modo de trabalho.
7. Leia `decisions-log.md` para decisões e justificativas.
8. Leia `security-checklist.md`, `security-strategy.md` e `security-incidents.md`.
9. Leia `.cursor/rules/portugues-brasil.mdc` para reforço de idioma do assistente (somente pt-BR).

## Session Aliases / Aliases de Sessao

- `CTX-UPDATE-ALL`: global alias for complete context update.
- `Atualizar todo o contexto`: natural-language synonym of `CTX-UPDATE-ALL`.
- `CTX-HUB`: this file (`README.md`).
- `CTX-OVERVIEW`: `project-overview.md`.
- `CTX-STATUS`: `current-status.md`.
- `CTX-ROADMAP`: `roadmap-priorities.md`.
- `CTX-RULES`: `engineering-rules.md`.
- `CTX-PROFILE`: `developer-profile.md`.
- `CTX-DECISIONS`: `decisions-log.md`.
- `SEC-CHECKLIST`: `security-checklist.md`.
- `SEC-STRATEGY`: `security-strategy.md`.
- `SEC-INCIDENTS`: `security-incidents.md`.

## CTX-UPDATE-ALL Protocol

When `CTX-UPDATE-ALL` (or `Atualizar todo o contexto`) is requested:

1. Identify all session impacts (product, architecture, backlog, process, compliance, security).
2. Update every impacted context file without requiring explicit file listing.
3. Always include security updates when there is technical/data/CI-CD/release/policy impact.
4. Append relevant decisions to `decisions-log.md`.
5. Append incidents or near misses to `security-incidents.md` when applicable.

## Maintenance checklist

- Update `current-status.md` at every meaningful feature delivery.
- Append important decisions to `decisions-log.md`.
- Keep `roadmap-priorities.md` aligned with business and store review priorities.
- Keep security docs updated with each architecture or deployment change.
- Keep this folder tool-agnostic; adapters in other files must only point here.

## Complementary context (outside the canonical sequence)

These files can add useful operational context, but they do **not** replace the canonical source in `docs/ai-context/`:

- `PLAYSTORE_CONTEXT.md`: store-facing notes and compliance support context.
- `.cursor/rules/ai-context.mdc`: adapter rule that points assistants to this hub.
- `.cursor/rules/portugues-brasil.mdc`: language enforcement for assistant replies in Portuguese (pt-BR only).
- `.claude/settings.local.json`: local tool configuration; treat as environment-specific, not canonical project context.
- `docs/ai-context/channel-sync-operational.md`: operational spec for daily channel-to-video sync.
- `docs/PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`: step-by-step for non-developers (stores, subscription service, account) to finish Phase 2 outside code.

## Checklist de manutenção (PT-BR)

- Atualizar `current-status.md` a cada entrega relevante.
- Registrar decisões importantes em `decisions-log.md`.
- Manter `roadmap-priorities.md` alinhado com negócio e aprovação da loja.
- Manter os docs de seguranca atualizados em mudancas de arquitetura e deploy.
- Manter esta pasta neutra para ferramentas; adaptadores externos só apontam para cá.

## Contexto complementar (fora da sequência canônica)

Estes arquivos podem acrescentar contexto operacional, mas **não** substituem a fonte canônica em `docs/ai-context/`:

- `PLAYSTORE_CONTEXT.md`: notas voltadas para loja e apoio de compliance.
- `.cursor/rules/ai-context.mdc`: regra adaptadora que aponta assistentes para este hub.
- `.cursor/rules/portugues-brasil.mdc`: reforço de idioma para respostas em português (somente pt-BR).
- `.claude/settings.local.json`: configuração local de ferramenta; trate como algo de ambiente, não como contexto canônico do projeto.
- `docs/ai-context/channel-sync-operational.md`: especificação operacional do sync diário de canais para vídeos.
- `docs/PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`: passo a passo para leigos (lojas, assinatura, conta) para fechar a Fase 2 fora do código.
