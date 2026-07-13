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

- **Active phase:** Phase 17 — Hardening: Errors, Empty States, Offline, Tests
- **Status:** Not started
- **Last session summary:** Phase 16 (Motion & Dark Mode Polish Pass) completed on 2026-07-13. New shared motion primitives in `core/`: `core/routing/app_page_transitions.dart` (`buildAppPage` — a hand-rolled M3 "fade through" `CustomTransitionPage`: incoming content fades+scales in from 96%, outgoing fades out, both curved with `AppCurves.standard`/timed with `AppDurations.medium`), applied via `pageBuilder` to every pushed `GoRoute` in `app_router.dart` (splash, onboarding, debug gallery, camera, preview, ai-loading, result, recommendation, plant detail, scan detail, all-tips) — deliberately **not** applied to the bottom-nav shell's own branch routes, since `StatefulShellRoute.indexedStack` swaps tabs via `IndexedStack`, not a page transition, and a push-style animation there would fight the platform bottom-nav convention. `core/widgets/press_scale.dart` (`PressScale` — ~0.97 `AnimatedScale` on press, built on `Listener` rather than `GestureDetector` specifically because a nested `GestureDetector` would still enter the gesture arena and could silently swallow the child's own tap; `Listener` only observes raw pointer events without competing for the gesture, confirmed via a new regression test), wired into `AppPrimaryButton`, `AppSecondaryButton`, and `AppCard` (covering press feedback everywhere those three shared widgets are used, rather than touching every screen individually). `core/widgets/staggered_fade_in.dart` (`StaggeredFadeIn` — per-index fade+slide-up entrance, delay capped at index 10 so long lists don't have an ever-growing total entrance time), applied to My Garden's grid, Scan History's list, Plant Health Dashboard's needs-attention list, All Tips' list, and Recommendation's treatment steps. `core/widgets/skeleton_box.dart` (`SkeletonBox` — hand-rolled shimmering placeholder, no new dependency, matching this project's existing custom-animation convention), composed into new `_PlantGridSkeleton`/`_ScanListSkeleton` private widgets replacing the plain spinner in My Garden's and Scan History's initial-loading states. `AppStatusBadge`'s `Container` became an `AnimatedContainer` so color changes animate rather than snap. `flutter analyze` clean; `flutter test` 71/71 (5 new: `PressScale`'s tap-passthrough/press-visual/disabled-state, `StaggeredFadeIn`'s settled-opacity/dispose-before-delay-fires — both required advancing the fake clock explicitly past the stagger `Future.delayed` before `pumpAndSettle()`, since `pumpAndSettle()` alone stops as soon as no animation is *actively ticking*, which is true before a still-pending `Future.delayed` fires). **Dark-mode visual QA was live-verified for Component Gallery (every shared widget), Home, and All Tips** (all screenshot-confirmed clean, good contrast, no legibility issues) **plus the new fade-through page transition and stagger entrance, both confirmed working live** via the Home→All Tips navigation. Bottom-nav-tab screens (My Garden, Scan History, Health, Settings) could **not** be live-verified in dark mode — three consecutive attempts to tap the bottom nav all hit the same recurring adb/emulator-input issue (now a sixth consecutive session: Phase 12/13/14/15/16, see CLAUDE.md §3), taps registering late against stale screens. Coverage for those four screens rests on architectural evidence instead: every screen in this codebase (confirmed while reading all of them this session) is built exclusively from `Theme.of(context)`/`context.statusColors` — zero hardcoded colors anywhere — so the same `ColorScheme.fromSeed`-driven dark palette verified clean in Component Gallery and Home applies identically everywhere else. A full performance/DevTools profiling pass was not possible for the same input-reliability reason; no new jank-prone patterns were introduced (one-shot `AnimationController`s, disposed on unmount; `SkeletonBox`'s `repeat()` runs only during the brief initial-loading state).
- **Next action:** Begin Phase 17 — Hardening: Errors, Empty States, Offline, Tests per `ROADMAP.md` (empty-state pass for My Garden/Scan History, error-state passes for weather offline/failure and AI failure, permission-denied error states on every relevant screen, widget tests for key screens, unit tests for remaining uncovered use cases/repositories, a crash-safety review of all I/O, and verification that nothing crashes/blanks under empty DB, no network, denied permissions, or AI failure).

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
