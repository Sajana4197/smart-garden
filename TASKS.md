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

- **Active phase:** Phase 9 — My Garden (CRUD UI)
- **Status:** Not started
- **Last session summary:** Phase 8 completed on 2026-07-11. Built the Recommendation feature end-to-end. Domain: `CareRecommendation`/`RecommendationUrgency` entity (`lib/features/recommendation/domain/entities/`), `RecommendationRepository` interface, and `GetCareRecommendation` use case (synchronous — pure local rule-based lookup, no I/O) taking `diagnosisLabel` + the existing `DiagnosisSeverity` (reused directly from `services/ai/models` rather than inventing a third mirrored severity enum). Data: `RecommendationLocalDataSource` holds a curated content bank keyed by `diagnosisLabel` covering all 7 distinct labels in `mockResultBank` (Healthy, Powdery Mildew, Aphid Infestation, Black Spot, Downy Mildew, Bacterial Wilt, Root Rot), each with watering advice, light advice, and 2-3 treatment steps; urgency (`routine`/`monitor`/`urgent`) is derived from severity rather than stored per-label, so a future real-model report of an existing label at a different severity still degrades sensibly. Included a generic fallback entry for any unmapped `diagnosisLabel` per `MODEL_INTEGRATION.md` §3's "never crash on an unknown diagnosis" requirement (not reachable by the current mock bank, but present for the Phase 18 swap). `RecommendationRepositoryImpl` wired into `app.dart`'s `MultiProvider`. Built `RecommendationScreen` (+ `RecommendationScreenArgs` transport class) — thumbnail + diagnosis label/species header, urgency badge (reusing `AppStatusBadge` with a custom label: routine→healthy/moderate→monitor/urgent→severe visual mapping), Watering/Light advice cards, and a checklist-style Treatment Steps card. Wired as a new `/recommendation` route. `ResultScreen` gained a "View Care Recommendations" primary CTA (pushes to the new route) with the old "Back to Home" demoted to a secondary outlined button beneath it. `flutter analyze` clean; `flutter test` 16/16 (no test changes — Phase 8 is a pure rule-based mapping + display, no new repository/use-case behavior needing DB access). Verified live end-to-end on the Android emulator in both themes: Result → View Care Recommendations → Recommendation screen, twice with different mock outcomes (Downy Mildew/Basil/Moderate→Monitor and Black Spot/Rose/Moderate→Monitor), each showing the correct distinct content-bank entry. Caught and correctly diagnosed a live testing gotcha (not an app bug): the "View Care Recommendations"/"Back to Home" button's on-screen Y position shifts between runs because it sits inside a `ListView` below a variable-length description — a fixed tap coordinate that worked for one diagnosis missed for another with a shorter description; resolved by reading exact bounds via `adb shell uiautomator dump` before tapping rather than assuming a fixed coordinate.
- **Next action:** Begin Phase 9 — My Garden (CRUD UI) per `ROADMAP.md` ("Save to My Garden" flow from Result/Recommendation screens with name/species-confirm/notes, My Garden list screen backed by the existing `PlantRepository`, plant detail screen with scan history/edit/delete/rescan, verifying CRUD persists across app restarts).

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
