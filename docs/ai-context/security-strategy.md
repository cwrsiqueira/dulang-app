# Security Strategy / Estrategia de Seguranca

Last updated: 2026-04-25

## EN

## Security objectives

- Protect children-oriented product behavior and parental controls.
- Prevent credential leakage and supply-chain compromise.
- Enforce least privilege in data access and CI/CD.
- Maintain release hardening for mobile binaries.

## Baseline controls (mandatory)

### Secrets and keys

- Never commit sensitive secrets to the repository.
- Treat client-side keys as public and apply strict provider-side restrictions.
- Use per-environment keys and rotation procedures.

### Supabase and data access

- RLS enabled by default for all exposed tables.
- Explicit policies by role and operation (`SELECT`, `INSERT`, `UPDATE`, `DELETE`).
- Public reads must be narrowed (minimum columns + pagination/limits).
- Writes should be restricted to trusted backend paths.

### Mobile hardening

- Secure storage for sensitive local data.
- Release hardening enabled (minification, shrinking, obfuscation).
- Production-safe logging only.
- Integrity and compromise strategy (Play Integrity / DeviceCheck or equivalent roadmap).

### CI/CD and supply chain

- Least privilege permissions in workflows.
- Pin actions by SHA where feasible.
- Avoid unnecessary secret materialization; clean temporary sensitive files.
- Keep release-critical files under stricter review.

## Operating model

- Every significant feature/update includes a security impact review.
- `SEC-CHECKLIST` is required at PR and release checkpoints.
- Decisions and exceptions must be documented in `decisions-log.md`.
- Incidents and near misses must be tracked in `security-incidents.md`.

## PT-BR

## Objetivos de seguranca

- Proteger o comportamento de produto infantil e os controles parentais.
- Evitar vazamento de credenciais e risco de supply chain.
- Aplicar menor privilegio em acesso a dados e CI/CD.
- Manter hardening de release para binarios mobile.

## Controles baseline (obrigatorios)

### Secrets e chaves

- Nunca commitar segredo sensivel no repositorio.
- Tratar chaves no cliente como publicas e restringir no provedor.
- Usar chaves por ambiente com processo de rotacao.

### Supabase e acesso a dados

- RLS ativo por padrao em todas as tabelas expostas.
- Policies explicitas por papel e operacao (`SELECT`, `INSERT`, `UPDATE`, `DELETE`).
- Leituras publicas reduzidas ao minimo (colunas minimas + paginacao/limites).
- Escritas restritas a caminhos confiaveis de backend.

### Hardening mobile

- Storage seguro para dados locais sensiveis.
- Hardening de release ativo (minificacao, shrink, ofuscacao).
- Logging seguro em producao.
- Estrategia de integridade/dispositivo comprometido (Play Integrity / DeviceCheck ou roadmap equivalente).

### CI/CD e supply chain

- Permissoes minimas nos workflows.
- Pin de actions por SHA quando viavel.
- Evitar materializacao desnecessaria de segredos e limpar arquivos temporarios sensiveis.
- Revisao reforcada para arquivos criticos de release.

## Modelo operacional

- Toda feature/mudanca relevante exige revisao de impacto de seguranca.
- `SEC-CHECKLIST` e obrigatorio nos checkpoints de PR e release.
- Decisoes e excecoes devem ser registradas em `decisions-log.md`.
- Incidentes e quase-incidentes devem ser registrados em `security-incidents.md`.
