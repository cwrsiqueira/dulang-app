# Decisions Log / Log de Decisoes

## EN

### 2026-04-25 - Cursor as primary development environment

- Decision: use Cursor as the main day-to-day environment.
- Why: stronger integrated workflow for coding + context continuity.
- Impact: project context must be portable and tool-agnostic.

### 2026-04-25 - Single source AI context in repo

- Decision: centralize all persistent project context in `docs/ai-context/`.
- Why: avoid duplicated and divergent memory files across tools.
- Impact: assistant-specific files should be thin pointers only.

### Historic technical decisions (carried from prior context)

- Use Supabase to replace static local SQLite for dynamic content updates.
- Use RevenueCat for subscription management and trial handling.
- Keep app safe for children, with strict parental and policy constraints.

## PT-BR

### 2026-04-25 - Cursor como ambiente principal

- Decisao: usar o Cursor como ambiente principal no dia a dia.
- Motivo: fluxo integrado mais forte para codigo + continuidade de contexto.
- Impacto: contexto do projeto precisa ser portatil e neutro para ferramentas.

### 2026-04-25 - Fonte unica de contexto de IA no repo

- Decisao: centralizar o contexto persistente em `docs/ai-context/`.
- Motivo: evitar memoria duplicada e divergente entre ferramentas.
- Impacto: arquivos especificos de assistente devem ser apenas ponteiros.

### Decisoes tecnicas historicas (herdadas do contexto anterior)

- Usar Supabase para substituir SQLite local estatico e permitir atualizacao dinamica.
- Usar RevenueCat para assinaturas e trial.
- Manter app seguro para criancas, com restricoes parentais e de politica.
