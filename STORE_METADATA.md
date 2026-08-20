# STORE_METADATA.md — Store Listing Draft (Phase 19)

> Content draft only — not a submission. Written for Google Play's listing fields (character limits noted); the same copy adapts directly to the App Store with minor trimming (App Store's subtitle/promotional text limits are similar in spirit, tighter in a couple of fields — noted inline).

---

## App name
**SmartGarden AI**

## Short description (Google Play: max 80 characters)
```
Diagnose plant diseases from a photo. Track your garden. Grow smarter.
```
(71 characters)

## App Store subtitle (max 30 characters)
```
AI plant health & garden care
```
(29 characters)

## Full description (Google Play: max 4000 characters)

```
SmartGarden AI turns your phone into a plant doctor and garden journal — snap a photo of any leaf and get an instant, on-device health diagnosis, then track every plant you own in one place.

📸 DIAGNOSE IN A SNAP
Point your camera at a leaf and SmartGarden AI identifies the plant and flags common diseases, pests, and nutrient issues on the spot — no internet connection required. Every scan runs entirely on your device, so your photos never leave your phone.

🌱 YOUR GARDEN, TRACKED
Save any scan to build a living record of your plants. Watch each one's health trend over time, revisit past diagnoses, and know at a glance which plants need attention today.

💡 CARE THAT ACTUALLY HELPS
Every diagnosis comes with plain-language care guidance — watering, light, and treatment steps tailored to what's actually wrong, not generic plant-care advice.

🔊 LISTEN, DON'T JUST READ
Busy hands in the garden? Tap Read Aloud and SmartGarden AI speaks your plant's diagnosis and care steps out loud.

☀️ WEATHER-AWARE
See today's local weather right on your dashboard, so you know when it's time to water — or when nature's about to do it for you.

📊 GARDEN HEALTH AT A GLANCE
The Plant Health Dashboard rolls every tracked plant into one view: what's healthy, what's struggling, and what's improved since your last scan.

🌙 BUILT TO FIT YOUR DAY
Full dark mode support, a clean Material You design, and an interface that gets out of your way.

Whether you're keeping a single houseplant alive or managing a full garden, SmartGarden AI gives you the same kind of instant, informed care a plant expert would.

Note: plant identification and disease diagnosis are provided as guidance and are not a substitute for professional agricultural or horticultural advice for high-value or commercial crops.
```
(~1,750 characters — well under the 4000 limit, deliberately; leaves room to expand once real user feedback/keywords are known rather than front-loading keyword-stuffed copy)

## App Store promotional text (max 170 characters, editable without a new build)
```
Snap a photo, get an instant plant health diagnosis — on-device, no internet needed. Track your whole garden and get care tips that actually match what's wrong.
```
(162 characters)

## Keywords (App Store, max 100 characters, comma-separated, no spaces)
```
plant,garden,disease,leaf,diagnosis,health,care,gardening,houseplant,ai,scanner,identify
```

## Category
- **Primary:** Lifestyle (Google Play) / Lifestyle (App Store)
- **Secondary consideration:** Health & Fitness or Education — Lifestyle is the better primary fit given the app's actual use pattern (personal garden tracking + daily check-ins), not a fitness or curriculum use case.

## Content rating
No user-generated content, no social features, no in-app purchases, no ads, no account/login required. Should qualify for the lowest content-rating tier on both stores (e.g. Google Play "Everyone", Apple "4+").

## Privacy notes (relevant for the store's data-safety questionnaire, not the listing copy itself)
- Scan photos are processed **entirely on-device** (TFLite model, no upload) — the AI diagnosis feature collects/transmits no photo data.
- Weather feature calls OpenWeatherMap using approximate/precise device location (user-permission-gated); no other network calls.
- No analytics/tracking SDKs, no ads SDK, no account system, no data leaves the device except the weather API call above.

---

## Screenshot plan

Google Play requires 2–8 screenshots per supported device class (phone, 7" tablet, 10" tablet if applicable); App Store requires per device size class (6.9", 6.5", 5.5" for iPhone, plus iPad sizes if universal). This app is phone-only per `CLAUDE.md`'s "Platforms scaffolded" decision, so only phone-size screenshots are needed for launch.

Planned shot order (tells a story: diagnose → track → understand → act):

| # | Screen | What to show | Why it's here |
|---|---|---|---|
| 1 | **Home Dashboard** | Real weather card, real Recent Activity with a couple of scanned plants, daily tip visible | First impression — shows the app has real, useful content, not an empty shell |
| 2 | **Result screen** (a disease diagnosis, moderate severity) | A real diagnosis with description + visual symptoms + confidence, on a real leaf photo | The core value prop — proves the "instant diagnosis" claim visually |
| 3 | **Recommendation screen** | Watering/light advice + treatment steps for that same diagnosis | Shows the app doesn't just diagnose, it tells you what to do |
| 4 | **My Garden** (grid view, several saved plants, mixed health statuses) | A populated garden grid with status badges | Sells the "tracking over time" value prop |
| 5 | **Plant Health Dashboard** | Health distribution + a "needs attention" plant highlighted | Shows the aggregate/at-a-glance value for users with several plants |
| 6 | **Result screen — Healthy case** | A "Healthy" diagnosis, green/positive framing | Balances screenshot #2 (disease) so the store listing doesn't read as fear-based marketing |
| 7 | **Settings — Dark mode** (same Home screen as #1, dark theme) | Same real content, dark mode | Demonstrates full theme support without needing a dedicated screen |

**Not planned as screenshots (deliberately):** Onboarding, Splash, Camera/Preview (transient/permission-gated screens that don't sell on their own), Scan History list (redundant with My Garden's story), Component Gallery (debug-only, excluded from release builds per this phase's own work).

**Capture requirements before these can actually be taken:** real (not synthetic/placeholder) scan data in My Garden/Scan History so the screenshots don't look like an empty demo — populate a few real plants via real scans first, on a device/emulator with `USE_REAL_AI_MODEL=true` so the diagnoses shown are genuine, not `MockAIService` placeholder copy.

---

*(This is a content draft for Phase 19 per ROADMAP.md — "Store metadata drafts (description, screenshots plan) — content only, not submission." Actual screenshot capture and store-listing submission are separate, later steps.)*
