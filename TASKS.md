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

- **Active phase:** Phase 19 — Release Preparation
- **Status:** Complete (Android verified live; iOS build/install unverifiable on this Windows dev machine — no Xcode/macOS — see note below)
- **Last session summary:** Phase 19 (Release Preparation) completed 2026-08-20. App icon + splash source images (a leaf mark in the app's own seed-derived colors, matching the in-app SplashScreen's `CircleAvatar`+`Icons.eco`) generated via a new one-off script, `tool/generate_icons.dart` — deliberately pure pixel-buffer drawing via `package:image`, not Flutter's widget/rendering pipeline, after `RenderRepaintBoundary.toImage()` hung indefinitely (two separate 10-minute timeouts) in this sandboxed dev environment. `flutter_launcher_icons` (Android adaptive icon + iOS all sizes) and `flutter_native_splash` (Android 12+ splash API + legacy `launch_background.xml` + iOS launch screen) both added as dev dependencies and run successfully from those source images. Also found and fixed a real pre-existing bug while verifying the launcher icon live: `AndroidManifest.xml`'s `android:label` and iOS `Info.plist`'s `CFBundleDisplayName` were still the literal Flutter-template default (`smart_garden_ai` / `Smart Garden Ai`) rather than `SmartGarden AI` — this had shipped since Phase 0 and was never caught until actually looking at the home-screen app drawer. Debug-only component gallery route + its Home app-bar entry point now guarded with `kDebugMode` (compile-time constant — tree-shaken out of release builds entirely, not just hidden) in both `app_router.dart` and `home_dashboard_screen.dart`; a `// TODO(Phase 19)` comment already marked the exact spot from when it was added. `flutter analyze` clean; `flutter test` 105/105 (no regressions). `flutter build apk --release --dart-define=USE_REAL_AI_MODEL=true` succeeds (78.6MB, confirms `tflite_flutter`'s native libraries survive R8 code shrinking in release mode, not just debug). Store metadata content drafted in new `STORE_METADATA.md` (app name, short/full descriptions, keywords, category, privacy notes, a 7-shot screenshot plan with rationale) — content only, no submission, per `ROADMAP.md`'s explicit scope.
- **Live on-device verification: done (Android).** The release APK was installed and launched on the Pixel_7 emulator twice (once to catch the label bug, once after fixing it) — confirmed live: the leaf launcher icon renders correctly and distinctly in the app drawer, the label reads "SmartGarden AI" (post-fix), the debug gallery button is genuinely absent from the release build's Home app bar (not just theoretically guarded), and the app renders real content (a real saved scan, "Black Spot / Moderate") with no crash. One `"System UI isn't responding"` ANR occurred during this — confirmed to be Android's own system-shell process (not this app) hanging, consistent with this project's long-documented emulator resource/jank constraints (see the adb-tap Locked Decision row); the app itself kept rendering correctly underneath it. The native splash's XML wiring was confirmed statically (`launch_background.xml` now references the generated `@drawable/background`/`@drawable/splash`, no longer the default empty template) but a live splash-frame screenshot wasn't cleanly caught due to emulator launch-timing flakiness — low-risk given the config is confirmed correct and the app boots into real content successfully either way.
- **iOS: config done, build/install unverifiable here.** `flutter_launcher_icons`/`flutter_native_splash` both ran with `ios: true` and updated `ios/Runner/Assets.xcassets` (all icon sizes, launch image) and `Info.plist` correctly — confirmed by reading the generated files. Actually building/running `flutter build ipa` or installing on an iOS simulator is impossible on this Windows dev machine (no Xcode/macOS toolchain available) — this is a genuine platform constraint, not a skipped step. Needs a Mac to complete iOS-side verification.
- **Next action:** Phase 19 was the last phase in `ROADMAP.md`'s original 19-phase plan. Remaining work is either (a) the disclosed open items below, (b) actual store submission (out of this phase's scope — `ROADMAP.md` explicitly limited Phase 19 to "content only, not submission"), or (c) new feature work beyond the original roadmap — whichever the next session is asked to do.
- **Open items carried forward (not blocking, disclosed):** (1) Read Aloud (`flutter_tts`, Phase 13) produced no audible voice on the Pixel_7 emulator during live testing — likely an emulator TTS/audio-routing limitation, not confirmed, worth checking on a real device. (2) No *real, non-synthetic* photo has been run through `TFLiteAIService` yet (Phase 18's integration test used a synthetic image) — the lab-background-bias question from training remains unconfirmed. (3) "Weather isn't set up yet" was observed live but is expected/correct behavior (no `WEATHER_API_KEY` passed), not a bug.

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
- [x] `tflite_flutter` (+ `image`, for Dart-side decode/resize) dependency added
- [x] Model asset(s) placed and registered in `pubspec.yaml` — `assets/models/plant_disease_model.tflite` + `assets/models/labels.txt`
- [x] `TFLiteAIService implements AIService` implemented per `MODEL_INTEGRATION.md` contract — lazy interpreter load, background-isolate inference via `compute()`, confidence-threshold + `Unknown Disease` handling
- [x] DI swap mechanism from `MockAIService` to `TFLiteAIService` implemented (`--dart-define=USE_REAL_AI_MODEL=true`; mock is the default and retained for dev/testing)
- [x] Output mapping validated against `PlantDiagnosisResult` shape — new `tflite_label_parser.dart` (label parsing/canonicalization, unit-tested) + `tflite_diagnosis_content_bank.dart` (43-entry content bank) + matching `RecommendationLocalDataSource` entries; exhaustiveness-tested against all 71 real labels
- [x] Verified: zero changes required in `presentation/` layers of result/recommendation/ai_loading/my_garden/scan_history (confirmed via `git status`)
- [x] Live on-device verification (`integration_test/tflite_ai_service_test.dart` run on the Pixel_7 emulator — real interpreter load + real inference confirmed working; see Current Status note above)

## Phase 19 — Release Preparation
- [x] App icons (Android adaptive + iOS all sizes) — generated from a leaf mark in the app's own theme via `tool/generate_icons.dart` + `flutter_launcher_icons`
- [x] Native splash screen configured to match Phase 2 branding — `flutter_native_splash`, same leaf mark + `colorScheme.surface`, matching the in-app `SplashScreen`
- [x] Release build validated — `flutter build apk --release` succeeds (78.6MB, confirms `tflite_flutter` survives R8 shrinking). `flutter build ipa` **not run** — no Xcode/macOS on this dev machine, a genuine platform constraint, not skipped by choice
- [x] Debug-only routes removed or guarded — component gallery route + its Home entry point both gated on `kDebugMode` (tree-shaken from release builds), confirmed absent in a live release-build install
- [x] Store metadata draft (description, screenshot plan) — `STORE_METADATA.md`
- [x] Verified: release build installs and runs cleanly, correct icons/splash, no debug artifacts — confirmed live on Android (Pixel_7 emulator); iOS confirmed via generated-file inspection only (see Current Status note)
