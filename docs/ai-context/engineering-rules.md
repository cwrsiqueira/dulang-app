# Engineering Rules / Regras de Engenharia

## EN

### Core stack

- Flutter + Dart
- State: Provider (legacy FlutterFlow state still present in parts)
- Navigation: go_router (plus legacy paths where still present)
- Data: Supabase (target), with SQLite legacy in transition

### Naming and structure

- File names in snake_case.
- Class names in PascalCase.
- Favor feature-based organization under `lib/features/`.
- Keep services cohesive and testable.

### Safety and product constraints

- Child-safe UX is mandatory.
- No external navigation for children without parental gate.
- Keep player surface minimal and policy-friendly.
- Do not add ad SDKs.

### Critical files (handle with care)

- `android/app/build.gradle`
- `android/key.properties` (generated in CI, do not commit)
- `.github/workflows/deploy_android.yml`
- `pubspec.yaml` (dependency overrides and release-impacting changes)

### Operational rules

- Prefer small, reviewable changes.
- Validate with analysis/tests when changing behavior.
- Avoid credential leakage in commits and logs.

### Security baseline

- Apply least privilege for CI/CD and data access.
- Keep all Supabase-exposed tables under explicit RLS policies.
- Do not store sensitive credentials or parental secrets in plain storage.
- Keep production logging minimal and sanitized.
- Keep release hardening enabled for mobile builds.
- Use `security-checklist.md` in PR/release checkpoints.
- **Portuguese copy:** all human-facing project text in Portuguese must be **Brazilian Portuguese (pt-BR)**, not European Portuguese. AI assistants must follow the same rule (also in `.cursor/rules/portugues-brasil.mdc`).

## PT-BR

### Stack principal

- Flutter + Dart
- Estado: Provider (estado legado do FlutterFlow ainda existe em partes)
- Navegacao: go_router (com caminhos legados em transicao)
- Dados: Supabase (alvo), com SQLite legado durante migracao

### Convencoes de nome e estrutura

- Arquivos em snake_case.
- Classes em PascalCase.
- Priorizar organizacao por feature em `lib/features/`.
- Manter services coesos e testaveis.

### Restricoes de seguranca e produto

- UX segura para criancas e obrigatoria.
- Sem navegacao externa para criancas sem gate parental.
- Superficie do player minima e aderente a politicas.
- Nao adicionar SDK de anuncios.

### Arquivos criticos (mexer com cuidado)

- `android/app/build.gradle`
- `android/key.properties` (gerado no CI, nao commitar)
- `.github/workflows/deploy_android.yml`
- `pubspec.yaml` (overrides e mudancas que impactam release)

### Idioma (texto em portugues)

- Tudo o que for escrito em portugues para humanos (docs, comentarios de produto, strings quando aplicavel) deve ser em **português do Brasil (pt-BR)**, nao em portugues de Portugal.
- **Assistentes (Cursor e similares):** mesma obrigacao que o texto do produto; a premissa esta tambem nas **rules** do repositorio (`.cursor/rules/portugues-brasil.mdc`).
- Vocabulário: usar **arquivo(s)**, **celular**, **tela**; **nao** usar *ficheiros*, *telemóvel*, *ecrã* quando estiver falando como em pt-BR.

### Regras operacionais

- Preferir mudancas pequenas e revisaveis.
- Validar com analise/testes quando alterar comportamento.
- Evitar vazamento de credenciais em commits e logs.

### Baseline de seguranca

- Aplicar menor privilegio em CI/CD e acesso a dados.
- Manter todas as tabelas expostas no Supabase com RLS e policies explicitas.
- Nao armazenar credenciais sensiveis ou segredo parental em storage simples.
- Manter logs de producao minimos e saneados.
- Manter hardening ativo nos builds de release mobile.
- Usar `security-checklist.md` nos checkpoints de PR/release.
