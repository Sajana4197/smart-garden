# ROADMAP.md — SmartGarden AI

> Phased delivery plan. Each phase is scoped to fit in **one Claude Code session** and must leave the app compiling and runnable (`flutter run`) at the end. Do not start a phase until the previous phase's exit criteria are met. Update `TASKS.md` checkboxes as work completes, and update the **Current Status** block in `CLAUDE.md` at the end of every session.

---

## Phase 0 — Project Bootstrap
**Goal:** A clean, empty-but-structured Flutter project that builds and runs.
- Run `flutter create`, set package/app name, org identifier.
- Add all core dependencies from `PROJECT_SPEC.md` §2 (resolve to latest stable versions).
- Create the full `lib/` folder skeleton from `PROJECT_SPEC.md` §3 (empty placeholder files with `// TODO` markers where needed).
- Configure `analysis_options.yaml` with `flutter_lints`.
- Decide and lock: DI approach (manual `provider`-based vs `get_it`), routing approach (named routes vs `go_router`). Record decision in `CLAUDE.md` → Locked Decisions.
- Set up `main.dart` / `app.dart` with a minimal `MaterialApp` (Material 3 enabled, placeholder home screen showing "SmartGarden AI").
- Initialize git (if not already) with a sensible `.gitignore` for Flutter.
- **Exit criteria:** `flutter analyze` is clean, `flutter run` shows a placeholder home screen on at least one platform (Android or iOS emulator, or web/desktop if that's the dev target).

## Phase 1 — Design System Foundation
**Goal:** Material 3 theme (light + dark) and the shared widget library exist and are demonstrable.
- Implement `core/theme/` — `ColorScheme` (light & dark, seeded per `UI_GUIDELINES.md`), `TextTheme`, full `ThemeData` for both modes.
- Implement theme mode switching plumbing (provider-based `ThemeModeController`), even before Settings screen exists.
- Build shared widgets in `core/widgets/`: primary/secondary buttons, app-branded `AppBar`, cards, section headers, loading indicator, empty-state widget, error-state widget.
- Add a temporary "component gallery" debug route to visually verify all shared widgets in both themes (removable later or kept behind a debug flag).
- **Exit criteria:** Toggling theme mode (even via a temp debug button) switches the whole app between light/dark with correct Material 3 styling.

## Phase 2 — Splash & Onboarding
**Goal:** App launch experience is complete.
- Splash screen: branded, animated logo/name entrance, reads first-launch flag from `shared_preferences`, routes accordingly.
- Onboarding: 3–4 slide carousel (illustration/icon + headline + subcopy), skip/next controls, final CTA into Home Dashboard, sets first-launch flag on completion.
- Wire routing: Splash is the actual app entry point now (replaces Phase 0 placeholder).
- **Exit criteria:** Fresh install shows Splash → Onboarding → Home (placeholder); relaunch shows Splash → Home directly.

## Phase 3 — Navigation Shell & Home Dashboard (static)
**Goal:** Primary navigation structure and Home Dashboard UI exist with placeholder/mock data (no DB yet).
- Build the app's primary navigation shell (bottom nav bar or nav rail) covering: Home, My Garden, Scan History, Plant Health Dashboard, Settings (confirm final nav structure here and record in `CLAUDE.md`).
- Build Home Dashboard UI: greeting header, weather summary card (static placeholder data), daily tip card (static placeholder), quick-scan CTA button, recent activity preview (static placeholder list).
- **Exit criteria:** All primary destinations are reachable via navigation; Home Dashboard renders fully with placeholder content in both themes.

## Phase 4 — SQLite Persistence Layer
**Goal:** Local database is fully wired per `PROJECT_SPEC.md` §5, with repository interfaces + implementations, no UI changes yet beyond wiring.
- Add `sqflite` DB helper/service in `core` (or a dedicated `services/database/`), schema versioning, `onCreate`.
- Implement `plants` and `scans` tables per spec.
- Implement domain entities, repository interfaces, and repository implementations for `my_garden` and `scan_history` features (data + domain layers only).
- Unit test repositories against an in-memory/test DB.
- **Exit criteria:** CRUD operations for plants and scans are covered by passing unit tests; no UI depends on this yet.

## Phase 5 — Camera & Gallery Capture
**Goal:** User can capture or pick a photo and land on a raw file path.
- Camera feature: live preview, capture button, permission request/rationale/denial handling.
- Gallery feature: `image_picker` integration, permission handling.
- Both write the resulting image into app sandbox storage (not just a temp/cache path) and return a stable local path.
- Entry point wired from Home Dashboard's quick-scan CTA (choice sheet: Camera or Gallery).
- **Exit criteria:** From Home, user can capture or pick an image and see the resulting file path logged/displayed on a temporary confirmation screen.

## Phase 6 — Preview & AI Loading Animation
**Goal:** The pre-analysis UX is complete.
- Preview screen: shows captured/picked image full-size, Retake and Confirm actions (Confirm proceeds, Retake returns to Camera/Gallery).
- AI Loading screen: branded animated "analyzing your plant" state (implicit animations or Lottie), triggered on Confirm, calls into `AIService` (mock still returns a placeholder/stub result at this point if Phase 7 hasn't landed — otherwise integrate directly with Phase 7).
- **Exit criteria:** Confirm → animated loading state → (stub) navigation to a placeholder Result screen.

## Phase 7 — Mock AIService & Result Screen
**Goal:** End-to-end scan flow works with realistic mock diagnosis data.
- Implement `AIService` abstract contract and `PlantDiagnosisResult` (+ related) entities per `MODEL_INTEGRATION.md`.
- Implement `MockAIService`: simulated latency (1.5–3s), varied/randomized plausible results drawn from a local curated result bank (multiple plant species, healthy + several disease cases, varying confidence/severity).
- Wire DI so `AIService` is injected as an interface everywhere it's consumed.
- Build Result screen: diagnosis label, confidence indicator, severity badge, description, hero image of the scan, primary CTA into Recommendation.
- Persist every completed scan into the `scans` table (Phase 4 repository).
- **Exit criteria:** Full flow works: Home → Camera/Gallery → Preview → AI Loading → Result, with a real (mock) diagnosis, and the scan is recorded in Scan History's data layer.

## Phase 8 — Recommendation Engine
**Goal:** Diagnosis results produce actionable, specific care guidance.
- Domain-layer rule-based mapping: diagnosis label/severity → structured recommendation (watering, light, treatment steps, urgency).
- Recommendation screen/section: presents steps as a clear checklist/card list, links from Result screen.
- Local curated content bank (JSON or Dart const data) covering all mock diagnosis outcomes from Phase 7.
- **Exit criteria:** Every possible mock diagnosis outcome produces a matching, sensible recommendation with no fallback "no data" states.

## Phase 9 — My Garden (CRUD UI)
**Goal:** Users can build and manage a persistent garden.
- "Save to My Garden" action from Result screen (name the plant, confirm species, optional notes).
- My Garden list screen: grid/list of saved plants with thumbnail, name, status badge.
- Plant detail screen: full info, scan history for that plant, edit/delete, rescan CTA.
- **Exit criteria:** Full CRUD works and persists across app restarts (backed by Phase 4 repositories).

## Phase 10 — Scan History
**Goal:** Every scan is browsable independent of My Garden.
- Scan History list screen: reverse-chronological, thumbnail + label + date + severity.
- Scan detail screen (can reuse/extend Result screen presentation).
- Filter/sort (by date, by severity, by linked plant vs. unlinked).
- **Exit criteria:** All scans performed since Phase 7 appear correctly, including ones not saved to My Garden.

## Phase 11 — Weather Integration
**Goal:** Live weather contextualizes the Home Dashboard.
- Weather service: REST client, API key handling via `--dart-define` (never hardcoded/committed), location permission flow.
- Domain models for current conditions + short forecast.
- Replace Home Dashboard's static weather card with live data; graceful offline/error/denied-permission states (cached last value + indicator).
- **Exit criteria:** Home Dashboard shows real current weather for the device's location, with correct fallback UI when offline or permission-denied.

## Phase 12 — Daily Plant Tips
**Goal:** A rotating tip-of-the-day system.
- Local curated tip bank (JSON asset), deterministic "tip of the day" selection (e.g. date-seeded index), persisted `daily_tip_state` so the tip doesn't change on every app open within the same day.
- Replace Home Dashboard's static tip card with the live daily tip; optional dedicated "All Tips" browse screen.
- **Exit criteria:** Tip changes once per calendar day, is stable across app restarts on the same day, and is browsable in full.

## Phase 13 — Voice Recommendation (TTS)
**Goal:** Result/Recommendation content can be read aloud.
- `flutter_tts` integration: play/pause/stop controls, visual "speaking" state, voice/rate/pitch respecting Settings (Settings screen may still be a stub at this point — hardcode sane defaults if so, revisit in Phase 15).
- Wired from Result and/or Recommendation screens.
- **Exit criteria:** Tapping "Read aloud" speaks the diagnosis + recommendation text, with working pause/stop.

## Phase 14 — Plant Health Dashboard
**Goal:** Aggregated garden-wide health view.
- Aggregate queries over `plants`/`scans` (status counts, trend indicators, plants needing attention).
- Dashboard UI: summary stat cards, health distribution visualization, "needs attention" list linking into My Garden detail.
- **Exit criteria:** Dashboard reflects real data from My Garden/Scan History and updates when new scans are added.

## Phase 15 — Settings & About
**Goal:** App-level configuration and info screens are complete.
- Settings: theme mode (light/dark/system) fully wired to Phase 1's controller, temperature units, TTS voice/rate controls (wired back into Phase 13), clear-data action (with confirmation), notification toggle (if in scope).
- About: version (from package info), credits, licenses (`showLicensePage` or custom), privacy/terms placeholders, contact link.
- **Exit criteria:** All settings persist and take effect immediately; About renders correct live app version.

## Phase 16 — Motion & Dark Mode Polish Pass
**Goal:** The app feels premium end-to-end.
- Audit every screen for animation opportunities: page transitions, `Hero` on scan images, list item stagger/fade-in, button press feedback, skeleton/shimmer loading states.
- Full dark-mode visual QA pass across every screen — fix any contrast/legibility issues.
- Performance pass: verify no jank on list scrolling or transitions (use DevTools if available).
- **Exit criteria:** Every screen has intentional motion, both themes look equally polished, no visible jank.

## Phase 17 — Hardening: Errors, Empty States, Offline, Tests
**Goal:** The app is robust, not just feature-complete.
- Systematic empty-state and error-state pass for every screen with dynamic data (My Garden empty, Scan History empty, Weather offline, AI failure, permission denied everywhere).
- Expand automated test coverage: widget tests for key screens, unit tests for remaining use cases/repositories not yet covered.
- Crash-safety pass: wrap risky I/O (camera, file, DB, network) in proper error handling surfaced as user-friendly UI, never a raw exception or blank screen.
- **Exit criteria:** No screen crashes or shows a blank/broken state under any of: empty DB, no network, denied permissions, AI failure.

## Phase 18 — TensorFlow Lite Integration
**Goal:** Replace the mock brain with the real one, touching **only** the AI service layer.
- Add `tflite_flutter` dependency, place model asset(s), implement `TFLiteAIService implements AIService` per the exact contract in `MODEL_INTEGRATION.md`.
- Swap DI registration from `MockAIService` to `TFLiteAIService` (single line change, ideally a build-time or config-time switch so mock remains available for future dev/testing).
- Validate output shape mapping (model output → `PlantDiagnosisResult`) matches what mock produced, so no downstream (Result/Recommendation/History/Garden/TTS) code changes are needed.
- **Exit criteria:** Real on-device inference powers the scan flow with zero changes to any `presentation/` code in `result`, `recommendation`, `ai_loading`, `my_garden`, or `scan_history`.

## Phase 19 — Release Preparation
**Goal:** Store-ready build.
- App icons (adaptive icon for Android, all iOS sizes), native splash screen config matching Phase 2's branding.
- Final performance/profile pass, release build validation (`flutter build apk`/`ipa`), remove/guard any debug-only routes (e.g. Phase 1's component gallery).
- Store metadata drafts (description, screenshots plan) — content only, not submission.
- **Exit criteria:** A release build installs and runs cleanly with correct icons/splash and no debug artifacts exposed.

---

## Phase sizing note
If a phase turns out too large for one session in practice, split it (e.g. "9a — Save flow", "9b — List & detail screens") and reflect the split in `TASKS.md` — don't silently cram two sessions into one phase's checklist.
