# Project Atlas

A shopping decision app — scan a barcode, see product identification, compare price and availability across retailer connectors, and save to a shopping list. Public app name TBD (see `BRAND.md` in the vault).

## Project knowledge base

All product docs — PRD, architecture, engineering values, MVP scope, wireframe spec, navigation map, sprint tracking — live in an Obsidian vault (not in this repo):

`F:\Obsidian\Shopping Intelligence Vault\`

Start at `AI_CONTEXT.md` for the full project briefing.

## Status

MVP v1.0 is frozen (see `MVP-FREEZE-v1.0.md`). Sprint 2 (experience design / wireframes) is complete. This repo is ATLAS-001: repository & Flutter foundation — placeholder screens matching the wireframes, with navigation wired up per `NAVIGATION-MAP.md`.

## Running the app

Given this machine's limited RAM, run in Chrome rather than an Android emulator:

```
flutter run -d chrome
```

## Structure

```
lib/
  models/       Product, PriceInfo (see ARCHITECTURE.md §3)
  connectors/   Retailer connector adapters (Kroger, Target, Walmart) — not yet implemented
  screens/      One folder per screen, matching WIREFRAME-SPEC.md
  widgets/      Shared components (e.g. ProductCard, reused by list screens)
  theme/        App theming
  routing/      Named routes — the code form of NAVIGATION-MAP.md
```
