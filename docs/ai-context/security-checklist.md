# Security Checklist / Checklist de Seguranca

Last updated: 2026-04-25

## How to use / Como usar

- Use this file as `SEC-CHECKLIST`.
- Track each item as `done`, `in_progress`, or `pending`.
- Always review this checklist on PR and before release.

## Critical risks currently observed

- [in_progress] Rotate and restrict exposed `YOUTUBE_API_KEY` (removed from versioned asset, pending provider-side rotation/restrictions).
- [pending] Migrate parental PIN storage from plain `SharedPreferences` to secure storage + hash.
- [pending] Enable Android release hardening (`minifyEnabled`, `shrinkResources`, obfuscation).
- [pending] Add explicit CI least-privilege permissions and pin actions by SHA.
- [pending] Confirm and version RLS/policies for Supabase tables.

## Development phase (Dev)

- [ ] No sensitive secret committed in repo (`service_role`, private keys, keystores, passwords).
- [ ] Public keys/tokens in client are restricted and monitored.
- [ ] Parental/auth sensitive values use secure storage, never plain local storage.
- [ ] No debug logs with sensitive values in production code paths.
- [ ] New data tables include explicit access model and RLS plan.
- [ ] External links are gated for child safety requirements.

## Pull Request phase (PR)

- [ ] Security-sensitive files reviewed explicitly (`android/app/build.gradle`, workflows, env files).
- [ ] Any new dependency has security impact checked.
- [ ] No new broad permissions or unsafe platform flags introduced.
- [ ] Data access changes include policy notes (RLS, limits, pagination).
- [ ] Changes include update to `SEC-STRATEGY`/`CTX-RULES` when needed.

## Release phase

- [ ] Android hardening enabled (minification/resource shrinking/obfuscation).
- [ ] Production logging reduced and sanitized.
- [ ] CI workflow uses minimum required permissions.
- [ ] CI actions pinned by SHA or documented exception.
- [ ] Key rotation/restriction status validated (YouTube, Supabase, RevenueCat).
- [ ] Security smoke test executed (auth gates, parental PIN, external navigation limits).

## Post-release phase

- [ ] Monitor abuse indicators (API quota spikes, unusual traffic patterns).
- [ ] Record incidents and near misses in `security-incidents.md`.
- [ ] Run periodic access review of Supabase policies.
- [ ] Reassess threat model after major feature changes.
