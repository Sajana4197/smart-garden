# UI_GUIDELINES.md — SmartGarden AI Design System

> Defines the visual and motion language so every screen built across many sessions looks like it came from the same team. Implementation of this spec happens in Phase 1 (`core/theme/`, `core/widgets/`); every later phase must use it rather than inventing new styles ad hoc.

---

## 1. Design Principles

1. **Premium, calm, organic.** This is a plant-care app — the palette and motion should feel natural and reassuring, not clinical or gamified.
2. **Material 3, not Material 2 with rounded corners.** Use real M3 components (`FilledButton`, `NavigationBar`, `Card` with M3 elevation tokens, `ColorScheme.fromSeed`), M3 elevation/tonal surfaces, and dynamic-color-ready structure (even if dynamic color itself isn't wired up).
3. **Content-first.** Photos of plants are the hero content on Result, Preview, My Garden, and Scan History — chrome should recede.
4. **One motion language.** Reuse the same transition/curve/duration vocabulary everywhere (see §5) instead of ad hoc animations per screen.
5. **Dark mode is not an afterthought.** Every color, elevation, and image-overlay decision is made for both themes simultaneously.

---

## 2. Color System

Generate both schemes from a single seed color using `ColorScheme.fromSeed(seedColor: ..., brightness: ...)` so M3 tonal relationships stay correct — do not hand-pick every tone manually.

- **Seed color:** a natural, confident green that reads as "healthy plant" — target hue around `#2E7D32`–`#3D8B4A` range. Finalize the exact hex in Phase 1 and record it in `CLAUDE.md` → Locked Decisions once chosen.
- **Secondary accent:** a warm, earthy complement (soil/terracotta tone) for tertiary/status accents — let `fromSeed` derive it, only override if the generated tertiary feels off-brand.

### Semantic status colors (beyond the generated scheme)
These map to plant health severity and must be defined explicitly (M3's generated scheme doesn't include them) with light/dark variants each:

| Status | Purpose | Light | Dark | Notes |
|---|---|---|---|---|
| `healthy` | no issues detected | deep green | soft green | pairs with a leaf/check icon |
| `mild` | minor issue, low urgency | amber/yellow | muted amber | |
| `moderate` | needs attention soon | orange | muted orange | |
| `severe` | urgent issue | red (not pure `#FF0000`) | muted red | never used for anything except plant-health severity — don't reuse for generic errors |

Generic error/destructive states use the M3 `error`/`onError`/`errorContainer` roles from the generated scheme, kept distinct from the `severe` plant-health color even if visually similar, so the two concepts stay semantically separate in code (`AppColors.severe` vs `Theme.of(context).colorScheme.error`).

### Surfaces
Use M3 surface tonal elevation (`surface`, `surfaceContainerLow/Low/High/Highest`) for card layering instead of manual `Colors.grey[...]` or hardcoded shadows. Do not use `Colors.white`/`Colors.black` directly anywhere in feature code — always go through `Theme.of(context).colorScheme` or the app's `ThemeExtension`.

### Image overlays
Photos (scan hero images, plant thumbnails) sit on both light and dark backgrounds. Any text/icon overlaid on a photo must use a scrim (`Container` with a gradient `Colors.black.withOpacity(...)`) rather than relying on theme text color, since photo content isn't theme-aware.

---

## 3. Typography

- Base on Material 3's default type scale (`TextTheme` with `displayLarge` … `labelSmall`) rather than inventing custom sizes per screen.
- Font: a single modern, highly legible sans-serif for both headings and body (e.g. a Google Font such as **Inter**, **Manrope**, or **Plus Jakarta Sans** — pick one in Phase 1 and lock it in `CLAUDE.md`; do not mix multiple families). Bundle via `google_fonts` package or local asset — decide and record which.
- Usage mapping:
  - `displaySmall`/`headlineMedium` — screen-level hero headings (onboarding slide titles, Result diagnosis name).
  - `titleLarge`/`titleMedium` — section headers, card titles, app bar titles.
  - `bodyLarge`/`bodyMedium` — primary content text, descriptions, recommendations.
  - `labelLarge`/`labelMedium` — buttons, badges, chips, metadata (dates, confidence %).
- Never hardcode `TextStyle(fontSize: ...)` inline in a feature screen — always pull from `Theme.of(context).textTheme` (optionally `.copyWith` for color/weight only).

---

## 4. Spacing, Sizing & Shape

- **Spacing scale (4pt base):** `4, 8, 12, 16, 24, 32, 48, 64`. Define as constants in `core/constants/app_spacing.dart` (e.g. `AppSpacing.sm = 8`, `.md = 16`, `.lg = 24`, etc.) — no magic numbers in widget code.
- **Screen padding:** default horizontal screen padding is `16` (mobile) with card content padding of `16`–`20`.
- **Corner radius:** M3-style large radii for cards/sheets — `12` for small components (chips, badges), `16` for cards, `24`+ for bottom sheets/modals and the AI Loading container. Keep consistent per component type across all screens.
- **Elevation:** prefer tonal elevation (surface color shift) over drop shadows per M3; reserve actual shadow elevation for floating/temporary elements (FAB, bottom sheets, snackbars).
- **Touch targets:** minimum `48x48` for any tappable element, even icon-only buttons.
- **Images:** plant thumbnails use a consistent aspect ratio (`1:1` for grid thumbnails in My Garden, `4:3` or `16:9` for hero images on Result/Preview — pick one per context and keep it consistent across all screens using that context).

---

## 5. Motion

One shared motion vocabulary, implemented as reusable helpers in `core/theme/` or `core/widgets/` (e.g. `AppTransitions`, `AppDurations`, `AppCurves`) — features must reuse these, not invent per-screen durations/curves.

| Token | Value | Usage |
|---|---|---|
| `AppDurations.fast` | ~150ms | icon toggles, button press feedback, small state flips |
| `AppDurations.medium` | ~250–300ms | card expand/collapse, `AnimatedSwitcher` content swaps, list item entrance |
| `AppDurations.slow` | ~400–500ms | full-screen transitions, Hero animations, onboarding slide transitions |
| `AppCurves.standard` | `Curves.easeInOutCubic` (or M3 emphasized curve) | default for most transitions |
| `AppCurves.emphasized` | M3 emphasized decelerate/accelerate pair | page-level route transitions |

### Specific motion moments
- **Route transitions:** consistent shared-axis or fade-through pattern app-wide (pick one primary pattern in Phase 1; don't mix multiple transition styles across features).
- **Camera/Gallery → Preview → Result:** the captured/selected image should visually persist via `Hero` across these screens so the photo feels continuous, not reloaded.
- **AI Loading screen:** a distinct, branded looping animation (e.g. pulsing leaf, scanning line sweep) — this is a signature moment, worth extra polish (Lottie is acceptable here if a suitable asset is available; otherwise a well-crafted `AnimationController`-based custom animation).
- **List entrances** (My Garden grid, Scan History list, Recommendation steps): subtle staggered fade+slide-in on first build, not on every rebuild.
- **Status changes** (health badge color, confidence bar fill): animate value changes (`TweenAnimationBuilder`/`AnimatedContainer`) rather than snapping instantly.
- **Micro-feedback:** buttons/cards get a subtle scale-down on press (`AnimatedScale` ~0.97) for tactile feel.

Avoid: gratuitous animation on every widget, animations that block user input, anything over ~600ms for a routine interaction.

---

## 6. Component Notes (M3-specific)

- **Navigation:** `NavigationBar` (M3 bottom nav) for the primary shell on mobile; consider `NavigationRail` if a tablet/desktop breakpoint is ever in scope (not required initially).
- **Buttons:** `FilledButton` for primary actions (Confirm, Save, Scan Now), `FilledButton.tonal` or `OutlinedButton` for secondary actions, `TextButton` for tertiary/dismissive actions (Skip, Cancel). Avoid raw `ElevatedButton` with manual styling — use M3 button variants as-is.
- **Cards:** `Card` with `Card.filled`/`Card.outlined` variants per M3, matched consistently by context (e.g. all dashboard summary cards use the same variant).
- **Badges/Chips:** severity/status uses a small pill badge (custom `AppStatusBadge` widget built once in Phase 1, reused everywhere status appears: Home, My Garden, Scan History, Plant Health Dashboard).
- **Bottom sheets:** used for the Camera/Gallery choice, and any short contextual action set — `showModalBottomSheet` with M3 rounded-top shape from the shape scale above.
- **Snackbars:** M3 floating snackbar for lightweight confirmations (e.g. "Saved to My Garden"); never use snackbars for critical errors that need explicit acknowledgment — use a dialog instead.
- **Empty/Error states:** every screen with dynamic data must use the shared `EmptyStateWidget`/`ErrorStateWidget` from `core/widgets/` (built in Phase 1) rather than a bespoke one-off per screen.

---

## 7. Dark Mode Rules

- Every new widget must be visually verified in **both** themes before a phase is considered done — this is called out explicitly in each `TASKS.md` phase's exit criteria.
- Never hardcode a color that isn't theme-aware, including inside `BoxShadow`, `Divider`, `Icon(color: ...)`, or gradient stops — always derive from `ColorScheme` or an explicit light/dark pair in a `ThemeExtension`.
- Status bar / system nav bar brightness must follow the active theme (`SystemUiOverlayStyle` set from theme brightness, not hardcoded).
- Images/photos don't change between themes, but any chrome around them (cards, overlays, scrims) must adapt — see §2 "Image overlays."

---

## 8. Accessibility

- All interactive elements have a `Semantics`/`tooltip`/accessible label — icon-only buttons are never unlabeled.
- Respect `MediaQuery.textScaler` — layouts must not break/clip at larger accessibility text sizes (test at 1.3x–1.5x scale periodically, especially on Result/Recommendation text-heavy screens).
- Color is never the *only* signal for status — severity badges pair color with an icon and a text label (e.g. not just a red dot).
- Sufficient contrast: rely on M3-generated tonal pairs (`onSurface` on `surface`, etc.) which are contrast-safe by construction; if a custom color (severity palette) is used for text, manually verify contrast ≥ 4.5:1.

---

## 9. What NOT to do

- Don't hardcode hex colors inline in feature widgets — always go through the theme.
- Don't create a new button/card/badge style per screen — extend the shared `core/widgets/` components, or add a new shared component if a genuinely new pattern is needed (and document it here).
- Don't mix multiple font families or invent one-off `TextStyle`s outside the type scale.
- Don't ship a screen that only looks correct in one theme.
- Don't add animation that can't be interrupted/skipped (especially the AI Loading screen — user should still be able to navigate back).
