# Readly

Personal Android app: **kcal tracker + AI meal maker**, with article summarization as a side feature. Built for one user — no accounts, no backend, everything on-device.

## Features

- **Track** — daily kcal ring vs. your goal. Log by barcode scan (Open Food Facts), from your pantry, or quick-add.
- **Kitchen** — scan what you have at home; estimate how much is left in each package with a slider.
- **Meals** — Claude suggests 3 healthy, low-effort meals from what you actually own and your remaining kcal. Missing ingredients go to the grocery list in one tap.
- **Groceries** — checklist with AI purchase propositions based on your pantry and eating habits.
- **Read** — share any web page to Readly (or paste a URL) and get a streamed summary.

## Stack

Flutter (Material 3) · Riverpod · go_router · drift (SQLite) · mobile_scanner · Open Food Facts API v2 · Anthropic Messages API (`claude-opus-4-8`, bring your own key).

## Setup

```sh
flutter pub get
dart run build_runner build   # drift codegen (after schema changes)
flutter run
```

Then add your Anthropic API key in the app's settings to enable the AI features.

## Checks

```sh
dart format lib test
flutter analyze
flutter test
```

See `PLAN.md` for the overhaul plan and remaining ideas.
