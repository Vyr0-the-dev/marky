/// Route path constants for the Marky app.
abstract final class Routes {
  /// Home / Feed tab path.
  static const String home = '/home';

  /// Search tab path.
  static const String search = '/search';

  /// Add / Capture tab path.
  static const String add = '/add';

  /// Collections tab path.
  static const String collections = '/collections';

  /// Profile / Settings tab path.
  static const String profile = '/profile';

  /// Vault auth screen path.
  static const String vault = '/vault';

  /// Vault auth screen path (explicit).
  static const String vaultAuth = '/vault/auth';

  /// Vault feed screen path.
  static const String vaultFeed = '/vault/feed';

  /// Bookmark detail screen path.
  static const String bookmarkDetail = '/detail/:id';

  /// Tags manager screen path.
  static const String tags = '/tags';

  /// Tag detail screen path.
  static const String tagDetail = '/tag/:id';

  /// Collection detail screen path.
  static const String collectionDetail = '/collection/:id';

  /// Note edit screen path (create mode).
  static const String noteEdit = '/note/edit';

  /// Note edit screen path (edit mode with ID).
  static const String noteEditWithId = '/note/edit/:id';

  /// Dashboard analytics screen path.
  static const String dashboard = '/dashboard';

  /// Automation rules list screen path.
  static const String automationRules = '/automation-rules';

  /// Automation rule edit screen path.
  static const String automationRuleEdit = '/automation-rule/edit';

  /// Automation rule edit screen path with ID.
  static const String automationRuleEditWithId = '/automation-rule/edit/:id';
}
