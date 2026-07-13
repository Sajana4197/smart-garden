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

- **Active phase:** Phase 16 — Motion & Dark Mode Polish Pass
- **Status:** Not started
- **Last session summary:** Phase 15 (Settings & About) completed on 2026-07-13. New `features/settings/` (filled in the pre-existing empty scaffold): domain `AppThemeMode`/`TemperatureUnit`/`SpeechSettings`/`AppSettings` entities (pure Dart — `AppThemeMode` is a domain-owned mirror of Flutter's `ThemeMode` since domain can't import Flutter, mapped via `presentation/utils/theme_mode_mapping.dart`), a `SettingsRepository` interface, and four use cases (`SetThemeMode`, `SetTemperatureUnit`, `SetSpeechSettings`, `ClearGardenData` — the last depends directly on `PlantRepository`+`ScanRepository`, same cross-feature pattern as `SavePlantToGarden`/`GetGardenHealthSummary`, and is deliberately scoped to garden content only, not a full factory reset). Data: `SettingsLocalDataSource` wraps `shared_preferences` with a synchronous `getSettings()`-shaped read (mirrors `OnboardingLocalDataSource`'s sync-read/async-write pattern), needed so `app.dart`'s bootstrap can seed `ThemeModeController`'s initial mode and `SpeechRepositoryImpl`'s initial rate/pitch before the widget tree exists. `SpeechRepository` gained `setSpeechRate`/`setSpeechPitch` methods (previously rate/pitch were hardcoded at construction only) so Settings changes apply live to the running TTS engine, not just on next app launch. Presentation: `SettingsProvider` (app-wide, same `StatefulShellRoute.indexedStack` reasoning as sibling tab providers) coordinates persistence *and* live propagation to `ThemeModeController`/`SpeechRepository`; rewritten `SettingsScreen` with five sections — Appearance (`SegmentedButton` for System/Light/Dark), Units (Celsius/Fahrenheit `SegmentedButton`, wired into `WeatherCard`'s display formatting via client-side conversion — the weather fetch itself still always requests `units=metric`), Voice (rate/pitch `Slider`s with `onChangeEnd`-only persistence to avoid spamming prefs/TTS mid-drag, plus a reused `ReadAloudControls` as a live preview), Data (`ClearGardenData` behind a confirmation `AlertDialog`, reloading `MyGardenProvider`/`ScanHistoryProvider`/`PlantHealthDashboardProvider` afterward per the established reload-on-mutation pattern), and About (live version via new `services/app_info/app_info_service.dart` wrapping `package_info_plus`, Credits/Privacy/Terms placeholder dialogs, `showLicensePage`, and a Contact row that copies an email to the clipboard rather than launching a mail client — deliberately avoiding a new `url_launcher` dependency/platform-manifest change for this pass, see CLAUDE.md §3). Notification toggle was deliberately left out of scope — no notification feature exists anywhere in the app yet, so a bare toggle would have no functionality behind it. `package_info_plus` added to `pubspec.yaml` (bumped to `^10.2.0` after `^8.3.1` conflicted with the existing `geolocator` constraint). `flutter analyze` clean; `flutter test` 66/66 (19 new: 4 `SettingsLocalDataSource`, 2 `SettingsRepositoryImpl`, 2 `ClearGardenData`, 7 `SettingsProvider`, 4 `SettingsScreen` widget tests — the last needed `tester.binding.setSurfaceSize()` since the full settings list exceeds the default test viewport). **Live on-device interactive verification was blocked by the same recurring adb/emulator-input issue**, now reproduced in a fourth consecutive session (Phase 12/13/14/15, see CLAUDE.md §3): the app launched and rendered correctly on the Android emulator with no regressions (Home, Scan History, Scan Detail all screenshot-confirmed), but taps toward the bottom-nav "Settings" tab twice landed late on stale screens (History, then a Scan Detail) instead of registering in real time; the `flutter run` log again showed the jank signature. The `SettingsScreen` widget tests (rendering + segment-tap-persists + clear-data-dialog-cancel, all exercised via `tester.tap()` against the real widget tree) stand in as the interactive-correctness proof, per the established fallback.
- **Next action:** Begin Phase 16 — Motion & Dark Mode Polish Pass per `ROADMAP.md` (page transition animations audited/added across all routes, `Hero` animations on scan images, list item stagger/fade-in where applicable, button press feedback polish, skeleton/shimmer loading states where applicable, a full dark-mode visual QA pass with issues fixed, and a performance pass for no visible jank on scroll/transitions).

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

## Phase 15 — Settings & About ✅ COMPLETED (2026-07-13)
- [x] Settings: theme mode control wired to Phase 1 controller
- [x] Settings: temperature units control
- [x] Settings: TTS voice/rate controls wired to Phase 13
- [x] Settings: clear-data action with confirmation dialog
- [x] Settings: notification toggle — deliberately out of scope; no notification feature exists in the app yet, so a bare toggle would control nothing (see CLAUDE.md §3)
- [x] About: live app version via package info
- [x] About: credits, licenses page, privacy/terms placeholders, contact link
- [x] Verified: all settings persist and take effect immediately — theme mode/temperature unit/speech rate & pitch changes propagate live to `ThemeModeController`/`WeatherCard`/`SpeechRepository` and persist via `shared_preferences`; confirmed via `flutter analyze`/`flutter test` (66/66, including 19 new tests) and a live emulator launch confirming no regressions. Interactive on-device tap verification of the Settings screen itself was blocked by the same recurring adb/emulator-input issue documented in Phase 12/13/14 (see CLAUDE.md §3), not by an app defect.

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
