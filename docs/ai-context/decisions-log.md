# Decisions Log / Log de Decisoes

## EN

### 2026-05-09 - Release `1.0.50+50`: Play upload API + iOS archive signing in CI

- **Versioning:** `pubspec.yaml` **`1.0.50+50`**; `app_build_metadata` **1.0.50** (legal footnote date unchanged: **11/05/2026**).
- **Android (`deploy_android.yml`):** removed **`changesNotSentForReview: true`** from `r0adkll/upload-google-play@v1` — Google Play Developer API returns *“Changes are sent for review automatically. The query parameter changesNotSentForReview must not be set.”* The workflow still uploads to **`internal`** only; this does **not** auto-promote to production.
- **iOS (`deploy_ios.yml`):** provisioning profile is decoded and installed as **`${UUID}.mobileprovision`** under `~/Library/MobileDevice/Provisioning Profiles/` (more reliable than a fixed filename).
- **iOS project:** `Runner` **Release** uses **Manual** signing, **`iPhone Distribution`**, **`DEVELOPMENT_TEAM`**, **`PROVISIONING_PROFILE_SPECIFIER`** matching the portal profile name; project-level **Release** uses **`iPhone Distribution`** for `iphoneos` (avoids “No development certificates” when CI only has a **distribution** `.p12`). `ExportOptions.plist` **`provisioningProfiles`** string aligned to **`Dulang App Store Distribution`**. If Apple shows **Apple Distribution** instead of **iPhone Distribution**, switch identities accordingly.

### 2026-05-11 - Release `1.0.49+49`: iOS bundle `com.carlosdev.dulang`; Android + iOS CI ops

- **Versioning:** `pubspec.yaml` **`1.0.49+49`**; `app_build_metadata` **1.0.49** / **11/05/2026**.
- **iOS:** `PRODUCT_BUNDLE_IDENTIFIER` and `ios/ExportOptions.plist` **`com.carlosdev.dulang`** (was `com.carlosdev.dulangfree`); matches **Dulang App Store Distribution** profile in Apple Developer. Signing for GitHub Actions: **CSR + private key on Windows (OpenSSL)** → `.p12` + repository secrets; **`deploy_ios.yml`** remains **`workflow_dispatch`** only (manual **Run workflow**).
- **Ops:** **`master` push** triggers **Android** deploy workflow; **iOS** TestFlight upload is independent — **parallel runs are fine**; ensure provisioning profile includes the active **iOS Distribution** certificate after any cert rotation.

### 2026-05-10 - Android Internal Test build `1.0.48+48` (coupon info screen, in-app review, paywall fix)

- **Versioning:** `pubspec.yaml` **`1.0.48+48`**; `app_build_metadata` **1.0.48** / **10/05/2026**.
- **Coupon UX:** `DulangPremiumCodigoInfoWidget` — settings “Dulang Premium” with access code opens **info + share** (store listing URLs placeholders until operator fills constants); no paywall for coupon-only.
- **Stability:** `DulangPremiumWidget` auto-redirect to **Manage subscription** only when `hasActiveStorePremiumEntitlement` (fixes navigation loop / freeze with coupon + manage guard).
- **In-app review:** `ParentReviewPrompt` from **Configuracoes** only; **5 days** after first `NavBarPage` marker (`AppInstallMarkers`); **5 minutes** in `kDebugMode` for local testing; `in_app_review` + `share_plus` deps. **Note:** Play/App Store may throttle visible review UI—avoid spamming `requestReview` in QA.

### 2026-05-09 - Android Internal Test build `1.0.47+47` (merge to `master`, CI deploy)

- **Versioning:** `pubspec.yaml` **`1.0.47+47`**; `lib/app_build_metadata.dart` **`marketingVersion` 1.0.47**, **`lastContentUpdate` 09/05/2026** (legal footnote on Sobre / Termos / Contato).
- **Product delta in this build:** premium **store-only** “Manage subscription” menu + defensive manage screen; **schedule autosave**; **profile name** normalization; access-code stack and related Supabase/docs already on `master` lineage.
- **Ops:** `deploy_android.yml` on **`master`** push uploads AAB to **Internal testing**; operator runs **Play-installed** QA (`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`) before promoting track or **Play Store review** submission.

### 2026-05-08 - Premium UX: store-only “Manage subscription”; schedule autosave; profile name normalization; footnote metadata

- **Settings navigation:** `Gerenciar assinatura` is shown only when `hasActiveStorePremiumEntitlement` (RevenueCat entitlement active). **Coupon-only** premium (`hasPremiumAccess` via `AccessCodeService`) opens **Dulang Premium** instead — no store subscription to manage.
- **`DulangSubscriptionManageWidget`:** after `refreshCustomerInfo`, redirects to `DulangPremiumWidget` if there is no active **store** entitlement; UI cards require `ent.isActive`. Removes the old “Premium por código” block on this route (coupon users should not land here).
- **Schedules (`HorariosAcessoWidget`):** persistence on every control change; **450ms debounce** on the daily-limit slider; optional success snack after debounced save; **silent** immediate saves for switches/dropdowns; **flush on dispose** when data was loaded; hint line explains autosave.
- **Profiles:** `TextCapitalization.words` on add/rename dialogs; `ChildProfileService.normalizeProfileDisplayName` applied in `addProfile` / `renameProfile`.
- **Release discipline:** `lib/app_build_metadata.dart` (`marketingVersion`, `lastContentUpdate`) must be updated alongside `pubspec.yaml` for releases that change visible version or legal footnote text; documented in `engineering-rules.md`.

### 2026-05-09 - Access-code UX hardening validated; ready for release build `1.0.46+46`

- **UX:** Access-code dialog now disables submit while processing, shows loading spinner, and blocks repeated taps.
- **Stability:** Removed transient `TextEditingController` disposal race in paywall dialog; prevents red-screen assertions (`_dependents.isEmpty`) after code redemption.
- **Resilience:** `AccessCodeService.redeem` now has timeout + dedicated `FunctionException` handling for clearer operator diagnostics.
- **Ops:** Reviewer instructions finalized with explicit **no login / no payment** guidance and numbered redemption steps.

### 2026-05-09 - Access-code work on `feature/access-codes-supabase`; “network error” = invoke failure

- **Git:** access-code work pushed on branch **`feature/access-codes-supabase`** (no merge to `master` yet) to avoid triggering **Android deploy** until release is intended.
- **Ops:** In-app **“Erro de rede…”** maps to an **exception** calling **`functions.invoke('validate-access-code')`** — verify Edge deploy, same-project `SUPABASE_URL` / anon key in `environment.json`, and network; see **`docs/ACCESS_CODES_SUPABASE.md`** §6.
- **Repo:** **`supabase/.temp/`** added to **`.gitignore`**.

### 2026-05-08 - Premium access codes (one-time) via Supabase; freemium tier removed

- **Product:** A **one-time alphanumeric access code** unlocks Premium for that **install**. The code is validated by Edge Function **`validate-access-code`**; Postgres table **`public.access_codes`** marks **`used = true`** after the first successful redemption — **no reuse** of the same row.
- **Client:** `AccessCodeService` persists grant in **`SharedPreferences`** (not tied to store account). Uninstall clears local state; user must **purchase**, **restore**, or **redeem a new code** from ops — the burned code cannot be entered again.
- **Ops:** Run migration `supabase/migrations/20260508120000_access_codes.sql`; deploy `supabase functions deploy validate-access-code --no-verify-jwt`; insert codes via SQL. Play Console reviewer instructions should describe **Premium screen → “Tenho um código de acesso”** + the issued code. Doc: `docs/ACCESS_CODES_SUPABASE.md`.
- **Removed:** `FreemiumService`, 1h/day freemium UI, `FreePlanEmailSheet`, NavBar freemium overlay/timer. **`hasPremiumAccess`** includes RevenueCat entitlement + local access-code grant (after debug flags).
- **Version:** **`1.0.45+45`** (expected next Android CI upload).

### 2026-03-02 (Play policy) - Families Policy Requirements: WebViews (rejection context)

- Fact: Google Play **rejected an update** under **Families Policy Requirements: WebViews**. Stated reason (Play Console policy text): apps that **primarily aggregate content that does not belong to the developer** are not allowed in this configuration.
- Play guidance to fix: remove violating presentation; and/or provide **proof of ownership** (official logo/icon, developer name, professional support email); and/or add **substantial first-party product value** beyond being a thin wrapper around third‑party video browsing.
- Product/engineering stance for Dulang: treat the app as **curated English exposure** with **no open web for children**, minimal player surface, and parent gates; keep store listing and in‑app reality aligned; maintain operator evidence pack (brand, curation workflow, privacy/support) for appeals/reviews.

### 2026-05-07 - Paywall purchase hardening; RevenueCat `$rc_*` package mapping; billing QA on Play-installed builds

- **Code:** `SubscriptionService` resolves monthly vs annual `Package`s when RevenueCat emits non-standard `PackageType` (includes `CUSTOM`) using `StoreProduct.subscriptionPeriod` and product-id keywords; purchase uses **120s** timeout; `userMessageForPurchaseError` maps Play-style errors (including item unavailable / English “could not be found”) to **pt-BR**, steering users and reviewers toward **Plano gratuito → Continuar**. `DulangPremiumWidget` handles `TimeoutException`; purchase errors use mapped messages.
- **RevenueCat (dashboard):** **`$rc_monthly`** / **`$rc_annual`** must reference **exactly one** corresponding Play subscription product each; mixing monthly SKU into the annual slot (or duplicates) reproduced **billing item not found** for testers/reviewers.
- **Operational QA:** Valid purchase testing expects the app **installed from Google Play** (internal/closed/production). **`flutter run` USB installs** may still query prices but commonly **fail or flake on purchase** — not sufficient alone for billing sign-off.
- **Play reviewer instructions:** Document **free plan** entry (**Continuar** on **Plano gratuito**) alongside optional Premium trial copy.
- Impact: `lib/features/subscription/subscription_service.dart`, `lib/pages/dulang_premium/dulang_premium_widget.dart`, `docs/ai-context/`; version **`1.0.44+44`** for CI Android deploy.

### 2026-05-02 - Play Store production submission; environment.json CI fix; parental reset fix

- **Play Store submitted:** version `1.0.43+43` sent to production review. Reviewer access via freemium plan (no backdoor); instructions in Play Console: title "Free Plan Access — No Login Required", email `review@dulang.com`. Premium-gated screens (Favorites, History, custom themes/schedules) documented as intentional behavior.
- **`environment.json` in CI (root cause fix):** file is gitignored — the release build had empty Supabase URL/key and RevenueCat key, causing spinner forever (no content), Brevo email failure, and "Subscriptions not available". Fix: `ENVIRONMENT_JSON` GitHub Secret (base64 of the file) decoded in both `deploy_android.yml` and `deploy_ios.yml` before `flutter pub get`. No code changes required.
- **Parental controls reset on premium loss:** time window and daily limit set during premium persisted to freemium, bypassing the 1h/day enforcement. Fix: `main()` now calls `ParentalService.setAccessWindowEnabled(false)` and `setDailyLimitEnabled(false)` when `!hasPremiumAccess` — identical pattern to theme reset. Auto-renewing subscribers unaffected (`hasPremiumAccess` stays `true` continuously). Impact: `lib/main.dart`, bump `1.0.42+42 → 1.0.43+43`.
- **iOS setup planned 2026-05-03:** Apple certificate export, provisioning profile, and GitHub Secrets setup; then run `deploy_ios.yml` and submit to App Store.

### 2026-05-01 - iOS CI/CD workflow; freemium QA completed on Android

- Decision: create `.github/workflows/deploy_ios.yml` (`workflow_dispatch` only; `macos-latest`; Flutter 3.41.7; manual code signing via certificate + provisioning profile installed in ephemeral keychain; `flutter build ipa --release --obfuscate`; TestFlight upload via `xcrun altool` with App Store Connect API key). `ios/ExportOptions.plist` uses bundle ID **`com.carlosdev.dulang`** and `signingStyle: manual`. Team ID injected at build time via `sed` (plist does not expand env vars natively).
- iOS app in App Store Connect uses bundle ID **`com.carlosdev.dulang`**; provisioning profile name in `ExportOptions.plist` must match the portal name — update if renamed.
- `workflow_dispatch` only (no auto-trigger on push) because iOS builds are less frequent and TestFlight uploads require deliberate version bumps; Android keeps auto-trigger on `master` push.
- Freemium + premium QA approved on physical Android device (2026-05-01); all flows validated including debug panel, daily limit overlay, Brevo email registration, content gates, and theme enforcement.
- Impact: `.github/workflows/deploy_ios.yml` (new), `ios/ExportOptions.plist` (new); `current-status.md` and `roadmap-priorities.md` updated. Version bump to `1.0.41+41` for Internal Test upload.

### 2026-04-30 - Freemium plan (1h/day); security hardening; Play reviewer access

- Decision: add **freemium tier** (1h/day, lifetime, email required) as a third plan alongside Monthly and Annual. Resolves Play Store reviewer access without backdoor: reviewer chooses Free, enters a provided email, experiences the app exactly as any real user would.
- Feature gates for free tier: Favoritos/Histórico blocked (`PremiumGateScreen`); Aparência light-only; Horários locked; Perfis add/delete blocked (rename allowed). `FreemiumService` tracks daily usage independently from `ParentalService` to avoid mixing business logic with parental controls.
- Email registration: `FreePlanEmailSheet` bottom sheet with LGPD consent. Brevo API key kept **server-side only** via Supabase Edge Function `register-free-plan` (secrets `BREVO_API_KEY`, `BREVO_LIST_ID`). `environment.json` removed from git tracking and added to `.gitignore`.
- Router gate: post-onboarding, no plan selected → `DulangPremiumWidget(isGate: true)` (no back button); enrolling/purchasing triggers router refresh to `NavBarPage`.
- Debug: `kDebugMode`-only panel in Configurações (tree-shaken in release) — bypass premium toggle + freemium reset.
- Impact: new files `freemium_service.dart`, `free_plan_email_sheet.dart`, `premium_gate_screen.dart`, `supabase/functions/register-free-plan/index.ts`; updated `nav.dart`, `main.dart`, `dulang_premium_widget.dart`, `configuracoes_widget.dart`, `favoritos_widget.dart`, `historico_widget.dart`, `selecionar_perfil_widget.dart`, `aparencia_widget.dart`, `horarios_acesso_widget.dart`, `subscription_service.dart`, `.gitignore`. Version bump `1.0.40+40`.

### 2026-04-30 - Subscription management screen; store `managementURL`; paywall UX refinements

- Decision: subscribers open **Gerenciar assinatura** (`DulangSubscriptionManageWidget`) from Settings (and paywall redirects away if already entitled); screen shows current entitlement/product summary and **Abrir na loja** using RevenueCat **`CustomerInfo.managementURL`** (native Apple/Google subscription UI). Non-subscribers still use **`DulangPremiumWidget`** (sticky CTA, placeholders when offerings missing). Removed in-app Premium debug overrides earlier in the same initiative cycle.
- Why: Apple/Google own cancellation and plan changes; the app must explain and deep-link, not duplicate store policy.
- Impact: `nav.dart`, `index.dart`, `configuracoes_widget.dart`, `dulang_premium_widget.dart`, new `dulang_subscription_manage_widget.dart`; context docs updated.

### 2026-04-28 - RevenueCat entitlement identifier `dulang_premium_entitlement`

- Decision: use RevenueCat entitlement identifier **`dulang_premium_entitlement`** in the dashboard and in app code (`SubscriptionConstants.premiumEntitlementId`); retire **`premium`** as the entitlement id string in operator-facing docs.
- Why: The RC project is configured with this identifier; `CustomerInfo.entitlements` lookups must match exactly.
- Impact: `lib/features/subscription/subscription_constants.dart`; `docs/ai-context/current-status.md`, `roadmap-priorities.md`, `PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`. Older log bullets that mention entitlement **`premium`** describe the earlier naming before this alignment.

### 2026-04-29 - Remove mandatory app login; RevenueCat decoupled from Supabase Auth; parental PIN change uses device auth

- Decision: drop **required Supabase Auth** for the main shell; remove `/login` route and GoRouter redirects to it; remove settings **sign-out**; keep Supabase client init for catalog APIs; **RevenueCat** no longer calls `Purchases.logIn` with Supabase `user.id` (store account + restore purchases is the recovery path). **Change parental PIN** screen requires **device biometrics or device PIN** via `local_auth` before saving (`ParentalService.setPinAfterDeviceAuth`), not the old in-app PIN.
- Why: minimize friction for families and paying users while keeping a meaningful adult gate for parental settings changes.
- Impact: `nav.dart`, `main.dart`, `subscription_service.dart`, `configuracoes_widget.dart`, `alterar_pin_widget.dart`, Android `USE_BIOMETRIC`, iOS `NSFaceIDUsageDescription`, docs updated; `login_widget.dart` left in repo unused (can delete later).

### 2026-04-27 - Phase 1 closed; Phase 2 starts with RevenueCat

- Decision: treat **Phase 1** (store/compliance baseline) as **complete on 2026-04-27** by operator sign-off, then prioritize **RevenueCat** integration as the next engineering block.
- Why: catalog sync, access posture, and player behavior are sufficient to move on; monetization was always the next roadmap phase.
- Impact: context docs and backlog shift to subscription SDK, offerings, paywall, and entitlement gating; residual items (SQLite file cleanup, SHA-pinned actions, more tests) stay as non-blocking follow-ups.

### 2026-04-29 - Single “Who is watching?” screen; premium title contrast; sign-out confirm; Phase 2 ops guide

- Decision: delete **PerfisGerenciar**; add **rename/delete** on profile cards (overflow menu) in **SelecionarPerfil**; keep legacy GoRoute `/perfisGerenciar` → same widget; **confirm dialog** before account sign-out; **PremiumCatalogLockBody** title uses `primaryText` so light theme stays readable; add non-technical ops doc `docs/PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md` (stores, RevenueCat, Supabase account, parental PIN “forgot” reality).
- Why: one parent flow; fewer accidental logouts; fix contrast bug; give operators a plain-language checklist outside code.
- Impact: `perfis_gerenciar_widget.dart` removed; `nav.dart`, `configuracoes_widget.dart`, `selecionar_perfil_widget.dart`, `premium_catalog_lock.dart` updated; README + `current-status.md` link the new guide.

### 2026-04-27 - Home channel grid: thumbnail from newest catalog video per channel

- Decision: use the **most recent `published_at`** among active `VideoRow`s per `channelName` as the **background image** for each channel tile (except “Todos”), with a dark gradient and white label text; fallback to solid tile if no URL.
- Why: stronger visual scan for children without storing channel avatars in Supabase; stable choice independent of `getVideos()` shuffle.
- Impact: `dulang_widget.dart` builds a per-channel representative map; UX aligns with the hero card’s imagery language.

### 2026-04-26 - Daily channel sync policy (nightly) with inactive-first handling

- Decision: operate channel-to-video sync once per day (night window), mark unavailable videos inactive first, and purge inactive records by TTL (90 days).
- Why: lower quota/cost and simpler operation for a curated child-safe catalog, while keeping auditability and rollback safety.
- Impact: sync design now depends on daily executor + metadata fields (`last_seen_at`, `deactivated_at`, sync logs); unavailable content leaves feed immediately via `is_active=false`.

### 2026-04-26 - Add Supabase Edge Function skeleton for daily YouTube sync

- Decision: add `supabase/functions/youtube-daily-sync/index.ts` as the operational executor skeleton for daily sync.
- Why: move from docs-only contract to executable path with explicit env, per-channel status update, and final inactivation/TTL calls.
- Impact: repository now contains deployable function baseline; production still requires secret setup and cron scheduling in Supabase.

### 2026-04-26 - Harden app-side catalog loading for sync instability

- Decision: add timeout + single retry in `SupabaseService` reads and explicit Home recovery UI for error and empty catalog states.
- Why: while channel-to-video sync is still being closed end-to-end, child-facing Home needs predictable behavior instead of silent failures.
- Impact: transient Supabase/network failures are retried once; Home now offers direct "try again" actions for load errors and empty catalog windows.

### 2026-04-26 - Remove SQLite bootstrap initialization from app startup

- Decision: stop calling `SQLiteManager.initialize()` in `main.dart`.
- Why: primary runtime read path is already Supabase-based; keeping SQLite init on startup adds unnecessary coupling while migration boundaries are being finalized.
- Impact: app startup no longer depends on SQLite initialization; legacy SQLite modules remain in repository and still need controlled cleanup.

### 2026-04-27 - Cap history and favorites in `FFAppState` (MRU, FIFO on overflow)

- Decision: keep at most `kMaxHistoryEntries` (100) and `kMaxFavorites` (60) in persisted lists. Newest item stays at index 0; when over capacity, the oldest items at the end of the list are dropped.
- Why: bound SharedPreferences size and keep UI lists manageable, aligned with typical mobile patterns.
- Impact: `initializePersistedState` trims existing oversized lists once; all mutating paths call the same caps. No UI change.

### 2026-04-28 - Revert Android native fullscreen channel for YouTube

- Decision: remove `MethodChannel` / `MainActivity` system-bar loop and Android-only Dart hooks; keep `flutter_flow_youtube_player` fullscreen overlay (black scaffold + `SystemChrome` as before the experiment).
- Why: on target API 36 the native approach still did not hide bars reliably in the field; avoid ongoing maintenance risk while child-safety navigation in the player stays unchanged.
- Impact: `MainActivity` is a plain `FlutterActivity` again; no `androidx.core` dependency added for this purpose.

### 2026-04-28 - Phase 2: login required, RevenueCat entitlement, Flutter paywall (no RC paywall UI)

- Decision: after parental onboarding, require **Supabase Auth** session before the main shell; gate Home/Favorites/History on RevenueCat entitlement **`premium`** (includes store free trial when configured); implement **custom Flutter paywall** (`DulangPremiumWidget`) with monthly/annual packages from the default offering, annual pre-selected, pricing from the store via SDK—**not** RevenueCat’s hosted paywall UI (`purchases_ui_flutter`).
- Why: align with product (account + subscription only), keep brand/UI control, and use RevenueCat for receipts and `CustomerInfo` only.
- Impact: `GoRouter` redirect to `/login` when logged out (public exceptions: login, terms, about, contact); `SubscriptionService` configures SDK, `logIn`/`logOut` with Supabase `user.id`; `NavBarPage` shows `PremiumCatalogLockBody` when not entitled; `DulangVideoWidget` / `CanalVideosWidget` defensively block without entitlement; settings adds sign-out.

### 2026-04-28 - Child profiles: no silent "Perfil 1"; Netflix-style picker

- Decision: replace `ensureDefaultProfile()` with `syncActiveProfileWithStoredList()` (never auto-create a profile). After onboarding the pending picker remains; `NavBarPage` also opens `SelecionarPerfil` when the stored profile list is empty.
- Why: the adult should name the child via the existing picker (`Nome da criança`) instead of a default label.
- Impact: first-time and “zero profiles” flows land on profile selection until at least one profile exists.

### 2026-04-26 - YouTube in-app fullscreen on Android: native system bar hide

- **Superseded 2026-04-28:** this approach was reverted (see above).

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

### 2026-05-09 - Release `1.0.50+50`: API da Play no upload + assinatura iOS no archive (CI)

- **Versionamento:** `pubspec.yaml` **`1.0.50+50`**; `app_build_metadata` **1.0.50** (data do rodapé legal **11/05/2026** — sem alteração de texto).
- **Android (`deploy_android.yml`):** removido **`changesNotSentForReview: true`** do `r0adkll/upload-google-play@v1` — a API da Play devolve *“Changes are sent for review automatically…”* e **não aceita** esse parâmetro. O fluxo segue só na trilha **`internal`** (**não** promove a produção sozinho).
- **iOS (`deploy_ios.yml`):** perfil decodificado e instalado como **`${UUID}.mobileprovision`** em `~/Library/MobileDevice/Provisioning Profiles/`.
- **Projeto iOS:** Release do **Runner** com assinatura **manual**, **`iPhone Distribution`**, **`DEVELOPMENT_TEAM`**, **`PROVISIONING_PROFILE_SPECIFIER`** = nome do perfil; Release no nível do **projeto** com **`iPhone Distribution`** para `iphoneos` (evita “No development certificates” quando o CI só tem `.p12` de **distribuição**). `ExportOptions.plist` com **`provisioningProfiles`** = **`Dulang App Store Distribution`**. Se a Apple mostrar **Apple Distribution** em vez de **iPhone Distribution**, trocar a identidade nos dois lugares.

### 2026-05-11 - Release `1.0.49+49`: bundle iOS `com.carlosdev.dulang`; CI Android + iOS

- **Versionamento:** `pubspec.yaml` **`1.0.49+49`**; `app_build_metadata` **1.0.49** / **11/05/2026**.
- **iOS:** `PRODUCT_BUNDLE_IDENTIFIER` e `ios/ExportOptions.plist` com **`com.carlosdev.dulang`** (antes `dulangfree`); alinhado ao perfil **Dulang App Store Distribution** no Developer. Assinatura para GitHub: **CSR + chave no Windows (OpenSSL)** → `.p12` + secrets; **`deploy_ios.yml`** só com **Run workflow** manual (não dispara no `push`).
- **Operação:** `push` na **`master`** → **Android** no CI; **iOS** independente — **pode rodar os dois ao mesmo tempo** no Actions; após trocar certificado, conferir perfil com o certificado **iOS Distribution** ativo.

### 2026-05-10 - Build Android `1.0.48+48` para Internal Test (tela cupom, review, fix paywall)

- **Versionamento:** `pubspec.yaml` **`1.0.48+48`**; `app_build_metadata` **1.0.48** / **10/05/2026**.
- **Cupom:** `DulangPremiumCodigoInfoWidget` — em Ajustes, **Dulang Premium** com código abre **informações + compartilhar** (URLs da ficha na loja ainda `null` até preencher constantes); **sem** paywall para quem só tem cupom.
- **Estabilidade:** `DulangPremiumWidget` só redireciona a **Gerenciar assinatura** com `hasActiveStorePremiumEntitlement` (evita **loop/travamento** com cupom + guarda da tela de gerenciar).
- **Avaliação na loja:** `ParentReviewPrompt` só na **aba Ajustes**; **5 dias** após marca em `AppInstallMarkers` (primeira `NavBarPage`); **5 minutos** em `kDebugMode` para teste local; deps `in_app_review` e `share_plus`. **Cuidado:** lojas podem **não mostrar** o diálogo se `requestReview` for chamado em excesso no QA.

### 2026-05-09 - Build Android `1.0.47+47` para Internal Test (merge na `master`, CI)

- **Versionamento:** `pubspec.yaml` **`1.0.47+47`**; `lib/app_build_metadata.dart` com **`marketingVersion` 1.0.47** e **`lastContentUpdate` 09/05/2026** (rodapé legal em Sobre / Termos / Contato).
- **Produto neste build:** menu **Gerenciar assinatura** só com loja + guarda na tela; **autosave** em Horários; **normalização** de nomes de perfil; linhagem já com códigos de acesso Supabase/docs.
- **Operação:** `push` na **`master`** roda **`deploy_android.yml`** (AAB → **teste interno**); validar build **baixada pela Play** com **`docs/CHECKLIST_TESTE_SANDBOX_PLAY.md`** antes de promover trilha ou **enviar para revisão** na Console.

### 2026-05-08 - UX Premium: “Gerenciar assinatura” só na loja; autosave em horários; perfis; rodapé

- **Menu Configurações:** **Gerenciar assinatura** só com entitlement de **loja** ativo (`hasActiveStorePremiumEntitlement`). Premium **só por cupom** continua em **Dulang Premium** (não há assinatura da Play/App Store para gerenciar nessa rota).
- **`DulangSubscriptionManageWidget`:** após `refreshCustomerInfo`, se não houver entitlement de loja ativo, **redireciona** para `DulangPremiumWidget`; cards exigem `ent.isActive`. Removido o bloco “Premium por código” nesta tela (deep link defensivo).
- **Horários e tempo:** gravação **automática** nas mudanças; **debounce ~450 ms** no slider do limite diário; snack de sucesso só após o debounce; switches/dropdowns salvam em silêncio com `_load` para atualizar “Hoje: …”; **flush** ao `dispose` se já carregou.
- **Perfis:** `TextCapitalization.words` nos diálogos; `ChildProfileService.normalizeProfileDisplayName` em `addProfile` / `renameProfile`.
- **Release:** além do `pubspec.yaml`, atualizar **`lib/app_build_metadata.dart`** (`marketingVersion`, `lastContentUpdate`) quando mudar versão visível ou texto do rodapé — ver `engineering-rules.md`.

### 2026-05-09 - Endurecimento de UX dos codigos validado; pronto para build `1.0.46+46`

- **UX:** dialogo de codigo com botao de confirmar desabilitado durante envio + spinner, evitando clique repetido.
- **Estabilidade:** removida corrida de descarte de `TextEditingController` no dialogo da paywall; evita tela vermelha com assert (`_dependents.isEmpty`) apos resgate.
- **Resiliencia:** `AccessCodeService.redeem` com timeout e tratamento dedicado de `FunctionException` para diagnostico mais claro.
- **Operacao:** instrucoes ao revisor fechadas com **sem login / sem pagamento** e passos numerados de resgate.

### 2026-05-09 - Checkpoint branch codigos + documentar falha invoke ("erro de rede")

- **Git:** alteracoes de codigos de acesso commitadas na branch **`feature/access-codes-supabase`** e `push` sem merge em `master` para **nao disparar** `deploy_android.yml` ate decisao de release.
- **Produto:** mensagem **"Erro de rede..."** em `AccessCodeService.redeem` = excecao na **Edge Function** (invoke), nao codigo invalido; checklist em **`docs/ACCESS_CODES_SUPABASE.md`** secao 6 (URL/anon key projeto certo, função deployada `--no-verify-jwt`, rede).
- **Higiene:** `supabase/.temp/` no **`.gitignore`** (cache da CLI).

### 2026-05-08 - Codigos de acesso premium (uso unico) com Supabase; fim do freemium

- **Produto:** um **codigo alfanumerico de uso unico** libera o Premium na **instalacao atual**. A Edge Function **`validate-access-code`** valida; a tabela **`public.access_codes`** marca **`used = true`** no primeiro resgate bem-sucedido — **nao da para reusar** a mesma linha.
- **Cliente:** `AccessCodeService` grava o direito em **`SharedPreferences`** (nao e conta da loja). Ao desinstalar, some o estado local; para voltar a ter Premium precisa **comprar**, **restaurar compras** ou **um codigo novo** inserido pela operacao — o codigo ja consumido **nao entra de novo**.
- **Operacao:** aplicar migration `supabase/migrations/20260508120000_access_codes.sql`; `supabase functions deploy validate-access-code --no-verify-jwt`; inserir codigos via SQL. No Play Console, instrucoes ao revisor: **Premium → “Tenho um codigo de acesso”** + o codigo emitido. Guia: `docs/ACCESS_CODES_SUPABASE.md`.
- **Removido:** `FreemiumService`, limite 1h/dia, sheet de email do plano gratuito, overlay/timer do freemium na NavBar. **`hasPremiumAccess`** = RevenueCat + flag local do codigo (apos flags de debug).
- **Versao:** **`1.0.45+45`** (proximo upload Android pelo CI esperado).

### 2026-05-07 - Paywall, mapeamento `$rc_*` no RevenueCat e QA de compra na Play

- **Código:** `SubscriptionService` deduz pacotes mensal/anual quando o RC não tipa como `monthly`/`annual` (período ISO + palavras-chave no id); timeout de **120s** na compra; mensagens em **pt-BR** para erros da loja (item indisponível / não encontrado), com caminho do **plano gratuito** (`DulangPremiumWidget` trata timeout e usa o mapeamento).
- **RevenueCat:** cada um de **`$rc_monthly`** e **`$rc_annual`** deve apontar para **um único** produto da Play coerente com o período; mapeamento incorreto gerou **item não encontrado** na compra em testes.
- **QA:** compra confiável só com app **instalado pela Play Store**; **`flutter run`** não substitui esse teste para billing.
- **Revisor Play:** instruções devem incluir **Continuar** no **Plano gratuito**, não apenas **Começar grátis** do Premium.
- Impacto: `subscription_service.dart`, `dulang_premium_widget.dart`, docs em `docs/ai-context/`; versão **`1.0.44+44`** para deploy Android no CI.

### 2026-03-02 (politica Play) - Requisitos da Politica para familias: WebViews (contexto de recusa)

- Fato: a Google Play **recusou uma atualizacao** sob **Requisitos da Politica para familias: WebViews**. Motivo declarado (texto do painel): **nao sao permitidos apps que coletam principalmente conteudo que nao pertence ao desenvolvedor**.
- Orientacao da Play para corrigir: remover o conteudo/apresentacao violadores; e/ou apresentar **prova de titularidade** (icone/logo oficiais, nome do desenvolvedor, e-mail profissional de suporte); e/ou acrescentar **funcionalidades e valor de produto** para o app nao ser apenas um “invólucro” de navegacao/consumo de video de terceiros.
- Posicao produto/engenharia no Dulang: posicionar como **curadoria de ingles para criancas** com **sem web aberta para a crianca**, superficie minima de player e portais parentais; manter **ficha da loja + experiencia real** alinhadas; manter pacote de evidencias (marca, curadoria, privacidade/suporte) para revisao/contestacao quando necessario.

### 2026-04-30 - Tela Gerenciar assinatura; `managementURL` da loja; refinamentos de UX do paywall

- Decisao: assinantes abrem **Gerenciar assinatura** (`DulangSubscriptionManageWidget`) nos Ajustes (e a paywall redireciona se ja houver entitlement); tela mostra resumo e **Abrir na loja** com **`CustomerInfo.managementURL`** do RevenueCat (UI nativa Apple/Google). Quem nao assina segue em **`DulangPremiumWidget`** (CTA fixo, placeholders se faltar offering). Overrides de Premium em debug removidos no mesmo ciclo.
- Motivo: cancelamento e mudanca de plano sao da loja; o app explica e deep-linka, nao duplica politica das lojas.
- Impacto: `nav.dart`, `index.dart`, `configuracoes_widget.dart`, `dulang_premium_widget.dart`, novo `dulang_subscription_manage_widget.dart`; docs de contexto.

### 2026-04-28 - Identificador de entitlement RevenueCat `dulang_premium_entitlement`

- Decisao: usar no painel RevenueCat e no codigo o identificador de entitlement **`dulang_premium_entitlement`** (`SubscriptionConstants.premiumEntitlementId`); deixar de documentar **`premium`** como id do entitlement para operacao.
- Motivo: O projeto no RC usa esse id; as leituras em `CustomerInfo.entitlements` precisam bater exatamente.
- Impacto: `lib/features/subscription/subscription_constants.dart`; `docs/ai-context/current-status.md`, `roadmap-priorities.md`, `PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md`. Entradas antigas do log que citam entitlement **`premium`** referem-se ao nome anterior a este alinhamento.

### 2026-04-29 - Sem login obrigatorio no app; RevenueCat sem Supabase Auth; troca de PIN com biometria/PIN do aparelho

- Decisao: tirar **login obrigatorio** (Supabase) do shell principal; remover rota `/login` e redirects do GoRouter; remover **Sair da conta** dos Ajustes; manter init do Supabase para leitura de catalogo; **RevenueCat** deixa de usar `Purchases.logIn` com `user.id` do Supabase (recuperacao = **conta da loja** + restaurar compras). Tela **Alterar PIN parental** exige **biometria ou PIN do aparelho** (`local_auth`) antes de salvar (`setPinAfterDeviceAuth`), nao o PIN antigo do Dulang.
- Motivo: menos friccao para familia e para quem quer assinar, mantendo trava razoavel para mudanca de PIN parental.
- Impacto: `nav.dart`, `main.dart`, `subscription_service.dart`, `configuracoes_widget.dart`, `alterar_pin_widget.dart`, permissao Android e texto iOS Face ID, docs; `login_widget.dart` fica no repo sem uso (pode apagar depois).

### 2026-04-27 - Fase 1 encerrada; Fase 2 comeca pelo RevenueCat

- Decisao: considerar a **Fase 1** (baseline loja/compliance) **concluida em 2026-04-27** por aceite do operador e priorizar em seguida a integracao **RevenueCat**.
- Motivo: sync de catalogo, postura de acesso e player estao suficientes para avancar; monetizacao ja era a proxima fase do roadmap.
- Impacto: documentacao e backlog passam a focar SDK, offerings, paywall e bloqueio por entitlement; limpeza SQLite, pin SHA em actions e mais testes ficam como follow-up nao bloqueante.

### 2026-04-27 - Grade Canais na Home: thumb do video mais novo do catalogo por canal

- Decisao: usar o **`published_at` mais recente** entre `VideoRow` ativos por `channelName` como **imagem de fundo** do tile (exceto "Todos"), com gradiente escuro e texto branco; sem URL, manter tile solido.
- Motivo: leitura visual melhor para crianca sem persistir avatar de canal no Supabase; escolha estavel independente do shuffle em `getVideos()`.
- Impacto: `dulang_widget.dart` monta mapa representativo por canal; linguagem visual alinhada ao hero.

### 2026-04-26 - Politica de sync diario (madrugada) com tratamento inativo-primeiro

- Decisao: operar sync de canais->videos 1x por dia (janela noturna), marcar indisponiveis como inativos primeiro e limpar inativos por TTL (90 dias).
- Motivo: menor custo/quota e operacao mais simples para catalogo curado infantil, mantendo trilha de auditoria e seguranca de rollback.
- Impacto: desenho do sync passa a depender de executor diario + metadados (`last_seen_at`, `deactivated_at`, logs de sync); conteudo indisponivel sai do feed imediatamente via `is_active=false`.

### 2026-04-26 - Adicionar esqueleto de Edge Function Supabase para sync diario do YouTube

- Decisao: adicionar `supabase/functions/youtube-daily-sync/index.ts` como executor operacional base do sync diario.
- Motivo: sair de contrato apenas documental para caminho executavel com env explicito, status por canal e chamadas finais de inativacao/TTL.
- Impacto: o repositorio passa a ter baseline de funcao implantavel; em producao ainda depende de configurar secrets e cron no Supabase.

### 2026-04-26 - Endurecer carregamento do catalogo no app para instabilidade de sync

- Decisao: adicionar timeout + uma tentativa de retry nas leituras do `SupabaseService` e UI explicita de recuperacao na Home para erro e catalogo vazio.
- Motivo: enquanto o sync canal->video ainda esta sendo fechado ponta a ponta, a Home infantil precisa de comportamento previsivel em vez de falha silenciosa.
- Impacto: falhas transitórias de rede/Supabase ganham uma nova tentativa; a Home agora oferece acao direta de "tentar novamente" para erro de carga e janela de catalogo vazio.

### 2026-04-26 - Remover inicializacao de bootstrap SQLite no startup do app

- Decisao: parar de chamar `SQLiteManager.initialize()` no `main.dart`.
- Motivo: o caminho principal de leitura em runtime ja esta baseado em Supabase; manter init de SQLite no startup adiciona acoplamento desnecessario enquanto a fronteira de migracao e fechada.
- Impacto: o startup do app nao depende mais da inicializacao de SQLite; os modulos legados continuam no repositorio e ainda exigem limpeza controlada.

### 2026-04-28 - Reverter fullscreen nativo Android no YouTube

- Decisao: remover `MethodChannel` / loop no `MainActivity` e os ganchos Dart especificos de Android; manter overlay de fullscreen (fundo preto + `SystemChrome` como antes do experimento).
- Motivo: no aparelho ainda nao escondia as barras de forma confiavel com target API 36; reduz risco de manutencao sem mexer na delegacao de navegacao do player.
- Impacto: `MainActivity` volta a ser `FlutterActivity` simples; dependencia `androidx.core` extra removida.

### 2026-04-28 - Fase 2: login obrigatorio, entitlement RevenueCat, paywall Flutter (sem UI nativa RC)

- Decisao: apos onboarding parental, exigir **sessao Supabase Auth** antes do shell principal; bloquear Home/Favoritos/Historico pelo entitlement **`premium`** no RevenueCat (inclui teste gratis da loja quando configurado); paywall **custom em Flutter** (`DulangPremiumWidget`) com pacotes mensal/anual da oferta padrao, **anual pre-selecionado**, precos da loja via SDK — **sem** paywall hospedada do RevenueCat (`purchases_ui_flutter`).
- Motivo: alinhar produto (so conta + assinatura), manter controle de marca/UI e usar RevenueCat so para recibos e `CustomerInfo`.
- Impacto: `GoRouter` redireciona para `/login` sem sessao (excecoes publicas: login, termos, sobre, contato); `SubscriptionService` configura SDK e faz `logIn`/`logOut` com `user.id` do Supabase; `NavBarPage` mostra `PremiumCatalogLockBody` sem direito ativo; `DulangVideoWidget` / `CanalVideosWidget` bloqueiam sem entitlement; Ajustes ganha sair da conta.

### 2026-04-29 - Tela unica de perfis; contraste do titulo Premium; confirmar sair; guia Fase 2 leigo

- Decisao: remover **Gerenciar perfis**; renomear/excluir pelo menu no card em **Quem esta assistindo?** (`SelecionarPerfil`); manter rota antiga `/perfisGerenciar` apontando para a mesma tela; dialogo de confirmacao antes de **Sair da conta**; titulo do bloqueio Premium com cor legivel no tema claro; novo arquivo `docs/PASSO_A_PASSO_FASE2_ASSINATURA_LEIGO.md` (lojas, assinatura, conta, PIN esquecido).
- Motivo: um fluxo so para o responsavel; menos saida acidental da conta; correcao de leitura; roteiro acessivel fora do codigo.
- Impacto: `perfis_gerenciar_widget.dart` removido; ajustes em `nav.dart`, `configuracoes_widget.dart`, `selecionar_perfil_widget.dart`, `premium_catalog_lock.dart`; links no README do hub e em `current-status.md`.

### 2026-04-28 - Perfis infantis: sem "Perfil 1" automatico; picker estilo Netflix

- Decisao: trocar `ensureDefaultProfile()` por `syncActiveProfileWithStoredList()` (nunca cria perfil sozinho). Depois do onboarding continua o flag de picker; `NavBarPage` tambem abre `SelecionarPerfil` quando a lista persistida esta vazia.
- Motivo: o adulto nomeia a crianca no fluxo existente ("Nome da criança") em vez de um rotulo padrao.
- Impacto: primeiro uso e caso "zero perfis" vao para a selecao ate existir pelo menos um perfil.

### 2026-04-27 - Limite de historico e favoritos no `FFAppState` (MRU, FIFO no excesso)

- Decisao: no maximo `kMaxHistoryEntries` (100) e `kMaxFavorites` (60) nas listas persistidas. O item mais recente fica no indice 0; acima do teto, remove os itens mais antigos (fim da lista).
- Motivo: limitar tamanho no SharedPreferences e manter listas usaveis, alinhado a apps moveis comuns.
- Impacto: `initializePersistedState` recorta listas antigas demais na primeira carga; todos os metodos que alteram lista aplicam o teto. Sem mudanca de UI.

### 2026-04-26 - Fullscreen do YouTube no Android: esconder barras via nativo

- **Substituído em 2026-04-28:** abordagem revertida (ver entrada de reversão acima).

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
