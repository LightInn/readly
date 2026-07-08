# Readly Roadmap — v3.2 and beyond

A multi-week improvement plan for Readly (personal kcal tracker + meal maker + article
summarizer). Written so that **each task card can be dispatched to an independent agent**:
every card carries its own context, the files involved, and acceptance criteria.

## Product principles (read before touching anything)

1. **Sliders are estimates, not scales.** Every quantity (eaten / used / remaining) is a
   fraction of a package or a number of units — never ask for exact grams in a text field.
   Reference implementation: `lib/widgets/log_portion_sheet.dart`.
2. **Sober but colorful.** Sepia/pale-maroon seed (`0xFF96604A`, Material 3 vibrant
   variant). Semantic colors stay: stock gauges green/amber/red, per-meal-type accents
   (`lib/data/meal_type.dart`). No redesigns; add color through accents.
3. **Everything on-device.** No accounts, no backend. Drift/SQLite is the source of truth;
   UI consumes reactive streams via Riverpod `StreamProvider`s (`lib/providers.dart`).
4. **Low effort above all.** The user is lazy (his words). Every flow should be
   completable in 1–3 taps. Cross-feature shortcuts (kitchen→track, groceries→kitchen)
   beat new screens.
5. **AI is BYOK OpenAI** (`gpt-5-nano` through `dart_openai`). gpt-5 models reject
   `temperature` and `max_tokens` — never pass them. Structured outputs use
   `json_schema` (see `lib/data/services/ai_service.dart`).
6. **UI language is English**; the user writes feedback in French. Target device: Android.

## Conventions for agents

- State: Riverpod 3, no codegen. DB: drift; schema bumps need a migration in
  `lib/data/db/database.dart` + `dart run build_runner build --delete-conflicting-outputs`.
- Quality gate before finishing any task: `flutter analyze` (0 issues), `flutter test`
  (all green), `dart format lib test`, `flutter build apk --debug` compiles.
  Release signing needs the user's `android/key.properties` — debug build is the CI proxy.
- Add/extend tests beside the code you touch (`test/` mirrors `lib/`).
- Riverpod gotcha: never `ref.invalidate()` a provider from inside a notifier that the
  provider watches (circular-dependency crash).

## Weak points (honest assessment, 2026-07)

| # | Weakness | Impact | Addressed by |
|---|----------|--------|--------------|
| W1 | Track shows **today only** — no history, no trends, no way to check yesterday | Can't learn from behavior | R-10, R-11, R-13 |
| W2 | **Deletes are irreversible** (swipe = gone) | Data-loss anxiety | R-01 |
| W3 | **Macros stored but unused** (proteins/carbs/fats sit in PantryItems, never shown) | Half the nutrition story missing | R-12 |
| W4 | **Silos between tabs**: buying groceries doesn't fill the kitchen; kitchen doesn't nudge the tracker | Manual double entry | R-02, R-03, R-21 |
| W5 | **No offline story**: OFF lookups fail without network, nothing cached | Scans die in the supermarket basement | R-25 |
| W6 | **Data lives in one SQLite file with no backup** — phone dies, data dies | Total loss risk | R-30 |
| W7 | Scanner has **no manual fallback** for damaged/unreadable barcodes | Dead end in a core flow | R-04 |
| W8 | Perishable flag exists but there is **no expiry pressure** (no dates, no nudges) | Food waste continues | R-02, R-20 |
| W9 | "I made it" logs the **full recipe kcal** even if you ate half | Overstated intake | R-23 |
| W10 | AI knows the kitchen but **meal suggestions ignore the time of day** | Dinner ideas at breakfast | R-24 |
| W11 | No onboarding/tips — features like unit-tracking or filters are **discoverable only by accident** | Features unused | R-31 |
| W12 | Theme follows system only; **no manual light/dark choice** | Minor comfort | R-33 |

## Phases

Sizes: S ≈ ½ day · M ≈ 1–2 days · L ≈ 3+ days. Priorities: P1 do first, P2 next, P3 nice.

---

### Phase 1 — Quick wins & flow glue (week 1)

#### R-01 · Undo for destructive actions — S · P1 ✅ (done 2026-07)
Swipe-deletes (consumption entries, shopping items) and pantry deletes show a snackbar
with an **Undo** action that re-inserts the row (new id is fine; keep original timestamps).
Files: `track_page.dart`, `kitchen_page.dart`, `groceries_page.dart`.
Accept: delete → tap Undo → item is back with same data; snackbar auto-dismisses.

#### R-02 · "Eat soon" perishables card on Track — S · P1 ✅ (done 2026-07)
Track shows, under the kcal header, a tinted card listing perishable, non-finished pantry
items as chips. Tapping a chip runs the shared eat-flow (portion slider → log + stock
decrement). Extract the eat-flow (sheet+log+decrement, currently in kitchen's `_eatSome`)
into a shared helper so Track/Kitchen/future callers reuse it.
Files: `track_page.dart`, `log_portion_sheet.dart` (helper), `kitchen_page.dart` (reuse).
Accept: perishable item appears as chip; tap → sheet → logged + stock reduced; card hidden
when no perishables.

#### R-03 · Groceries → Kitchen hand-off — M · P1 ✅ (done 2026-07)
Checking off a shopping item offers "Add to kitchen": if a pantry item matches the name
(case-insensitive) → refill it to 100%; otherwise open the pantry add-sheet prefilled with
the item's name. Files: `groceries_page.dart`, `kitchen_page.dart` (sheet gains an
`initialName` param). Accept: check item → snackbar action → pantry updated/created.

#### R-04 · Manual barcode entry — S · P1 ✅ (done 2026-07)
Scanner page gets a keyboard fallback (bottom field "…or type the barcode" + submit) that
pops the same way a scan does. Files: `widgets/scanner_page.dart`.
Accept: typing 13 digits + submit behaves exactly like a successful camera scan.

#### R-05 · Micro-polish batch — S · P2
Light haptics on log/eat/check actions (`HapticFeedback.lightImpact`), consistent snackbar
durations, `FloatingActionButton` heroTag audit, pull-to-refresh on Meals regenerates.
Accept: no visual regressions; analyze clean.

---

### Phase 2 — Insight & history (week 2)

#### R-10 · Day navigation on Track — M · P1
Replace the fixed "today" with a selected-day state (provider holding a `DateTime`).
Chevrons + horizontal swipe on the header navigate days; "Today" pill jumps back. Entries
stream & kcal ring follow the selected day (`watchEntriesBetween` already takes a range).
Files: `providers.dart` (selectedDayProvider), `track_page.dart`.
Accept: swipe left = yesterday with its own entries/ring; logging while viewing a past day
logs to that day (portion sheet gains a date awareness) or is blocked with a hint — pick
logging-to-that-day.

#### R-11 · Weekly kcal chart — M · P1
A 7-day bar chart card on Track (below the log) — hand-drawn `CustomPaint` bars (no chart
package): one bar per day vs goal line, bars colored by within/over goal. Tapping a bar
navigates to that day (needs R-10). Data: aggregate `entriesSince(now-7d)` in a provider.
Files: `providers.dart`, `track_page.dart` (or new `widgets/weekly_chart.dart`).
Accept: chart matches logged data; goal line visible; tap-to-navigate works.

#### R-12 · Macro tracking — L · P2
Schema v4: add `proteins`, `carbs`, `fats` (nullable REAL, per portion) to
`ConsumptionEntries`. Capture at log time: pantry/OFF items know per-100g values and the
portion sheet knows grams → compute silently. Track header shows three small progress
chips (protein/carb/fat vs rough targets derived from the kcal goal: 25/45/30% split).
Files: `database.dart` (+migration), `log_portion_sheet.dart`, `track_page.dart`,
`providers.dart`. Accept: logging a pantry item with macros fills the chips; entries
without data don't break totals; migration preserves existing rows.

#### R-13 · Streaks & gentle stats — S · P3 (needs R-10/R-11)
"N days in a row within goal" line under the chart; no guilt-tripping when over (copy:
"fresh start today"). Accept: streak computed from history, capped display at 99+.

---

### Phase 3 — Smarter kitchen & meals (week 3)

#### R-20 · Expiry dates & pressure — M · P2
Optional `expiresAt` date on PantryItems (schema bump; date picker in edit sheet, quick
presets +3d/+1w/+2w). Kitchen sorts expiring-soon first within the list, shows "expires in
2 d" in red/amber on cards; "Eat soon" card (R-02) prioritizes by expiry. AI meal prompt
gains `expires_in_days`. Files: `database.dart`, `kitchen_page.dart`, `providers.dart`,
`ai_service.dart`, `track_page.dart`. Accept: expired items visibly flagged; prompt JSON
contains expiry.

#### R-21 · Low stock → groceries in one tap — S · P2
Kitchen app-bar action "Add low stock to groceries": every non-finished item ≤ 20% (or
≤ 2 units) not already on the list is added (source `auto`). Confirmation snackbar with
count + Undo. Files: `kitchen_page.dart`, `database.dart` (bulk insert helper).
Accept: duplicates skipped case-insensitively; undo removes the batch.

#### R-22 · Meal favorites & cook history — M · P2
"I made it" also archives the meal (new table `CookedMeals` or a `favorite`/`cookedAt`
approach on SavedMeals — prefer a separate table so regenerations don't erase history).
New section on Meals page: "Cook again" horizontal cards (title, kcal, one-tap log with
portion slider, one-tap "suggest variations" that seeds the AI prompt). Files:
`database.dart`, `meals_page.dart`, `providers.dart`, `ai_service.dart`.
Accept: cooked meals survive regeneration & restarts; re-log works.

#### R-23 · Partial "I made it" — S · P1
After picking the meal type, reuse the portion slider (fraction of the recipe, default
100%) so eating half logs half the kcal. Files: `meals_page.dart` (reuse
`showLogPortionSheet` with `packageGrams: null`, kcal scaled by fraction).
Accept: 50% → half kcal logged; kitchen-update sheet still offered.

#### R-24 · Time-of-day aware suggestions — S · P1
Pass `MealType.suggestedNow()` and the local time to `suggestMeals`; system prompt asks
for meals fitting that moment (breakfast ideas in the morning…). Files: `ai_service.dart`,
`providers.dart`. Accept: prompt contains the moment; no schema change.

#### R-25 · Offline OFF cache — M · P2
Cache OFF product JSON by barcode (new drift table `OffCache` with `fetchedAt`, TTL 30 d).
`OpenFoodFactsService` checks cache first, falls back to network, writes back; on network
failure serve stale cache with a "cached" hint. Files: `off_service.dart`, `database.dart`,
`providers.dart` (service needs the db — inject via constructor). Accept: airplane-mode
re-scan of a known barcode still resolves; unit tests with a fake client.

---

### Phase 4 — Trust, onboarding & polish (week 4)

#### R-30 · Data export / import — M · P1
Settings gains "Export data" (all tables → single JSON, versioned envelope, shared via
`share_handler`/`SharePlus` or saved to Downloads) and "Import data" (file picker →
validate version → replace-or-merge dialog → transaction). Files: new
`lib/data/services/backup_service.dart`, `settings_page.dart`, tests with an in-memory db.
Accept: export→wipe→import round-trips every table including done flags and timestamps.

#### R-31 · Tips & first-run guidance — S · P2
A dismissible one-liner tip card system (`TipsCard(id, text)` stored-dismissed in
SharedPreferences): Kitchen → "Tap an item to adjust what's left"; Track → "Scan a barcode
right from here"; Meals → "Suggestions use what's in your kitchen". Max one tip visible
per screen. Files: new `widgets/tip_card.dart`, the three pages, `settings_service.dart`.
Accept: dismiss persists across restarts; "Reset tips" in settings.

#### R-32 · App icon & splash in sepia — S · P3
Regenerate launcher icon (`assets/logo.png` recolor) + adaptive icon background to match
seed `0xFF96604A`; splash screen color. Files: `pubspec.yaml` (flutter_launcher_icons),
`android/`. Accept: icon visibly sepia on device.

#### R-33 · Theme mode toggle — S · P2
Settings: System / Light / Dark segmented control persisted in prefs; `ReadlyApp` reads a
themeModeProvider. Files: `settings_service.dart`, `providers.dart`, `app/app.dart`,
`settings_page.dart`. Accept: choice survives restart.

#### R-34 · CI artifact & release hygiene — S · P3
GitHub Actions uploads the debug APK as a workflow artifact; README section documents the
`android/key.properties` release-signing setup. Files: `.github/workflows/*`, `README.md`.
Accept: artifact downloadable from a CI run.

#### R-35 · Read tab quality-of-life — S · P3
History search field, "share summary" action on the summary page, retry button when the
proxy fails. Files: `reader_page.dart`, `summary_page.dart`. Accept: search filters live.

#### R-36 · Friendly error copy audit — S · P3
Sweep every `catch` → user-facing message: no raw exceptions in snackbars; map common
cases (no network, 401 bad key, quota) to plain-English strings with a fix hint.
Files: all pages + `ai_service.dart`, `off_service.dart`. Accept: no `$e` shown raw.

---

## Later / ideas parking lot

- Home-screen widget (today's ring + quick log) — heavy platform work.
- Voice quick-log ("I ate a croissant") → AI parses to name+kcal.
- Water tracking toggle.
- Recipe photo → ingredient extraction (vision model).
- Multi-day meal planning ("plan my week from the kitchen").
- Wear OS glance.

## Suggested dispatch order

1. ~~R-01, R-02, R-03, R-04~~ (done — v3.2)
2. R-23 + R-24 (small, immediate AI value) → one agent
3. R-10 + R-11 + R-13 (Track history bundle) → one agent
4. R-30 (backup — protects everything else) → one agent
5. R-25 + R-20 + R-21 (kitchen intelligence) → one agent
6. R-12 (macros, largest schema change — after the Track bundle lands)
7. R-31, R-33, R-05, R-35, R-36 (polish sweep) → one agent
8. R-22, R-32, R-34 as capacity allows
