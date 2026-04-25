# Dulang Context Pointer for Claude

This file is now a lightweight adapter.

## Canonical project context

Use `docs/ai-context/` as the single source of truth:

- `docs/ai-context/README.md`
- `docs/ai-context/project-overview.md`
- `docs/ai-context/current-status.md`
- `docs/ai-context/roadmap-priorities.md`
- `docs/ai-context/engineering-rules.md`
- `docs/ai-context/developer-profile.md`
- `docs/ai-context/decisions-log.md`

## Critical reminders

- Child-safe product constraints are non-negotiable.
- Avoid regressions that expose external navigation to children.
- Treat release-critical files with care:
  - `android/app/build.gradle`
  - `.github/workflows/deploy_android.yml`
  - `pubspec.yaml`

## Nota (PT-BR)

Este arquivo existe para compatibilidade com Claude.  
O contexto oficial e atualizado do projeto esta em `docs/ai-context/`.
