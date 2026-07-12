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

- **Active phase:** Phase 13 — Voice Recommendation (TTS)
- **Status:** Not started
- **Last session summary:** Phase 12 (Daily Plant Tips) completed on 2026-07-12. Local curated tip bank authored as `assets/tips/plant_tips.json` (24 tips: id/title/body), declared in `pubspec.yaml`'s `flutter.assets`. New `features/daily_tips/` (filled in Phase 4/9's pre-existing empty scaffold): domain entities `PlantTip`, `DailyTipState`; `DailyTipRepository` interface; `GetDailyTip` use case (date-seeded deterministic index — `year*10000+month*100+day` mod tip-count — accepts an injectable `now` for testability); `GetAllTips` use case. Data: `TipBankDataSource` (reads the JSON asset via `rootBundle`, no network — offline-first), `DailyTipStateLocalDataSource` (sqflite-backed, wraps the `daily_tip_state` table created back in Phase 4; single-row table has no PK so `saveState` deletes-then-inserts rather than upserting by id), `DailyTipRepositoryImpl`. Presentation: `DailyTipProvider` (app-wide, same `StatefulShellRoute.indexedStack` reasoning as `MyGardenProvider`/`ScanHistoryProvider`/`WeatherProvider`; `tip`/`isLoading`/`hasError`, broad `catch (_)` per CLAUDE.md §3's locked decision on degrade-on-failure providers) and a new `AllTipsScreen` (optional browse screen, built and kept — see ROADMAP.md Phase 12's "browsable in full" exit criterion) reachable via a new `/tips` route. Home Dashboard's `_DailyTipCard` (previously hardcoded placeholder text) now reads live from `DailyTipProvider` and is tappable (`AppCard.onTap` + trailing chevron) through to `/tips`. `flutter analyze` clean; `flutter test` 27/27 (11 new: 6 `GetDailyTip` use-case tests against a fake repository covering same-day stability/next-day reselection/deterministic-not-random/stale-persisted-id fallback/empty-bank error, 3 `DailyTipStateLocalDataSource` sqflite-ffi tests covering the single-row overwrite semantics, 1 `AllTipsScreen` widget test, 1 new full-app widget test that taps the Home Dashboard tip card via `tester.tap` and asserts navigation to `/tips`). Verified live on the Android emulator (Pixel_7): screenshot confirmed the Home Dashboard tip card renders a real date-selected tip ("Use Room-Temperature Water") in place of the old static text. **Could not interactively verify the `/tips` tap-through live on-device**: `adb shell input tap`/`swipe` stopped registering with the app entirely partway through this session (confirmed via control taps on already-working targets — the bottom nav and the pre-existing "See all" link both also failed to respond) — an adb/emulator-input sandbox artifact, not an app defect (this echoes a milder version of the same tap-coordinate flakiness noted in Phase 2). Substituted the full-app `tester.tap()` widget test above as automated proof of the tap-to-navigate flow instead, which is arguably more reliable than a manual adb tap since it drives the real widget/gesture layer directly.
- **Next action:** Begin Phase 13 — Voice Recommendation (TTS) per `ROADMAP.md` (`flutter_tts` integration — already a `pubspec.yaml` dependency since Phase 0 but unused until now; play/pause/stop controls; a visual "speaking" state indicator; wire from Result and/or Recommendation screens; voice/rate/pitch can hardcode sane defaults for now since Settings is still a stub, revisit in Phase 15).

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
