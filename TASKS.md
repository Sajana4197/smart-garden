# TASKS.md — SmartGarden AI

> Granular, checkbox-level task tracker mirroring `ROADMAP.md`. This is the file to update **during** a session as work happens, and to check **at the start** of a session to know exactly where things stopped.
>
> **Rules for using this file:**
> - Check a box the moment the task is actually done (code written *and* verified running/compiling), not when merely started.
> - If a phase is split (see `ROADMAP.md` sizing note), split its section here too (e.g. `Phase 9a`, `Phase 9b`).
> - Never delete completed sections — this file is the project's build log. Strike through only if a task became obsolete, and say why in a short inline note.
> - Keep "Current Status" at the top accurate — it is the first thing a new session should read.

---

## Current Status

- **Active phase:** Phase 4 — SQLite Persistence Layer
- **Status:** Not started
- **Last session summary:** Phase 3 completed on 2026-07-10. Built the primary navigation shell: bottom M3 `NavigationBar` with 5 destinations (Home, My Garden, Scan History, Plant Health, Settings) via `go_router`'s `StatefulShellRoute.indexedStack` — `core/routing/main_shell_screen.dart` (shell `Scaffold`+`NavigationBar`) and `core/routing/app_router.dart` (5 branches, routes `/`, `/my-garden`, `/scan-history`, `/plant-health`, `/settings`), decision recorded in `CLAUDE.md` §3. Added minimal stub screens for `MyGardenScreen`, `ScanHistoryScreen`, `PlantHealthDashboardScreen`, `SettingsScreen` (own app bar + shared `EmptyStateWidget`, `TODO(Phase N)` pointing at the phase that builds each out for real). Rebuilt `HomeDashboardScreen` into the real static dashboard: time-of-day greeting, weather summary card (static placeholder), daily tip card (static placeholder), full-width "Scan a Plant" CTA (snackbar placeholder until Phase 5), and a "Recent Activity" preview (3 static entries with `AppStatusBadge`) whose "See all" navigates to the Scan History tab — all built from existing Phase-1 shared widgets/tokens, no new one-off styles. Kept the debug-gallery entry on Home's app bar (not moved) so the existing widget test didn't need changing. `flutter analyze` clean, `flutter test` passes (2 widget tests, unchanged). Verified live on the Android emulator (Pixel_7): screenshotted Home, then tapped through all 5 `NavigationBar` destinations (found via `uiautomator dump` bounds, not eyeballed coordinates) confirming correct content and selection state per tab; verified dark mode by flipping the emulator's system theme (`ThemeModeController` still defaults to `ThemeMode.system`, no in-app toggle until Phase 15) — full contrast/legibility held.
- **Next action:** Begin Phase 4 — SQLite Persistence Layer per `ROADMAP.md` (`sqflite` DB helper/service + schema versioning, `plants`/`scans`/`daily_tip_state` tables, domain entities, repository interfaces + implementations for `my_garden`/`scan_history`, unit tests against an in-memory/test DB — no UI changes yet).

---

## Phase 0 — Project Bootstrap
- [x] `flutter create` run with final package/app name and org identifier (confirm names with user if not already decided; record in `CLAUDE.md`)
- [x] Core dependencies added to `pubspec.yaml`: `provider`, `sqflite`, `path_provider`, `path`, `camera`, `image_picker`, `http` (or `dio`), `flutter_tts`, `shared_preferences`, `flutter_lints` (plus `go_router` per locked routing decision)
- [x] DI approach decided and recorded in `CLAUDE.md` (manual `provider` MultiProvider vs `get_it`)
- [x] Routing approach decided and recorded in `CLAUDE.md` (named routes vs `go_router`)
- [x] Full `lib/` folder skeleton created per `PROJECT_SPEC.md` §3
- [x] `analysis_options.yaml` configured with `flutter_lints`
- [x] Minimal `main.dart`/`app.dart` with Material 3 `MaterialApp` and placeholder home screen
- [x] `.gitignore` present and correct for Flutter
- [x] `flutter analyze` passes clean
- [x] `flutter run` verified on at least one target (Android emulator, screenshot-confirmed)

## Phase 1 — Design System Foundation ✅ COMPLETED (2026-07-08)
- [x] Light `ColorScheme` implemented per `UI_GUIDELINES.md`
- [x] Dark `ColorScheme` implemented per `UI_GUIDELINES.md`
- [x] `TextTheme` implemented (both modes)
- [x] Full `ThemeData` assembled for light and dark
- [x] `ThemeModeController` (provider) implemented, wired into `MaterialApp.themeMode`
- [x] Shared widget: primary button
- [x] Shared widget: secondary/outlined button
- [x] Shared widget: branded `AppBar`
- [x] Shared widget: card container
- [x] Shared widget: section header
- [x] Shared widget: loading indicator
- [x] Shared widget: empty-state widget
- [x] Shared widget: error-state widget
- [x] Shared widget: `AppStatusBadge` (per `UI_GUIDELINES.md` §6 — added beyond the original checklist since the guideline explicitly scopes it to Phase 1)
- [x] Temporary component gallery debug route added
- [x] Verified: theme toggle switches entire app correctly in both directions (on Android emulator)

## Phase 2 — Splash & Onboarding ✅ COMPLETED (2026-07-09)
- [x] Splash screen UI (branded entrance animation)
- [x] First-launch flag read/write via `shared_preferences`
- [x] Splash routing logic (first run → Onboarding; else → Home)
- [x] Onboarding carousel UI (3–4 slides) — 4 slides implemented
- [x] Onboarding skip/next/CTA controls
- [x] Onboarding completion sets first-launch flag
- [x] Verified: fresh install flow and returning-user flow both behave correctly (live on Android emulator, both themes)

## Phase 3 — Navigation Shell & Home Dashboard (static) ✅ COMPLETED (2026-07-10)
- [x] Primary navigation shell built (bottom nav or nav rail) — structure confirmed and recorded in `CLAUDE.md`
- [x] All primary destinations reachable (Home, My Garden, Scan History, Plant Health Dashboard, Settings)
- [x] Home Dashboard: greeting header
- [x] Home Dashboard: weather summary card (static placeholder)
- [x] Home Dashboard: daily tip card (static placeholder)
- [x] Home Dashboard: quick-scan CTA
- [x] Home Dashboard: recent activity preview (static placeholder)
- [x] Verified in both light and dark themes

## Phase 4 — SQLite Persistence Layer
- [ ] DB helper/service created, schema versioning constant defined
- [ ] `plants` table created (`onCreate`)
- [ ] `scans` table created (`onCreate`)
- [ ] `daily_tip_state` table/mechanism created
- [ ] Domain entities: `Plant`, `Scan` (pure Dart)
- [ ] Repository interfaces: `PlantRepository`, `ScanRepository`
- [ ] Repository implementations (sqflite-backed)
- [ ] Unit tests: `PlantRepository` CRUD
- [ ] Unit tests: `ScanRepository` CRUD
- [ ] All repository tests passing

## Phase 5 — Camera & Gallery Capture
- [ ] Camera feature: live preview + capture
- [ ] Camera permission request/rationale/denial UI
- [ ] Gallery feature: `image_picker` integration
- [ ] Gallery permission request/rationale/denial UI
- [ ] Captured/picked images copied into app sandbox storage (stable path)
- [ ] Home quick-scan CTA opens Camera/Gallery choice sheet
- [ ] Verified: resulting image path is valid and displayable after capture and after gallery pick

## Phase 6 — Preview & AI Loading Animation
- [ ] Preview screen: full-size image display
- [ ] Preview: Retake action (returns to Camera/Gallery)
- [ ] Preview: Confirm action (proceeds to AI Loading)
- [ ] AI Loading screen: branded animated analyzing state
- [ ] AI Loading: calls into `AIService` (stub result acceptable if Phase 7 not yet done)
- [ ] Verified: Confirm → animation → navigation forward works end-to-end

## Phase 7 — Mock AIService & Result Screen
- [ ] `AIService` abstract contract defined per `MODEL_INTEGRATION.md`
- [ ] `PlantDiagnosisResult` and related entities defined
- [ ] `MockAIService` implemented with simulated latency
- [ ] Mock result bank: multiple species, healthy case, multiple disease cases, varied confidence/severity
- [ ] DI wiring: `AIService` injected as interface everywhere consumed
- [ ] Result screen: diagnosis label, confidence indicator, severity badge, description, hero image
- [ ] Scan persisted to `scans` table on completion
- [ ] Verified: full Home → Camera/Gallery → Preview → AI Loading → Result flow works with mock data

## Phase 8 — Recommendation Engine
- [ ] Domain rule-based mapping: diagnosis → recommendation (watering, light, treatment, urgency)
- [ ] Local curated recommendation content bank covering all Phase 7 mock outcomes
- [ ] Recommendation screen/section UI
- [ ] Linked from Result screen
- [ ] Verified: every mock diagnosis outcome yields a sensible, non-empty recommendation

## Phase 9 — My Garden (CRUD UI)
- [ ] "Save to My Garden" flow from Result screen (name, species confirm, notes)
- [ ] My Garden list screen (grid/list, thumbnail, name, status badge)
- [ ] Plant detail screen (info, scan history for plant, edit, delete, rescan CTA)
- [ ] Verified: CRUD persists across app restart

## Phase 10 — Scan History
- [ ] Scan History list screen (reverse-chronological)
- [ ] Scan detail screen (reuse/extend Result presentation)
- [ ] Filter/sort controls (date, severity, linked vs unlinked)
- [ ] Verified: all historical scans appear correctly, including unlinked ones

## Phase 11 — Weather Integration
- [ ] Weather REST client implemented
- [ ] API key handling via `--dart-define` (not hardcoded/committed)
- [ ] Location permission flow
- [ ] Domain models: current conditions, short forecast
- [ ] Home Dashboard weather card wired to live data
- [ ] Graceful offline/error/permission-denied fallback UI (cached last value + indicator)
- [ ] Verified: live weather shown; offline/denied states verified by simulation

## Phase 12 — Daily Plant Tips
- [ ] Local tip bank asset (JSON) authored
- [ ] Deterministic date-seeded tip selection logic
- [ ] `daily_tip_state` persistence (stable within a calendar day)
- [ ] Home Dashboard tip card wired to live daily tip
- [ ] (Optional) "All Tips" browse screen
- [ ] Verified: tip stable across restarts same day, changes next day (simulate date if needed)

## Phase 13 — Voice Recommendation (TTS)
- [ ] `flutter_tts` integration
- [ ] Play/pause/stop controls
- [ ] Visual "speaking" state indicator
- [ ] Wired from Result and/or Recommendation screens
- [ ] Verified: reads diagnosis + recommendation aloud; pause/stop work correctly

## Phase 14 — Plant Health Dashboard
- [ ] Aggregate queries (status counts, trends, needs-attention list)
- [ ] Dashboard UI: summary stat cards
- [ ] Dashboard UI: health distribution visualization
- [ ] "Needs attention" list linking into My Garden detail
- [ ] Verified: updates correctly as new scans/plants are added

## Phase 15 — Settings & About
- [ ] Settings: theme mode control wired to Phase 1 controller
- [ ] Settings: temperature units control
- [ ] Settings: TTS voice/rate controls wired to Phase 13
- [ ] Settings: clear-data action with confirmation dialog
- [ ] Settings: notification toggle (if in scope)
- [ ] About: live app version via package info
- [ ] About: credits, licenses page, privacy/terms placeholders, contact link
- [ ] Verified: all settings persist and take effect immediately

## Phase 16 — Motion & Dark Mode Polish Pass
- [ ] Page transition animations audited/added across all routes
- [ ] `Hero` animations on scan images
- [ ] List item stagger/fade-in where applicable
- [ ] Button press feedback polish
- [ ] Skeleton/shimmer loading states where applicable
- [ ] Full dark-mode visual QA pass, issues fixed
- [ ] Performance pass (no visible jank on scroll/transitions)

## Phase 17 — Hardening: Errors, Empty States, Offline, Tests
- [ ] Empty-state pass: My Garden
- [ ] Empty-state pass: Scan History
- [ ] Error-state pass: Weather offline/failure
- [ ] Error-state pass: AI failure
- [ ] Error-state pass: permissions denied (camera/gallery/location) on every relevant screen
- [ ] Widget tests added for key screens
- [ ] Unit tests added for remaining uncovered use cases/repositories
- [ ] Crash-safety review of all I/O (camera, file, DB, network)
- [ ] Verified: no crash/blank state under empty DB, no network, denied permissions, AI failure

## Phase 18 — TensorFlow Lite Integration
- [ ] `tflite_flutter` dependency added
- [ ] Model asset(s) placed and registered in `pubspec.yaml`
- [ ] `TFLiteAIService implements AIService` implemented per `MODEL_INTEGRATION.md` contract
- [ ] DI swap mechanism from `MockAIService` to `TFLiteAIService` implemented (config/build-time switch, mock retained for dev/testing)
- [ ] Output mapping validated against `PlantDiagnosisResult` shape
- [ ] Verified: zero changes required in `presentation/` layers of result/recommendation/ai_loading/my_garden/scan_history

## Phase 19 — Release Preparation
- [ ] App icons (Android adaptive + iOS all sizes)
- [ ] Native splash screen configured to match Phase 2 branding
- [ ] Release build validated (`flutter build apk` / `flutter build ipa` as applicable)
- [ ] Debug-only routes removed or guarded (e.g. component gallery)
- [ ] Store metadata draft (description, screenshot plan)
- [ ] Verified: release build installs and runs cleanly, correct icons/splash, no debug artifacts
