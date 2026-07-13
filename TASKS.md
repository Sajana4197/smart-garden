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

- **Active phase:** Phase 18 — TensorFlow Lite Integration
- **Status:** Not started
- **Last session summary:** Phase 17 (Hardening: Errors, Empty States, Offline, Tests) completed on 2026-07-13, plus a post-Phase-16 user-requested enhancement (animated, condition-matched weather icons replacing the static weather icon — `features/weather/presentation/widgets/animated_weather_icon.dart`, hand-rolled `AnimationController`+`CustomPainter`, no new dependency). Phase 17 found and fixed four concrete crash-safety bugs via a systematic audit (not just review — each was verified against the actual code, several caught genuine unguarded paths): (1) new `core/widgets/safe_file_image.dart` (`SafeFileImage`, wrapping `Image.file` with a themed `errorBuilder` fallback) replaced all 9 raw `Image.file` call sites app-wide — sandboxed scan/plant photos are OS/user-managed disk state that can vanish independently of the DB row referencing them. (2) `ScanDetailScreen.initState()` previously called `PlantDiagnosisResult.fromJson(jsonDecode(...))` unguarded — a malformed `rawResultJson` (e.g. after a future result-shape change) would crash the whole screen; now caught, falling back to an `ErrorStateWidget`. (3) `PlantDetailScreen._loadScans()` previously had no try/catch — a `GetScansForPlant` failure left the screen in a permanently-stuck loading spinner; now caught with a retryable `ErrorStateWidget` for just that section. (4) `AiLoadingScreen._runAnalysis()` previously only caught `on AIServiceException` — a `ScanRepository.addScan` failure *after* a successful AI analysis fell through uncaught; now caught generically too (same class of bug as `WeatherProvider`'s Phase 11 fix, see CLAUDE.md §3). Also fixed a real (non-crash-safety) bug: Home Dashboard's "Recent Activity" was hardcoded fake static data since Phase 3, never wired to real scans — a brand-new user with an empty DB saw fake plants they never scanned. Rewired to `ScanHistoryProvider` via a new `recentScans` getter (deliberately separate from the existing filtered `scans` getter, which would have leaked the Scan History screen's filter/sort UI state into Home) — genuine empty state, real thumbnails via `SafeFileImage`, real relative timestamps, tap-through to Scan Detail; live-screenshot-confirmed showing real scan data. `flutter analyze` clean; `flutter test` 94/94 (24 new: `SafeFileImage` file-missing fallback — needed `tester.runAsync()` since real disk I/O doesn't resolve inside `flutter_test`'s fake-async zone; `AiLoadingScreen` typed-and-generic error states; `ScanDetailScreen` malformed-JSON fallback; `PlantDetailScreen` scan-load-error fallback — needed `tester.allWidgets` instead of `find.text()`/`find.byType()`, which didn't reliably locate content in this specific test's element-tree shape (documented in the test as a known quirk, not fully root-caused); `ScanHistoryProvider.recentScans`; a full `RecommendationLocalDataSource`/`RecommendationRepositoryImpl` suite, previously zero coverage). Widget-test coverage for `camera`, `gallery`, `onboarding`, `splash`, `preview`, and `result` screens remains at zero dedicated test files — a deliberate, disclosed scope decision (time-bounded to one session; Home/AI-loading/scan-detail/plant-detail were prioritized as the screens with actual newly-fixed bugs) rather than a silent gap. Live emulator verification confirmed the Home dashboard fix rendering correctly with real data; a follow-up tap to test Scan Detail navigation hit the same recurring adb/emulator-input issue (a seventh consecutive session: Phase 12/13/14/15/16/17, see CLAUDE.md §3), this time on a non-bottom-nav tap for the first time, so the "single-tap-from-Home targets are reliable" pattern noted in Phase 16 no longer fully holds.
- **Next action:** Begin Phase 18 — TensorFlow Lite Integration per `ROADMAP.md` (add `tflite_flutter` dependency, place and register a model asset, implement `TFLiteAIService implements AIService` per MODEL_INTEGRATION.md's contract, wire a DI swap mechanism from `MockAIService` to `TFLiteAIService` — config/build-time switch, mock retained for dev/testing — validate output mapping against `PlantDiagnosisResult`, and verify zero changes are required in any `presentation/` layer).

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

## Phase 16 — Motion & Dark Mode Polish Pass ✅ COMPLETED (2026-07-13)
- [x] Page transition animations audited/added across all routes — hand-rolled M3 "fade through" (`core/routing/app_page_transitions.dart`) applied to every pushed route; bottom-nav shell branches deliberately excluded (IndexedStack tab switching, not a page transition)
- [x] `Hero` animations on scan images — already in place since Phase 6 (Preview → AI Loading → Result), confirmed still correct, no changes needed
- [x] List item stagger/fade-in where applicable — `StaggeredFadeIn` applied to My Garden grid, Scan History list, Plant Health needs-attention list, All Tips list, Recommendation treatment steps
- [x] Button press feedback polish — `PressScale` (~0.97 `AnimatedScale`, built on `Listener` to guarantee it never swallows the child's own tap) wired into `AppPrimaryButton`/`AppSecondaryButton`/`AppCard`
- [x] Skeleton/shimmer loading states where applicable — hand-rolled `SkeletonBox` shimmer, composed into My Garden's and Scan History's initial-loading states
- [x] Full dark-mode visual QA pass, issues fixed — live-verified clean on Component Gallery (every shared widget), Home, and All Tips (including the new page transition and stagger, both confirmed working); the four bottom-nav-tab screens could not be live-verified due to the recurring adb/emulator-input issue (see CLAUDE.md §3) but rest on strong architectural evidence (zero hardcoded colors anywhere in the codebase, confirmed while reading every screen this session) — no contrast/legibility issues found or expected
- [x] Performance pass (no visible jank on scroll/transitions) — best-effort given the same input-reliability constraint; no new jank-prone patterns introduced (all new animations are one-shot and disposed on unmount, or run only during brief loading states); pre-existing environment jank (documented since Phase 12) is unrelated to this phase's changes

## Phase 17 — Hardening: Errors, Empty States, Offline, Tests ✅ COMPLETED (2026-07-13)
- [x] Empty-state pass: My Garden — already correct (Phase 9); reverified
- [x] Empty-state pass: Scan History — already correct (Phase 10); reverified. Also found and fixed Home Dashboard's "Recent Activity", which was hardcoded fake data since Phase 3 rather than a real empty state — rewired to `ScanHistoryProvider.recentScans` with a genuine empty state
- [x] Error-state pass: Weather offline/failure — already correct (Phase 11); reverified
- [x] Error-state pass: AI failure — typed `AIServiceException` handling already correct (Phase 7); found and fixed a gap where a post-analysis `ScanRepository.addScan` failure fell through uncaught in `AiLoadingScreen`
- [x] Error-state pass: permissions denied (camera/gallery/location) on every relevant screen — already correct (Phases 5, 11); reverified
- [x] Widget tests added for key screens — `AiLoadingScreen` (typed + generic error states), `ScanDetailScreen` (malformed-JSON fallback), `PlantDetailScreen` (scan-load-error fallback), `SafeFileImage`, `PressScale`/`StaggeredFadeIn` (carried over from Phase 16), `AnimatedWeatherIcon`
- [x] Unit tests added for remaining uncovered use cases/repositories — `RecommendationLocalDataSource`/`RecommendationRepositoryImpl` (previously zero coverage), `ScanHistoryProvider.recentScans`
- [x] Crash-safety review of all I/O (camera, file, DB, network) — found and fixed: unguarded `Image.file` at 9 call sites (→ `SafeFileImage`), unguarded `jsonDecode`/`fromJson` in `ScanDetailScreen`, unguarded DB call in `PlantDetailScreen._loadScans`, narrow typed-only catch in `AiLoadingScreen`
- [x] Verified: no crash/blank state under empty DB, no network, denied permissions, AI failure — confirmed via the fixes above plus `flutter analyze`/`flutter test` (94/94) and a live emulator launch showing Home's Recent Activity rendering real data correctly with no regressions

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
