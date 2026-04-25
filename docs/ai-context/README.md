# AI Context Hub (Single Source of Truth)

This folder is the canonical context for the Dulang project across tools, machines, and AI assistants.

## How to use

1. Read this file first.
2. Read `project-overview.md` for product and mission.
3. Read `current-status.md` for implementation snapshot.
4. Read `roadmap-priorities.md` for execution order.
5. Read `engineering-rules.md` for technical and safety constraints.
6. Read `developer-profile.md` for working style and constraints.
7. Read `decisions-log.md` for stable decisions and rationale.
8. Read `security-checklist.md`, `security-strategy.md`, and `security-incidents.md`.

## Como usar (PT-BR)

1. Comece por este arquivo.
2. Leia `project-overview.md` para produto e missão.
3. Leia `current-status.md` para snapshot de implementação.
4. Leia `roadmap-priorities.md` para ordem de execução.
5. Leia `engineering-rules.md` para regras técnicas e de segurança.
6. Leia `developer-profile.md` para perfil e modo de trabalho.
7. Leia `decisions-log.md` para decisões e justificativas.
8. Leia `security-checklist.md`, `security-strategy.md` e `security-incidents.md`.

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

## Checklist de manutenção (PT-BR)

- Atualizar `current-status.md` a cada entrega relevante.
- Registrar decisões importantes em `decisions-log.md`.
- Manter `roadmap-priorities.md` alinhado com negócio e aprovação da loja.
- Manter os docs de seguranca atualizados em mudancas de arquitetura e deploy.
- Manter esta pasta neutra para ferramentas; adaptadores externos só apontam para cá.
