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

### 2026-04-25 - Harden parental PIN and Android release build

- Decision: store parental PIN in secure storage with hashed verification and enable Android release hardening flags.
- Why: reduce plaintext secret exposure on device and make reverse engineering harder in production.
- Impact: onboarding/verification uses secure PIN migration path; release builds use minification, resource shrinking, and obfuscation in CI.

### 2026-04-25 - Fix video switching on same GoRouter route

- Decision: key `DulangVideoWidget` by selected video id and reload YouTube player when `url` changes.
- Why: GoRouter can reuse `State` across navigations to the same route with different query params, leaving the old player controller attached.
- Impact: reliable multi-tap navigation from the list under the player; reduces black-screen risk when popping back.

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

### 2026-04-25 - Endurecer PIN parental e build de release Android

- Decisao: armazenar PIN parental em storage seguro com validacao por hash e ativar hardening no release Android.
- Motivo: reduzir exposicao de segredo em texto puro no dispositivo e dificultar engenharia reversa em producao.
- Impacto: onboarding/validacao usa migracao segura de PIN; builds de release usam minificacao, shrink e ofuscacao no CI.

### 2026-04-25 - Corrigir troca de video na mesma rota do GoRouter

- Decisao: usar `Key` no `DulangVideoWidget` baseada no id do video e recarregar o player quando `url` mudar.
- Motivo: o GoRouter pode reutilizar `State` na mesma rota com query params diferentes, mantendo controller antigo do YouTube.
- Impacto: navegacao confiavel com multiplos toques na lista sob o player; reduz risco de tela preta ao voltar.

### Decisoes tecnicas historicas (herdadas do contexto anterior)

- Usar Supabase para substituir SQLite local estatico e permitir atualizacao dinamica.
- Usar RevenueCat para assinaturas e trial.
- Manter app seguro para criancas, com restricoes parentais e de politica.
