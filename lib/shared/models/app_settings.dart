import 'package:isar/isar.dart';

part 'app_settings.g.dart';

/// Single-row application settings stored in Isar.
///
/// Always use [id] = 0 so only one settings row ever exists.
/// Query with `isar.appSettings.get(0)` or use a singleton repository pattern.
@collection
class AppSettings {
  AppSettings({
    this.themeMode = 'system',
    this.accentColor = 'default',
    this.dynamicColorEnabled = false,
    this.oledPureBlackEnabled = false,
    this.gridDensity = 'comfortable',
    this.defaultLayoutMode = 'grid',
    this.defaultOpenBehavior = 'inApp',
    this.hapticsEnabled = true,
    this.animationsEnabled = true,
    this.clipboardDetectionEnabled = true,
    this.autoArchiveDays,
    this.autoDeleteDays,
    this.backupEnabled = false,
    this.backupTarget,
    this.backupEncryptionEnabled = false,
    this.aiEnabled = false,
    this.localAiOnlyMode = true,
    this.languagePreference = 'system',
    this.analyticsEnabled = false,
    this.crashLogsEnabled = true,
    this.recentSearches,
  });

  /// Fixed id for the single settings row.
  Id id = 0;

  /// Theme mode: 'system', 'light', or 'dark'.
  String themeMode;

  /// Accent color identifier (e.g. 'default', 'blue', 'purple').
  String accentColor;

  /// Whether to use Material You dynamic colors when available.
  bool dynamicColorEnabled;

  /// Whether to use pure black (#000000) backgrounds in dark mode.
  bool oledPureBlackEnabled;

  /// Grid density: 'compact', 'comfortable', or 'spacious'.
  String gridDensity;

  /// Default layout mode: 'grid', 'list', or 'detail'.
  String defaultLayoutMode;

  /// Default open behavior: 'inApp', 'external', or 'reader'.
  String defaultOpenBehavior;

  /// Whether haptic feedback is enabled throughout the app.
  bool hapticsEnabled;

  /// Whether animations are enabled.
  bool animationsEnabled;

  /// Whether clipboard URL detection is enabled.
  bool clipboardDetectionEnabled;

  /// Number of days before auto-archiving items. `null` disables.
  int? autoArchiveDays;

  /// Number of days before auto-deleting items. `null` disables.
  int? autoDeleteDays;

  /// Whether automatic backups are enabled.
  bool backupEnabled;

  /// Backup target path or identifier.
  String? backupTarget;

  /// Whether backup files should be encrypted.
  bool backupEncryptionEnabled;

  /// Whether AI features are enabled.
  bool aiEnabled;

  /// Whether AI should run only on-device.
  bool localAiOnlyMode;

  /// Preferred language code or 'system'.
  String languagePreference;

  /// Whether anonymous analytics are enabled.
  bool analyticsEnabled;

  /// Whether crash log collection is enabled.
  bool crashLogsEnabled;

  /// Recent search queries (most recent first, max 20).
  List<String>? recentSearches;

  /// Creates a copy of this [AppSettings] with the given fields replaced.
  AppSettings copyWith({
    String? themeMode,
    String? accentColor,
    bool? dynamicColorEnabled,
    bool? oledPureBlackEnabled,
    String? gridDensity,
    String? defaultLayoutMode,
    String? defaultOpenBehavior,
    bool? hapticsEnabled,
    bool? animationsEnabled,
    bool? clipboardDetectionEnabled,
    int? autoArchiveDays,
    int? autoDeleteDays,
    bool? backupEnabled,
    String? backupTarget,
    bool? backupEncryptionEnabled,
    bool? aiEnabled,
    bool? localAiOnlyMode,
    String? languagePreference,
    bool? analyticsEnabled,
    bool? crashLogsEnabled,
    List<String>? recentSearches,
  }) {
    final AppSettings copy = AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      dynamicColorEnabled: dynamicColorEnabled ?? this.dynamicColorEnabled,
      oledPureBlackEnabled: oledPureBlackEnabled ?? this.oledPureBlackEnabled,
      gridDensity: gridDensity ?? this.gridDensity,
      defaultLayoutMode: defaultLayoutMode ?? this.defaultLayoutMode,
      defaultOpenBehavior: defaultOpenBehavior ?? this.defaultOpenBehavior,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      clipboardDetectionEnabled:
          clipboardDetectionEnabled ?? this.clipboardDetectionEnabled,
      autoArchiveDays: autoArchiveDays ?? this.autoArchiveDays,
      autoDeleteDays: autoDeleteDays ?? this.autoDeleteDays,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      backupTarget: backupTarget ?? this.backupTarget,
      backupEncryptionEnabled:
          backupEncryptionEnabled ?? this.backupEncryptionEnabled,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      localAiOnlyMode: localAiOnlyMode ?? this.localAiOnlyMode,
      languagePreference: languagePreference ?? this.languagePreference,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashLogsEnabled: crashLogsEnabled ?? this.crashLogsEnabled,
      recentSearches: recentSearches ?? this.recentSearches,
    );
    copy.id = id;
    return copy;
  }
}
