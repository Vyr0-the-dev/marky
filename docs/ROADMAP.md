# Marky Production Roadmap & Feature Horizons

> **Current Version:** `1.0.0+1`  
> **Target Release:** Google Play Store (Android-First Production)

---

## 1. Production Release Gate Status

The roadmap tracks the hardening and release pipeline of Marky from initial consolidation through final Play Store deployment.

```text
Status Legend:
[x] Completed & Verified
[/] In Progress
[ ] Planned / Pending Verification
```

---

## 2. Completed Milestones

### Phase A — Code Health & Isolation
- [x] **A1: Analyzer Policy:** Enforced default analyzer scope on active codebase; archived obsolete test files into `legacy_archive/`.
- [x] **A2: Legacy Code Isolation:** Moved pre-V2 migration scripts and obsolete test files to `legacy_archive/` with dedicated documentation.
- [x] **A3: Lint Debt Cleanup:** Resolved unused imports, prefer_const, and styling lints across all production sources.
- [x] **A4: Metadata Finalization:** Version set to `1.0.0+1`; icon assets, Android app label, and package metadata verified.

### Phase B — Test Infrastructure & Coverage
- [x] **B1: Production Test Scope:** Configured `dart_test.yaml` tags and active test discovery.
- [x] **B2: Green Production Test Suite:** All 516 active tests passing cleanly (`flutter test`).
- [x] **B3: Critical Coverage Expansion:** Added widget snapshot resilience tests, fallback coverage, and repository edge-cases.
- [x] **B4: End-to-End Smoke Path:** Implemented router-level smoke test traversing intake → feed → detail → search → library.

### Phase C — Performance & Polish
- [x] **C1: Startup Profiling:** Cold start traced on physical `SM G780G` (`timeToFirstFrameMicros: 408774`).
- [x] **C2: Scale Contracts:** Validated Home feed lazy rendering across 100, 1,000, and 5,000 bookmark datasets (`home_feed_scale_test.dart`).
- [x] **C3: Motion Compliance:** Enforced system `disableAnimations` and app animation toggle zero-duration overrides.
- [x] **C4: Visual Consistency:** Aligned loading skeletons, error panels, and empty states with the Reading Room grammar.

### Phase D — Accessibility & Internationalization
- [x] **D1: TalkBack Verification:** Verified semantic announcements on physical hardware for search input, feed cards, and navigation.
- [x] **D2: Dynamic Text Scaling:** Verified layout usability at 1.0x, 1.5x, and 2.0x scales across all core screens.
- [x] **D3: Full Localization:** Comprehensive English and Turkish localization coverage generated via `flutter gen-l10n`.
- [x] **D4: Accessibility Regression Tests:** Semantic labels locked via automated widget tests.

### Pre-E Quality Gate
- [x] **Pre-E1: Scraper Resilience:** Added Cloudflare challenge detection, Reddit `.json` fallback API, and favicon fallbacks.
- [x] **Pre-E2: Screen Polish:** Added full-screen hero image zoom, inline title/description editing, and automation guides.

### Phase E — Security & Privacy
- [x] **E2: Minimal Permission Audit:** Removed unnecessary permissions (`VIBRATE` stripped, `RECEIVE_BOOT_COMPLETED` audited for alarms).
- [x] **E3: Release-Safe Error Boundary:** Implemented `debugOnlyErrorDetails` to prevent sensitive URLs or PII leaks in production logs.
- [x] **E4: Input Limits & Deep-Link Hardening:** Added `MarkyInputLimits` and enforced route allowlists on Android intents.

### Phase F — Data Integrity & Migration
- [x] **F1: Isar Schema Versioning:** `schemaVersion = 1` locked with deterministic schema order tests.
- [x] **F2: Backup/Restore Round-Trip:** Paged backup export and non-destructive import verified with full Isar round-trip test.
- [x] **F3: Duplicate Detection:** Canonical URL, SHA-256 hash, external content IDs, and AMP collapse tested against edge cases.
- [x] **F4: Reminder Rescheduling:** Boot receiver and app startup reminder rescheduling verified for pending alarms.

### Phase G1 & J4 — Identity & Cleanup
- [x] **G1: Final App Identity:** Application ID `com.marky.app.marky`, app name `Marky`, AMOLED black native splash screen.
- [x] **J4: Documentation Cleanup:** Obsolete drafts removed; architecture, testing, and roadmap consolidated in `docs/`.

---

## 3. Pre-Launch Release Gates (Active Tracking)

- [ ] **G2: Play Store SDK Audit**
  - Verify compileSdkVersion (35/36), targetSdkVersion (35), and minSdkVersion (26) align with the latest Google Play target API requirements.
- [ ] **G3: Release Keystore Configuration**
  - Configure production release keystore via local `android/key.properties` or environment variables (`MARKY_STORE_FILE`, `MARKY_KEY_ALIAS`). Ensure credentials remain strictly out of version control.
- [ ] **G4: Release App Bundle Build**
  - Execute `flutter build appbundle --release` and verify package integrity and size optimization.
- [ ] **G5: Multi-Device Physical Smoke**
  - Perform manual verification across at least two distinct Android OS versions (e.g., Android 12/13 and Android 14/15).
- [ ] **H1-H3: Production Observability**
  - Verify error boundary telemetry and runtime crash logs remain strictly local.
- [ ] **I1-I3: CI/CD Pipeline Integration**
  - Configure GitHub Actions workflow to run `flutter analyze`, `flutter test`, and release compilation.
- [ ] **J1-J3: Store Presence & Metadata**
  - Finalize Google Play store descriptions (English & Turkish), promotional graphics, and store screenshots.
- [ ] **K1-K4: Play Console Track Rollout**
  - Internal testing track → Closed testing track → Production staged rollout (10% → 50% → 100%).

---

## 4. Forward Horizons (Post-1.0)

Ideas and conceptual extensions slated for exploration following the initial Android production release:

1. **Browser Companion Extension (Firefox & Chrome):**
   - A lightweight browser extension to send active browser tabs or highlighted passages directly to Marky via a secure local bridge or share payload.
2. **Desktop Companion Bridge (Windows / Linux):**
   - Local, peer-to-peer or file-based synchronization allowing users to search and read their Marky link library from desktop workstations.
3. **Smart Digest & Export Formats:**
   - Periodic reading digests, weekly summary exports in Markdown/HTML, and export compatibility with e-readers (ePub).
