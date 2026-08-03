# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Project Atlas is a shopping decision app (Flutter, web-first): scan a barcode, identify the product, compare price/availability across retailer connectors, and save it to a shopping list. Public app name TBD.

Product docs (PRD, architecture, engineering values, MVP scope, wireframe spec, navigation map, sprint tracking) live in an external Obsidian vault, not in this repo. Files referenced throughout the code as `ARCHITECTURE.md`, `PRD.md`, `NAVIGATION-MAP.md`, `WIREFRAME-SPEC.md`, `MVP-FREEZE-v1.0.md`, `TASKS.md` are in that vault — comments assume you have access to them, but this repo is self-contained for coding purposes. Commit messages and code comments reference task IDs (`ATLAS-XXX`) from `TASKS.md`.

Status: MVP v1.0 is frozen. Kroger is the only live connector, wired end-to-end (Cloud Function → Firestore → UI). Target/Walmart connectors are not yet implemented.

## Commands

Run everything from the repo root unless noted.

```bash
flutter pub get              # install/sync Dart deps
flutter run -d chrome        # run the app — Chrome, not an emulator (low-RAM dev machine)
flutter analyze              # static analysis (flutter_lints + analysis_options.yaml)
flutter test                 # run all tests
flutter test test/scan_intake_test.dart              # run a single test file
flutter test --plain-name "rejects the same code"    # run tests matching a name
```

Cloud Functions (`functions/`, TypeScript):

```bash
cd functions
npm ci
npx tsc --noEmit             # type-check only (what CI runs)
npm run build                # compile to lib/
npm run serve                # build + run functions emulator locally
npm run deploy                # firebase deploy --only functions
npm run logs                  # firebase functions:log
```

Firestore rules: `firebase deploy --only firestore:rules` (from repo root; needs `firebase-tools` and login).

CI (`.github/workflows/ci.yml`) runs two independent jobs on push/PR to `main`: `flutter analyze && flutter test`, and `npx tsc --noEmit` inside `functions/`. Match these locally before pushing.

Phone testing over LAN (camera needs a secure context): `python tools/serve_https.py` after `flutter build web`, or `adb reverse tcp:5757 tcp:5757` if USB debugging is available — see the script's docstring for cert setup.

## Architecture

### Layering

`screens/` (UI, Riverpod `ConsumerWidget`s) → provider layer (`lib/providers.dart`) → repository *interfaces* (`lib/repositories/*_repository.dart`) → concrete implementations (Firestore, connectors). Screens and widgets never import `cloud_firestore`, `firebase_auth`, or connector classes directly — they depend only on the abstract repository interfaces and read them via Riverpod providers. **All dependency wiring lives in `lib/providers.dart` — nowhere else.** To swap an implementation (e.g. mock → Firestore), change the provider there; no screen code changes.

`lib/repositories/mock_repositories.dart` holds the original in-memory stand-ins from early scaffolding; production wiring now points at the `Firestore*Repository` implementations instead.

### `Result<T>` — no nulls, no thrown exceptions across layers

`lib/models/result.dart` defines a sealed `Result<T>` with cases `Success`, `NotFound`, `Offline`, `PermissionDenied`, `ConnectorUnavailable`, `Failure`. Every repository/connector method that can fail returns a `Result`, not a thrown exception or `null`. UI code maps each case to a specific, honest message via `resultMessage()` in `lib/widgets/state_message.dart` (e.g. `Offline` → "Offline · Showing nothing rather than guessing") rather than a blank screen or generic error. When adding a new failing operation, return/handle `Result`, don't introduce a new error-handling convention.

### Retailer connectors

`RetailConnector` (`lib/connectors/retail_connector.dart`) is the interface every retailer (Kroger, and future Target/Walmart) implements, returning a normalized `PriceInfo`. Adding a store must never require touching UI or repository code.

Kroger (`lib/connectors/kroger_connector.dart`) is the one live implementation, and its shape is the pattern for future connectors: the Flutter client **never holds retailer API credentials**. It calls the `lookupKrogerPrice` Cloud Function (`functions/src/index.ts`), which holds `KROGER_CLIENT_ID`/`KROGER_CLIENT_SECRET` in Google Secret Manager (set via `firebase functions:secrets:set`, never in `.env` — `functions/.env.example` documents this but contains no real values). The function writes the normalized result to `products/{productId}/prices/{connectorId}` in Firestore; the client then reads it back through `FirestorePriceRepository` like any other connector, so there is one single source of truth for what the UI displays. `KrogerConnector.refreshPrice()` is a side-effecting trigger, not a read path.

Kroger is currently pinned to Kroger's **certification** environment (`api-ce.kroger.com`), not production — see the comment in `functions/src/index.ts` if promoting to production credentials/URLs.

### Firestore data model & security

Two data domains, enforced by `firestore.rules`:
- **Shared catalog** (`products/{id}`, `products/{id}/prices/{connectorId}`) — retailer-independent product identification. Read-only to any signed-in client; writes are backend-only (Cloud Functions / admin SDK, which bypasses rules). Products are found by querying `barcode`, not by document ID being the UPC.
- **Per-user data** (`users/{userId}/favorites`, `.../shoppingList`, `.../scanHistory`) — owned exclusively by that user; rules require `request.auth.uid == userId` both ways.

Every Firestore repository (`lib/repositories/firestore_*.dart`) follows the same shape: constructor takes an optional `FirebaseFirestore` for test injection (defaults to `.instance`), methods wrap Firestore calls in try/catch and map `FirebaseException` (especially `permission-denied`) into the matching `Result` case via a local `_mapError` helper.

### Auth

`lib/repositories/auth_repository.dart` wraps `firebase_auth` behind `AuthRepository`/`AppUser` — screens never touch `firebase_auth`'s `User` type directly. Supports anonymous sign-in and Google sign-in (web popup flow only for now; mobile will need `google_sign_in` instead). `authStateProvider` (in `providers.dart`) is watched once at the app root in `main.dart` to keep the auth stream alive for the whole app lifetime — reading `currentUserIdProvider` before that stream starts would otherwise silently see `null` even when signed in.

### Routing

`lib/routing/app_router.dart`'s `AppRoutes` is the code-form contract of `NAVIGATION-MAP.md` in the vault — every named route here must correspond to an arrow in that document. The product screen takes its ID via route arguments (set by the scan flow).

### Scanning pipeline

`lib/scanning/scan_intake.dart` holds pure, Flutter-free helpers so they're trivially unit-testable: `normalizeScannedCode()` (pads UPC-A/EAN-13 to a 13-digit zero-padded ID used as the `products/{id}` key everywhere downstream) and `ScanDeduper` (suppresses repeat detections from the same physical scan — cameras emit multiple frames per second). The actual camera widget uses `mobile_scanner`; its barcode-decoding library is served from a locally bundled copy (`web/js/zxing-library-0.21.3.js`) instead of the package's default unpkg.com fetch, which hangs indefinitely behind ad blockers or flaky CDNs.

`scannerCameraEnabledProvider` (in `providers.dart`) gates whether the Scan screen builds the real camera widget — it's overridden to `false` in tests, since `MobileScanner` needs platform channels `flutter_test` doesn't provide.

## Testing conventions

- Fakes, not mocking frameworks: `test/fake_*.dart` provides hand-written fakes (`FakeAuthRepository`, `FakeKrogerConnector`, `FakePriceRepository`, `FakeUserDataRepositories`) implementing the same repository interfaces as production.
- Widget tests wrap the widget under test in a `ProviderScope` with `overrides:` swapping every repository/connector provider for its fake — see `test/product_screen_test.dart` and `test/widget_test.dart` for the pattern. Build a `harness()` helper per test file rather than repeating the override list.
- Pure logic (e.g. `scan_intake.dart`) gets plain `test()` cases with no widget/provider setup at all — keep new pure helpers Flutter-free so they can stay this cheap to test.
- Async UI flows that involve timers (e.g. the Launch screen's auto-navigate) need `await tester.pumpAndSettle(const Duration(...))` to flush pending timers before assertions, not a bare `pumpAndSettle()`.

## Platform notes

- Development targets **Chrome/web only** right now (`flutter_options.dart`'s `DefaultFirebaseOptions.web` is the only configured Firebase target; `main.dart` guards Firebase init with `kIsWeb`). Android/iOS/Linux/macOS/Windows directories exist from `flutter create` but aren't wired up with their own Firebase config yet.
- `shared_preferences` (used for the persisted Kroger store selection, `krogerLocationIdProvider`) can fail to load (stale build, private browsing); the app degrades to an in-memory default and logs via `debugPrint`, rather than surfacing an error to the UI — follow that pattern for other local-persistence reads.
