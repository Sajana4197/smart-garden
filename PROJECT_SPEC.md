# PROJECT_SPEC.md — SmartGarden AI

> Source of truth for **what** the product is. For **how we build it session-to-session**, see `CLAUDE.md`. For **when** things get built, see `ROADMAP.md` and `TASKS.md`.

---

## 1. Product Vision

**SmartGarden AI** is a premium, offline-first Flutter mobile app that helps home gardeners and plant owners diagnose plant health issues from a photo, track their garden over time, and receive actionable, localized care recommendations — enhanced with live weather data and spoken (TTS) guidance.

The app must feel like a polished, funded consumer product: smooth Material 3 UI, tasteful motion, full dark mode, and zero jank — even though the "AI" is a mock during early development.

### Guiding principles
1. **UI is permanent, AI is swappable.** Every screen is built against an abstract `AIService` contract. The mock implementation and the future TensorFlow Lite implementation are interchangeable with **zero UI changes**.
2. **Offline-first.** Core flows (scan, view results, browse garden, scan history, tips) must work with no network connection. Only weather requires connectivity, and it must fail gracefully.
3. **Clean Architecture, strictly layered.** Presentation never talks to data sources directly; it goes through domain use cases and repository interfaces.
4. **Small, resumable increments.** Every phase in `ROADMAP.md` is scoped to fit in a single Claude Code session and leaves the app in a compilable, runnable state.

---

## 2. Tech Stack

| Concern | Choice |
|---|---|
| Framework | Flutter (stable channel) |
| Language | Dart (null-safe) |
| Design system | Material 3 (`useMaterial3: true`) |
| Architecture | Clean Architecture (presentation / domain / data / core) |
| State management | `provider` (ChangeNotifier-based) |
| Local persistence | SQLite via `sqflite` (+ `path_provider`, `path`) |
| Camera | `camera` plugin (live capture) |
| Gallery | `image_picker` (gallery selection) |
| Image handling | `path_provider`, local file copy into app sandbox storage |
| Weather | REST call to a weather API (OpenWeatherMap-compatible) via `http` or `dio` |
| Text-to-Speech | `flutter_tts` |
| On-device AI (future) | `tflite_flutter` (integrated in a later phase; **not** used yet) |
| Dependency injection | Lightweight manual DI via `provider`'s `MultiProvider` + a `ServiceLocator` (or `get_it` — decide in Phase 0, document the decision in `CLAUDE.md`) |
| Routing | `Navigator 2.0`-lite via named routes or `go_router` (decide in Phase 0) |
| Animations | Implicit animations, `AnimatedSwitcher`, `Hero`, `Lottie` (optional, for AI loading state) |
| Testing | `flutter_test`, `mockito`/`mocktail` for repository & service mocking |
| Linting | `flutter_lints` |

> **Note:** Exact package versions are not pinned in this document. When Phase 0 runs, resolve to the latest stable versions compatible with the installed Flutter SDK and record the resolved versions in `CLAUDE.md` under "Locked Decisions."

---

## 3. Architecture Overview

```
lib/
├── main.dart
├── app.dart                     # MaterialApp, theme, routing, top-level providers
├── core/
│   ├── constants/                # app-wide constants, asset paths, durations
│   ├── theme/                    # ColorScheme, TextTheme, ThemeData (light/dark)
│   ├── routing/                  # route names, route generator
│   ├── di/                       # service locator / provider wiring
│   ├── errors/                   # Failure types, exceptions, Result wrapper
│   ├── utils/                    # formatters, validators, extensions
│   └── widgets/                  # shared/reusable widgets (buttons, cards, loaders)
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── home_dashboard/
│   ├── plant_health_dashboard/
│   ├── camera/
│   ├── gallery/
│   ├── preview/
│   ├── ai_loading/
│   ├── result/
│   ├── recommendation/
│   ├── my_garden/
│   ├── scan_history/
│   ├── weather/
│   ├── daily_tips/
│   ├── voice/
│   ├── settings/
│   └── about/
└── services/
    └── ai/
        ├── ai_service.dart        # abstract contract (THE key seam)
        ├── mock_ai_service.dart   # mock implementation (active today)
        └── tflite_ai_service.dart # future real implementation (added in Phase 18)
```

### Per-feature internal structure (Clean Architecture)
Each entry under `features/<feature_name>/` follows:

```
<feature_name>/
├── data/
│   ├── datasources/     # local (sqflite) / remote (http) data sources
│   ├── models/          # DTOs — extend domain entities, add fromJson/toMap etc.
│   └── repositories/    # concrete repository implementations
├── domain/
│   ├── entities/         # pure Dart business objects, no Flutter/DB imports
│   ├── repositories/      # abstract repository interfaces
│   └── usecases/          # single-purpose classes, one `call()` method each
└── presentation/
    ├── providers/         # ChangeNotifier state holders
    ├── screens/           # full-page widgets (route targets)
    └── widgets/           # feature-local reusable widgets
```

### Dependency rule
`presentation` → `domain` ← `data`. Domain has **no** dependency on Flutter, sqflite, http, or any package — it is pure Dart. `data` implements domain interfaces. `presentation` only calls `domain` use cases via providers, never `data` directly.

### Cross-feature contract: AIService
`services/ai/ai_service.dart` defines the single seam through which **all** plant diagnosis happens:

```dart
abstract class AIService {
  Future<PlantDiagnosisResult> analyzeImage(File imageFile);
}
```

- `MockAIService` (active now) simulates latency and returns realistic, varied canned/randomized results.
- `TFLiteAIService` (added in Phase 18) implements the same contract using an on-device `.tflite` model.
- The `result`, `recommendation`, and `ai_loading` features depend **only** on `AIService` (injected via provider/DI), never on the concrete implementation.
- See `MODEL_INTEGRATION.md` for the full contract, data shapes, and swap procedure.

---

## 4. Feature Inventory

Each feature below states its purpose, primary data dependencies, and its relationship to the AIService seam. Full acceptance criteria live in `TASKS.md` under the corresponding phase.

| # | Feature | Purpose | Data sources |
|---|---|---|---|
| 1 | **Splash** | Branded launch screen, warms up DI/theme, routes to onboarding or home based on first-launch flag | local prefs (`shared_preferences`) |
| 2 | **Onboarding** | 3–4 slide intro to app value prop, permission priming (camera/gallery/location for weather) | local prefs |
| 3 | **Home Dashboard** | Central hub: greeting, weather summary card, daily tip card, quick-scan CTA, recent garden/scan preview | weather service, garden repo, scan history repo, tips |
| 4 | **Plant Health Dashboard** | Aggregated health overview across all saved plants (status counts, trends, alerts) | garden repo, scan history repo |
| 5 | **Camera** | Live camera capture of a plant/leaf for diagnosis | `camera` plugin |
| 6 | **Gallery** | Pick an existing photo for diagnosis | `image_picker` |
| 7 | **Preview** | Confirm/crop/retake captured or picked image before analysis | local file |
| 8 | **AI Loading Animation** | Branded, animated "analyzing" state while `AIService.analyzeImage` runs | AIService (async) |
| 9 | **Result Screen** | Displays diagnosis: plant/disease identification, confidence, severity, description | AIService result |
| 10 | **Recommendation Engine** | Maps a diagnosis result to actionable care steps (watering, sunlight, treatment) | rule-based domain logic keyed off result |
| 11 | **My Garden** | User's saved plant collection (CRUD): add from a scan, name, photo, species, notes | SQLite (`plants` table) |
| 12 | **Scan History** | Chronological log of every scan performed, linkable back to My Garden entries | SQLite (`scans` table) |
| 13 | **Weather Integration** | Current conditions + short forecast for the user's location, used to contextualize recommendations | Weather REST API |
| 14 | **Daily Plant Tips** | Rotating daily care tip, sourced from a local curated tip bank | local JSON/asset + prefs (day-of-tip tracking) |
| 15 | **Voice Recommendation** | Reads result/recommendation aloud via TTS, with play/pause/stop controls | `flutter_tts` |
| 16 | **Settings** | Theme mode (light/dark/system), units (°C/°F), TTS voice/rate, data management (clear history), notifications toggle | `shared_preferences` |
| 17 | **About** | App version, credits, licenses, privacy/terms links, contact | static |

### Primary user flow
```
Splash → (first run) Onboarding → Home Dashboard
Home Dashboard → Camera | Gallery → Preview → AI Loading → Result → Recommendation
Result/Recommendation → (save) My Garden entry created
Home Dashboard → My Garden / Scan History / Plant Health Dashboard / Settings / About
Result/Recommendation → Voice Recommendation (TTS playback)
```

---

## 5. Data Model (SQLite)

> Exact schema/migrations are finalized in Phase 4, but the target shape is:

**`plants`** (My Garden entries)
| column | type | notes |
|---|---|---|
| id | INTEGER PK AUTOINCREMENT | |
| name | TEXT | user-given nickname |
| species | TEXT NULLABLE | identified or user-entered |
| image_path | TEXT | local sandbox path |
| date_added | TEXT (ISO8601) | |
| last_scan_id | INTEGER NULLABLE | FK → scans.id |
| notes | TEXT NULLABLE | |
| status | TEXT | derived health status, e.g. `healthy`/`warning`/`critical` |

**`scans`** (Scan History)
| column | type | notes |
|---|---|---|
| id | INTEGER PK AUTOINCREMENT | |
| plant_id | INTEGER NULLABLE | FK → plants.id (null if not saved to a plant) |
| image_path | TEXT | local sandbox path |
| diagnosis_label | TEXT | e.g. "Powdery Mildew" |
| confidence | REAL | 0.0–1.0 |
| severity | TEXT | `none`/`mild`/`moderate`/`severe` |
| raw_result_json | TEXT | full serialized `PlantDiagnosisResult` for replay/debug |
| scanned_at | TEXT (ISO8601) | |

**`daily_tip_state`** (small key-value or single-row table)
| column | type | notes |
|---|---|---|
| last_shown_date | TEXT | ISO date |
| last_tip_id | TEXT | id into the local tip bank |

DB versioning: use `sqflite` `onCreate`/`onUpgrade` with an explicit `schemaVersion` constant in `core/constants`. All schema changes must bump this version and add a migration step — never silently alter columns.

---

## 6. Non-Functional Requirements

- **Performance:** 60fps scroll/animation target; image analysis must never block the UI thread (run via `async`/isolate if the future real model is heavy).
- **Offline resilience:** Weather failures must degrade gracefully (cached last-known value + "offline" indicator), never crash or block the scan flow.
- **Permissions:** Camera, photo library, and location (for weather) must be requested contextually (at point of use), with clear rationale UI and graceful denial handling (no dead-end screens).
- **Accessibility:** Minimum tap target 48x48, text scaling support, semantic labels on icons/images, sufficient color contrast in both themes.
- **Dark mode:** Full parity with light mode — no screen is light-only or dark-only.
- **Privacy:** All images and scan data stay on-device unless/until a future cloud feature is explicitly scoped. No image leaves the device in the current spec.
- **Localization-ready:** Strings centralized (not necessarily translated yet) so i18n can be added later without a rewrite.

---

## 7. Explicit Out-of-Scope (for now)

- Real TensorFlow Lite model integration (deferred to Phase 18; interface is built now).
- Cloud sync / multi-device / user accounts.
- Social features (sharing, community).
- Monetization (ads, IAP, subscriptions).
- Push notifications backend (local notifications only, if any, and only if scheduled in roadmap).

---

## 8. Related Documents

- `CLAUDE.md` — session continuity, conventions, locked decisions, current status.
- `ROADMAP.md` — phased delivery plan.
- `TASKS.md` — granular, checkbox-level task tracker mirroring the roadmap.
- `UI_GUIDELINES.md` — Material 3 design system: color, type, spacing, motion, component specs.
- `MODEL_INTEGRATION.md` — `AIService` contract, mock behavior, and the future TFLite swap procedure.
