# Changelog

## 1.0.0+1 - 2026-05-05

### Added

- Offline-first bookmark capture, feed, search, detail, library, reminders, backup/restore, and automation flows.
- Android share overlay for saving links from other apps.
- QR-only scan capture, manual input, and clipboard quick-add options.
- Duplicate bookmark detection with visible feedback and an `Open` action.
- Home-screen filter chips, unread reminder nudge, and compact bottom navigation.
- Settings screen with simplified primary options and an advanced section.
- Automation onboarding guide with starter templates.
- Android widget snapshot support.

### Changed

- Release Android target SDK set to `35`.
- Release signing is configured through local `key.properties` or `MARKY_*` environment variables instead of debug keys.
- Notification/timezone startup work is deferred until after initial app launch where safe.

### Verification

- Release App Bundle build completed: `build/app/outputs/bundle/release/app-release.aab`.
- Android identity/signing guard test passed.
- Emulator smoke checks passed for Settings, Automation onboarding, Quick Add, and duplicate feedback.
