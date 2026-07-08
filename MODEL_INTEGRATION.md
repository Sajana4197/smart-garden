# MODEL_INTEGRATION.md — AI Service Contract & Model Swap Plan

> This document defines the single most important seam in the codebase: the boundary between the UI/app logic and the AI "brain." Everything in `features/ai_loading/`, `features/result/`, `features/recommendation/`, `features/my_garden/`, and `features/scan_history/` is built against the interface defined here — **never against a concrete implementation.** Read this before touching Phase 7 (mock) or Phase 18 (real model).

---

## 1. Why this document exists

The real TensorFlow Lite plant-disease-classification model **does not exist yet** during early development. To avoid blocking UI/UX work on model availability, and to avoid a painful rewrite later, the entire app is built against a fixed abstract contract (`AIService`) from Phase 7 onward. A `MockAIService` fulfills that contract with realistic simulated behavior. When the real model is ready (Phase 18), a `TFLiteAIService` is written to fulfill the *exact same contract*, and it is swapped in via dependency injection — **no UI code changes.**

If you ever find yourself wanting to change a screen's code to accommodate "how the real model will work," stop — that need should be absorbed by the `AIService` contract or the `PlantDiagnosisResult` shape instead, updated here first, and then implemented by both `MockAIService` and (later) `TFLiteAIService` identically.

---

## 2. The Contract

Location: `lib/services/ai/ai_service.dart`

```dart
abstract class AIService {
  /// Analyzes a plant/leaf image and returns a diagnosis.
  /// Implementations may take variable time (mock simulates latency;
  /// real on-device inference has its own cost) — callers must always
  /// treat this as a potentially slow async operation and show the
  /// AI Loading UI while awaiting it.
  ///
  /// Throws [AIServiceException] on failure (corrupt image, model load
  /// failure, inference error) — never returns a null/garbage result.
  Future<PlantDiagnosisResult> analyzeImage(File imageFile);

  /// Whether this implementation is ready to serve requests
  /// (e.g. model loaded). UI may use this to show a "not ready" state.
  /// Mock always returns true immediately; TFLite implementation may
  /// need to report false until the model/interpreter is loaded.
  Future<bool> isReady();
}
```

### `AIServiceException`
```dart
class AIServiceException implements Exception {
  final String message;
  final AIServiceErrorType type;
  AIServiceException(this.message, this.type);
}

enum AIServiceErrorType {
  invalidImage,      // unreadable/corrupt file
  modelUnavailable,  // model failed to load (TFLite case) — mock never throws this
  inferenceFailed,   // generic failure during analysis
  timeout,           // took too long
}
```
The `result`/`ai_loading` presentation layer must handle **every** `AIServiceErrorType` with a distinct, user-friendly message (see `UI_GUIDELINES.md` §6 empty/error states) — never a raw exception surfaced to the user.

---

## 3. The Data Shape: `PlantDiagnosisResult`

Location: `lib/services/ai/models/plant_diagnosis_result.dart` (pure Dart domain entity — no Flutter/DB imports, per Clean Architecture rules).

```dart
class PlantDiagnosisResult {
  final String plantCommonName;       // e.g. "Tomato"
  final String? plantSpeciesLatin;    // e.g. "Solanum lycopersicum", nullable if unknown
  final String diagnosisLabel;        // e.g. "Powdery Mildew" or "Healthy"
  final bool isHealthy;               // true when diagnosisLabel == healthy case
  final double confidence;            // 0.0–1.0
  final DiagnosisSeverity severity;   // enum: none, mild, moderate, severe
  final String description;           // human-readable explanation of the finding
  final List<String> visualSymptoms;  // short bullet list, e.g. ["Yellowing leaf edges", "White powdery patches"]
  final DateTime analyzedAt;
}

enum DiagnosisSeverity { none, mild, moderate, severe }
```

This shape is what `MockAIService` produces **today** and what `TFLiteAIService` must produce **later**, exactly — this is the contract that lets Result, Recommendation, Scan History, and My Garden be written once and never touched again for the model swap.

> **Design rule:** If the real model, once available, naturally produces something this shape can't represent (e.g. multiple simultaneous findings, bounding boxes for affected regions), **extend this class with new optional/nullable fields** rather than replacing it, and update `MockAIService` to populate sensible defaults for the new fields too, so the contract never silently diverges between mock and real.

### Recommendation mapping input
`features/recommendation/` domain logic keys off `diagnosisLabel` + `severity` (see Phase 8). Any new `diagnosisLabel` value introduced by the real model **must** have a corresponding entry added to the recommendation content bank, or the Recommendation screen will hit its "unknown diagnosis" fallback state (which must always exist and never crash — see `UI_GUIDELINES.md` empty-state rules).

---

## 4. `MockAIService` Design (Phase 7)

Location: `lib/services/ai/mock_ai_service.dart`

**Behavior requirements:**
1. **Simulated latency:** `await Future.delayed(Duration(milliseconds: 1500 + Random().nextInt(1500)))` (~1.5–3s) so the AI Loading UI is properly exercised during development — never resolve instantly.
2. **Realistic variety:** draw from a local curated result bank (`mock_result_bank.dart` or a bundled JSON asset) covering, at minimum:
   - 1 "Healthy" result (multiple plant species)
   - 4–6 distinct disease/issue results across varying severities (mild/moderate/severe) and at least 3 different plant species, so Recommendation content (Phase 8) has real variety to map against.
3. **Deterministic test hook:** support an optional constructor parameter or debug flag to force a specific result (by index or label) for widget/integration testing, without affecting default random behavior in normal app use.
4. **Occasional simulated failure (optional but recommended):** a small configurable probability of throwing `AIServiceException(type: inferenceFailed)` so error-state UI (Phase 17) gets exercised honestly rather than assumed to work. Default this probability to `0` in normal runs and only enable via an explicit debug toggle, so it never surprises a demo.
5. `isReady()` always resolves `true` immediately — the mock has no loading phase.

**Non-requirements:** the mock does **not** need to actually inspect image content/pixels — it may ignore the `imageFile` argument's contents entirely and just pick from the result bank (optionally using the file's bytes length or a hash as a pseudo-random seed for variety across repeated scans of the "same" image, if desired for demo realism).

---

## 5. `TFLiteAIService` Design (Phase 18 — future)

Location: `lib/services/ai/tflite_ai_service.dart` — **do not create this file before Phase 18.**

When Phase 18 begins:
1. Add `tflite_flutter` (and `image` package if manual preprocessing/resizing is needed) to `pubspec.yaml`.
2. Place the trained `.tflite` model file (and label map, if separate) under `assets/models/`, registered in `pubspec.yaml`.
3. Implement `TFLiteAIService implements AIService`:
   - `isReady()` reflects whether the `Interpreter` has finished loading (load it lazily on first use or eagerly at app start behind a loading gate — decide based on model load time measured at integration time).
   - `analyzeImage()`: decode image → preprocess (resize/normalize to the model's expected input tensor shape) → run inference → map raw output tensor (class probabilities) → a `PlantDiagnosisResult` using the **same** label/severity/description content bank structure the mock used (reuse or extend `mock_result_bank.dart`'s descriptive content, keyed by the model's actual output classes, rather than inventing new copy at integration time).
   - Wrap all steps in try/catch mapping to the appropriate `AIServiceErrorType`.
4. Run inference off the UI thread if it's not trivially fast (e.g. via `compute()` or an isolate) — this must not jank scrolling/animations elsewhere in the app if inference happens to overlap with other activity.
5. **Do not modify** any file under `features/result/`, `features/recommendation/`, `features/ai_loading/presentation/`, `features/my_garden/`, or `features/scan_history/` as part of this phase. If such a change feels necessary, it means the contract in this document is incomplete — update §3 first, update `MockAIService` to match, and only then implement `TFLiteAIService` against the revised contract.

---

## 6. Dependency Injection / Swap Mechanism

Decided in Phase 0/7 and recorded in `CLAUDE.md` → Locked Decisions, but the shape is:

```dart
// core/di/service_locator.dart (or wherever DI is wired)
Provider<AIService>(
  create: (_) => kUseRealAIModel
      ? TFLiteAIService()
      : MockAIService(),
),
```

Where `kUseRealAIModel` is a single build-time or config-level flag (e.g. `--dart-define=USE_REAL_AI_MODEL=true`, or a simple `const bool` flipped once Phase 18 lands). Keep `MockAIService` in the codebase permanently after Phase 18 (don't delete it) — it remains valuable for widget/integration tests and for development without a device capable of running the real model.

---

## 7. Testing Expectations

- Every widget/integration test that exercises the scan flow (`ai_loading`, `result`, `recommendation`) should inject `MockAIService` (optionally with the deterministic test hook from §4.3) via DI/provider overrides — never depend on real timing or randomness in tests.
- When `TFLiteAIService` is added in Phase 18, add a small dedicated test suite for it alone (model loads, produces a well-formed `PlantDiagnosisResult` for a known sample image) — but UI-level tests continue to use the mock for speed and determinism.

---

## 8. Quick Reference — What Never Changes After Phase 7

- `AIService` abstract interface (§2)
- `AIServiceException` / `AIServiceErrorType` (§2)
- `PlantDiagnosisResult` shape (§3) — extend-only, never break
- Every `presentation/` widget that consumes an `AIService` via DI

## What Is Allowed to Change at Phase 18
- The concrete class implementing `AIService`
- The DI registration (one flag/line)
- The content bank backing descriptions/recommendations (extended, not replaced, to cover any new real-model classes)
