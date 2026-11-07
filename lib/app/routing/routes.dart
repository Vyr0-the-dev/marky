/// All route paths used by Marky v2's GoRouter configuration.
///
/// Keeping these as compile-time constants rather than strings scattered
/// across feature code means the compiler catches typos, and renaming a
/// route is a single-file operation. Feature code must never hand-write
/// `'/detail/$id'` — always go through these constants (+ helpers).
abstract final class Routes {
  // ─── Shell branches (bottom nav tabs) ──────────────────────────────
  /// Home / Feed — the default landing tab.
  static const String home = '/home';

  static const String homeUnread = '/home/unread';

  /// Instant search.
  static const String search = '/search';

  /// Add / Capture — paste or share a new bookmark.
  static const String add = '/add';

  /// QR scan capture screen.
  static const String addQr = '/add/qr';

  /// Library — tags + collections + archive, all saved content.
  static const String library = '/library';

  // ─── Root-level (stacked above shell, hide bottom nav) ─────────────
  /// Bookmark detail. Use [bookmarkDetailPath] to build with an id.
  static const String bookmarkDetail = '/detail/:id';

  /// Settings root — theme, language, backup, automation.
  static const String settings = '/settings';

  /// Dashboard / statistics — reached from Settings.
  static const String stats = '/settings/stats';

  /// Backup + restore + Google Drive config — reached from Settings.
  static const String backup = '/settings/backup';

  /// Automation rules list — reached from Settings.
  static const String automationRules = '/settings/automation';

  /// Broken link checker — reached from Settings.
  static const String brokenLinks = '/settings/broken-links';

  /// Automation rule editor (create).
  static const String automationRuleNew = '/settings/automation/new';

  /// Automation rule editor (edit). Use [automationRuleEditPath].
  static const String automationRuleEdit = '/settings/automation/:id';

  static const String reminders = '/reminders';

  /// Tag manager.
  static const String tags = '/library/tags';

  /// Collection manager.
  static const String collections = '/library/collections';

  // ─── Path builders ─────────────────────────────────────────────────
  /// Builds a concrete detail path: `/detail/42`.
  static String bookmarkDetailPath(int id) => '/detail/$id';

  /// Builds a concrete automation rule edit path.
  static String automationRuleEditPath(int id) => '/settings/automation/$id';
}
