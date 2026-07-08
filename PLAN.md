# Readly 3.0 — Overhaul Plan

Transform Readly from a single-purpose "article summarizer" into a personal **kcal tracker + meal maker**, with the article synthesis kept as a side feature. Personal app: no accounts, no backend, everything on-device.

## Architecture decisions

| Area | Choice | Why |
|---|---|---|
| UI framework | Flutter (Material 3, seed-color theme, rounded 20–28px radii) | Existing codebase, modern look for free |
| State management | `flutter_riverpod` 3.x (no codegen) | Reactive, testable, minimal boilerplate |
| Navigation | `go_router` + `StatefulShellRoute` (5-tab `NavigationBar`) | Preserves per-tab state, deep-linkable |
| Local database | `drift` (SQLite) + `drift_flutter` | Type-safe, reactive streams drive the UI, testable |
| Barcode scanning | `mobile_scanner` 7.x | Maintained, CameraX-based |
| Food data | Open Food Facts API v2 (plain `http`, `User-Agent` set) | Free, no key, FR products well covered |
| AI | Anthropic Messages API via raw HTTP (`claude-opus-4-8`), BYOK key in `flutter_secure_storage` | `chat_gpt_sdk` is dead; no official Dart SDK → raw HTTP + SSE streaming; structured outputs (`output_config.format`) for meals/groceries |
| Article extraction | In-app: fetch page + strip text with `html` package | Removes dependency on the (likely dead) `readly.lightin.io` readability API |
| Fonts | `google_fonts` (Outfit / Manrope style) | Clean rounded look without bundling font files |
| Lint/CI | `flutter_lints` 6 + stricter rules; GitHub Actions: analyze → test → build | There was no analyze/test step at all |

## Pages (5 tabs + settings)

1. **Track** (home) — today's kcal ring vs. daily goal, meal log (breakfast/lunch/dinner/snack), quick-add, barcode-scan-to-log (OFF lookup → portion → kcal), log straight from pantry.
2. **Kitchen** — pantry stock. Scan or manual add; each item stores OFF nutrition (kcal/100 g, macros) and a "quantity left" slider (0–100 %). Edit/delete.
3. **Meals** — AI meal maker. Sends pantry (with quantities left), remaining kcal today and language to Claude → 3 low-effort meal suggestions (title, time, kcal, steps, used + missing ingredients). Missing ingredients → one-tap add to groceries. "I made it" → logs kcal.
4. **Groceries** — checklist. Manual add + AI proposition (pantry + recent consumption → suggested purchases with reasons). Check off, clear done.
5. **Read** — legacy feature. Paste URL or Android share-sheet → extract text → stream Claude summary → saved history.

**Settings** (gear on every tab): Anthropic API key (secure storage), summary/meal language, daily kcal goal.

## Data model (drift tables)

- `PantryItems` — barcode?, name, brand?, imageUrl?, kcalPer100g?, proteins/carbs/sugars/fats per 100 g?, packageQuantity?, amountLeft (0..1), addedAt, updatedAt
- `ConsumptionEntries` — name, kcal, mealType, pantryItemId?, grams?, loggedAt
- `ShoppingItems` — name, note? (AI reason), done, source (manual/ai), addedAt
- `Articles` — url, title, summary, createdAt (synthesis history)

## Task list

### Phase 0 — Toolchain & hygiene
- [x] Audit existing code (1 200 lines, 11 files) and Android config
- [x] Rewrite `pubspec.yaml`: drop `chat_gpt_sdk`, `animated_image_list`; add riverpod, go_router, drift(+dev,build_runner), mobile_scanner, google_fonts; bump SDK to `^3.12.0`, version `3.0.0`
- [x] Stricter `analysis_options.yaml` (flutter_lints 6 + extra rules)
- [x] Android: add `CAMERA` permission, drop deprecated manifest `package` attr, Java 11
- [x] CI: format + analyze + test + build APK, current Flutter, drop `dart format` misuse

### Phase 1 — Core plumbing
- [x] Theme (Material 3, light+dark, rounded shapes, google_fonts)
- [x] Router (5-branch StatefulShellRoute + /settings + /scan)
- [x] Drift database + DAOs + codegen
- [x] SettingsService (API key secure, goal/language prefs)
- [x] AnthropicService: SSE streaming (`summarize`) + structured-output (`suggestMeals`, `suggestGroceries`) against `claude-opus-4-8`
- [x] OpenFoodFactsService: product by barcode (v2 API, staging-safe parsing)
- [x] ArticleExtractor: fetch URL → title + readable text
- [x] Share-intent hook → Read tab

### Phase 2 — Features
- [x] Track page (ring painter, grouped log, quick add sheet, scan-to-log flow, log-from-pantry)
- [x] Kitchen page (list, scan-to-add flow, manual add/edit sheet, amount-left slider, delete)
- [x] Meals page (suggestion cards, missing→groceries, "I made it" → log)
- [x] Groceries page (checklist, manual add, AI proposition, clear done)
- [x] Read page (URL field, history list, streaming summary view)
- [x] Settings page

### Phase 3 — Quality
- [x] Unit tests: OFF response parsing, SSE stream parsing, AI JSON parsing, article extraction, DB queries
- [x] Widget test: app boots, 5 tabs navigate
- [x] `flutter analyze` clean, `dart format` clean
- [ ] `flutter build apk` passes
- [x] Delete dead code (old pages/services), update README

### Later / ideas (not in this pass)
- [ ] Decrement pantry quantities automatically when a meal is cooked
- [ ] Weekly kcal/macro charts
- [ ] Off-line queue for OFF lookups
- [ ] iOS share-extension re-test (Android is the target device)
