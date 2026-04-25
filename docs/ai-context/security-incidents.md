# Security Incidents / Incidentes de Seguranca

Use this file as `SEC-INCIDENTS`.

## How to log

For each incident or near miss, add:

- Date
- Type (incident or near_miss)
- Severity (critical/high/medium/low)
- Area (mobile, backend, CI/CD, secrets, compliance)
- Summary
- Root cause
- Fix applied
- Prevention actions
- Owner and due date (if pending)

## Template

```text
Date:
Type:
Severity:
Area:
Summary:
Root cause:
Fix applied:
Prevention actions:
Owner:
Due date:
Status:
```

## Current records

### 2026-04-25

- Type: near_miss
- Severity: high
- Area: secrets
- Summary: `YOUTUBE_API_KEY` found in versioned client asset file.
- Root cause: key management relied on local asset configuration without restrictive controls documented in repo.
- Fix applied: key removed from versioned asset; app now supports `--dart-define=YOUTUBE_API_KEY=...`.
- Prevention actions: enforce key governance in `SEC-CHECKLIST` and `SEC-STRATEGY`, run periodic secret exposure review, apply Google Cloud key restrictions (currently temporary `none`).
- Status: in_progress

### 2026-04-25

- Type: near_miss
- Severity: high
- Area: mobile
- Summary: parental PIN stored in plain `SharedPreferences`.
- Root cause: convenience local persistence with no secure storage policy enforced.
- Fix applied: pending.
- Prevention actions: migrate to secure storage + hash/salt baseline rule.
- Status: open
