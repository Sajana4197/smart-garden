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

- **Active phase:** Phase 15 — Settings & About
- **Status:** Not started
- **Last session summary:** Phase 14 (Plant Health Dashboard) completed on 2026-07-13. New `features/plant_health_dashboard/` (filled in the pre-existing empty scaffold): domain `GardenHealthSummary`/`NeedsAttentionEntry`/`HealthTrend` entities and a `GetGardenHealthSummary` use case that depends directly on both `PlantRepository` and `ScanRepository` (pure domain, no dedicated dashboard repository — same cross-feature pattern as `SavePlantToGarden`, see CLAUDE.md §3) to compute zero-filled status counts and a "needs attention" list (moderate/severe plants, most severe and most-recently-added first) with each entry's trend derived by comparing its two most recent scans' severities. Presentation: `PlantHealthDashboardProvider` (registered app-wide in `app.dart`, not screen-scoped — same `StatefulShellRoute.indexedStack` reasoning as `MyGardenProvider`/`ScanHistoryProvider`), three new widgets (`HealthStatCard`, `HealthDistributionBar` — a stacked-bar + color-keyed-legend visualization, `NeedsAttentionTile` — thumbnail/name/status badge/trend icon, tapping into `PlantDetailScreen`), and a rewritten `PlantHealthDashboardScreen` (loading/error/empty states + stat cards row + distribution + needs-attention list) replacing the Phase 3 stub. Every existing mutation site that can change plant/scan health data now also calls `PlantHealthDashboardProvider.loadSummary()` right after it succeeds: `PlantDetailScreen`'s edit and delete, `ResultScreen`'s Save to My Garden, and `ScanDetailScreen`'s Save-and-link (unlinked-scan creation in `AiLoadingScreen` was deliberately *not* wired, since an unlinked scan cannot affect any plant's status count or trend until it's linked to a plant). `flutter analyze` clean; `flutter test` 47/47 (14 new: 7 `GetGardenHealthSummary` unit tests against fake repositories covering status counting, needs-attention ordering/tie-breaking, and all four trend outcomes; 3 `PlantHealthDashboardProvider` unit tests; 4 `PlantHealthDashboardScreen` widget tests covering empty/loaded/all-healthy/error states). **Live on-device interactive verification was again blocked by the same recurring adb/emulator-input issue** first seen in Phase 12 and Phase 13 (see CLAUDE.md §3): relaunched the app fresh on the Android emulator and screenshot-confirmed it builds and renders correctly with real persisted data (Home, Scan History, and Scan Detail all rendered correctly with no regressions), but `adb shell input tap` toward the bottom-nav "Health" tab failed to register in real time across seven attempts — taps queued and fired late against stale screens (once landing on History, once opening a Scan Detail, once even backing fully out of the app to the launcher), reproduced even immediately after a fresh cold app relaunch, and the `flutter run` log again showed the same jank signature (`Choreographer: Skipped 259/36 frames`). This is now confirmed across three separate sessions as an environment constraint of this dev machine's emulator, not an app defect. Per the established fallback, the 4 `PlantHealthDashboardScreen` widget tests (exercising the real widget/render pipeline directly, immune to emulator input jank) stand in as the interactive-correctness proof for this phase.
- **Next action:** Begin Phase 15 — Settings & About per `ROADMAP.md` (theme mode control wired to the Phase 1 `ThemeModeController`, temperature units control, TTS voice/rate controls wired to Phase 13's `SpeechRepository` defaults, clear-data confirmation action, notification toggle if in scope, About screen with live app version via `package_info_plus`/credits/licenses/privacy-terms placeholders/contact link; wire the existing `SettingsScreen` stub behind the bottom-nav "Settings" tab).

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

## Phase 4 — SQLite Persistence Layer ✅ COMPLETED (2026-07-10)
- [x] DB helper/service created, schema versioning constant defined
- [x] `plants` table created (`onCreate`)
- [x] `scans` table created (`onCreate`)
- [x] `daily_tip_state` table/mechanism created
- [x] Domain entities: `Plant`, `Scan` (pure Dart)
- [x] Repository interfaces: `PlantRepository`, `ScanRepository`
- [x] Repository implementations (sqflite-backed)
- [x] Unit tests: `PlantRepository` CRUD
- [x] Unit tests: `ScanRepository` CRUD
- [x] All repository tests passing

## Phase 5 — Camera & Gallery Capture ✅ COMPLETED (2026-07-10)
- [x] Camera feature: live preview + capture
- [x] Camera permission request/rationale/denial UI
- [x] Gallery feature: `image_picker` integration
- [x] Gallery permission request/rationale/denial UI
- [x] Captured/picked images copied into app sandbox storage (stable path)
- [x] Home quick-scan CTA opens Camera/Gallery choice sheet
- [x] Verified: resulting image path is valid and displayable after capture and after gallery pick

## Phase 6 — Preview & AI Loading Animation ✅ COMPLETED (2026-07-11)
- [x] Preview screen: full-size image display
- [x] Preview: Retake action (returns to Camera/Gallery)
- [x] Preview: Confirm action (proceeds to AI Loading)
- [x] AI Loading screen: branded animated analyzing state
- [x] AI Loading: calls into `AIService` (stub result acceptable if Phase 7 not yet done)
- [x] Verified: Confirm → animation → navigation forward works end-to-end

## Phase 7 — Mock AIService & Result Screen ✅ COMPLETED (2026-07-11)
- [x] `AIService` abstract contract defined per `MODEL_INTEGRATION.md`
- [x] `PlantDiagnosisResult` and related entities defined
- [x] `MockAIService` implemented with simulated latency
- [x] Mock result bank: multiple species, healthy case, multiple disease cases, varied confidence/severity
- [x] DI wiring: `AIService` injected as interface everywhere consumed
- [x] Result screen: diagnosis label, confidence indicator, severity badge, description, hero image
- [x] Scan persisted to `scans` table on completion
- [x] Verified: full Home → Camera/Gallery → Preview → AI Loading → Result flow works with mock data

## Phase 8 — Recommendation Engine ✅ COMPLETED (2026-07-11)
- [x] Domain rule-based mapping: diagnosis → recommendation (watering, light, treatment, urgency)
- [x] Local curated recommendation content bank covering all Phase 7 mock outcomes
- [x] Recommendation screen/section UI
- [x] Linked from Result screen
- [x] Verified: every mock diagnosis outcome yields a sensible, non-empty recommendation

## Phase 9 — My Garden (CRUD UI) ✅ COMPLETED (2026-07-11)
- [x] "Save to My Garden" flow from Result screen (name, species confirm, notes)
- [x] My Garden list screen (grid/list, thumbnail, name, status badge)
- [x] Plant detail screen (info, scan history for plant, edit, delete, rescan CTA)
- [x] Verified: CRUD persists across app restart

## Phase 10 — Scan History ✅ COMPLETED (2026-07-11)
- [x] Scan History list screen (reverse-chronological)
- [x] Scan detail screen (reuse/extend Result presentation)
- [x] Filter/sort controls (date, severity, linked vs unlinked)
- [x] Verified: all historical scans appear correctly, including unlinked ones

## Phase 11 — Weather Integration ✅ COMPLETED (2026-07-12)
- [x] Weather REST client implemented
- [x] API key handling via `--dart-define` (not hardcoded/committed)
- [x] Location permission flow
- [x] Domain models: current conditions, short forecast
- [x] Home Dashboard weather card wired to live data
- [x] Graceful offline/error/permission-denied fallback UI (cached last value + indicator)
- [x] Verified: live weather shown; offline/denied states verified by simulation

## Phase 12 — Daily Plant Tips ✅ COMPLETED (2026-07-12)
- [x] Local tip bank asset (JSON) authored
- [x] Deterministic date-seeded tip selection logic
- [x] `daily_tip_state` persistence (stable within a calendar day)
- [x] Home Dashboard tip card wired to live daily tip
- [x] (Optional) "All Tips" browse screen
- [x] Verified: tip stable across restarts same day, changes next day (simulate date if needed) — covered by unit tests against an injectable clock (`GetDailyTip(now: ...)`); live device verification confirmed the card renders a real bank tip, not simulated across a real day boundary (would require leaving the emulator running past midnight)

## Phase 13 — Voice Recommendation (TTS) ✅ COMPLETED (2026-07-12)
- [x] `flutter_tts` integration
- [x] Play/pause/stop controls
- [x] Visual "speaking" state indicator
- [x] Wired from Result and/or Recommendation screens
- [x] Verified: reads diagnosis + recommendation aloud; pause/stop work correctly — verified via `flutter analyze`/`flutter test` (33/33, including a full tap-cycle `ReadAloudControls` widget test) and a live emulator launch confirming no regressions; interactive on-device tap verification was blocked by an adb/emulator-input issue this session (see Current Status above and CLAUDE.md §3), not by an app defect

## Phase 14 — Plant Health Dashboard ✅ COMPLETED (2026-07-13)
- [x] Aggregate queries (status counts, trends, needs-attention list)
- [x] Dashboard UI: summary stat cards
- [x] Dashboard UI: health distribution visualization
- [x] "Needs attention" list linking into My Garden detail
- [x] Verified: updates correctly as new scans/plants are added — every mutation site (edit/delete plant, save-to-garden, save-and-link scan) calls `PlantHealthDashboardProvider.loadSummary()`; confirmed via `flutter analyze`/`flutter test` (47/47, including 4 dedicated screen widget tests) and a live emulator launch confirming no regressions on other screens. Interactive on-device tap verification of the dashboard itself was blocked by the same recurring adb/emulator-input issue documented in Phase 12/13 (see CLAUDE.md §3), not by an app defect.

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
