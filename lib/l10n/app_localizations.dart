import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Marky'**
  String get appTitle;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feedTitle;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @captureTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Link'**
  String get captureTitle;

  /// No description provided for @collectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @vaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vaultTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @importExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import & Export'**
  String get importExportTitle;

  /// No description provided for @navigationFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navigationFeed;

  /// No description provided for @navigationSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navigationSearch;

  /// No description provided for @navigationAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navigationAdd;

  /// No description provided for @navigationCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get navigationCollections;

  /// No description provided for @navigationProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search bookmarks...'**
  String get searchHint;

  /// No description provided for @captureUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get captureUrlLabel;

  /// No description provided for @captureUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a link'**
  String get captureUrlHint;

  /// No description provided for @captureTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get captureTitleLabel;

  /// No description provided for @captureTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Optional custom title'**
  String get captureTitleHint;

  /// No description provided for @captureNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get captureNotesLabel;

  /// No description provided for @captureNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add a quick note'**
  String get captureNotesHint;

  /// No description provided for @clipboardBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Link found in clipboard'**
  String get clipboardBannerTitle;

  /// No description provided for @clipboardBannerAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get clipboardBannerAction;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get actionArchive;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get actionDismiss;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionAddTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get actionAddTag;

  /// No description provided for @actionAddCollection.
  ///
  /// In en, this message translates to:
  /// **'Add collection'**
  String get actionAddCollection;

  /// No description provided for @emptyBookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get emptyBookmarksTitle;

  /// No description provided for @emptyBookmarksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved links will appear here once you add your first item.'**
  String get emptyBookmarksSubtitle;

  /// No description provided for @emptyCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get emptyCollectionsTitle;

  /// No description provided for @emptyCollectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create collections to organize related bookmarks.'**
  String get emptyCollectionsSubtitle;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword, tag, or filter.'**
  String get emptySearchSubtitle;

  /// No description provided for @emptyNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get emptyNotesTitle;

  /// No description provided for @emptyNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add notes to keep context alongside your bookmarks.'**
  String get emptyNotesSubtitle;

  /// No description provided for @emptyRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders scheduled'**
  String get emptyRemindersTitle;

  /// No description provided for @emptyRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create reminders to revisit important links later.'**
  String get emptyRemindersSubtitle;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// No description provided for @errorNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get errorNetworkMessage;

  /// No description provided for @errorLoadFeedMessage.
  ///
  /// In en, this message translates to:
  /// **'The feed could not be loaded.'**
  String get errorLoadFeedMessage;

  /// No description provided for @errorSaveBookmarkMessage.
  ///
  /// In en, this message translates to:
  /// **'The bookmark could not be saved.'**
  String get errorSaveBookmarkMessage;

  /// No description provided for @errorDeleteBookmarkMessage.
  ///
  /// In en, this message translates to:
  /// **'The bookmark could not be deleted.'**
  String get errorDeleteBookmarkMessage;

  /// No description provided for @errorSearchMessage.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get errorSearchMessage;

  /// No description provided for @snackbarBookmarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved'**
  String get snackbarBookmarkSaved;

  /// No description provided for @snackbarBookmarkAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get snackbarBookmarkAlreadySaved;

  /// No description provided for @snackbarBookmarkUpdated.
  ///
  /// In en, this message translates to:
  /// **'Bookmark updated'**
  String get snackbarBookmarkUpdated;

  /// No description provided for @snackbarBookmarkDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bookmark deleted'**
  String get snackbarBookmarkDeleted;

  /// No description provided for @snackbarCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get snackbarCopiedToClipboard;

  /// No description provided for @snackbarReminderCreated.
  ///
  /// In en, this message translates to:
  /// **'Reminder created'**
  String get snackbarReminderCreated;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get filterFavorites;

  /// No description provided for @filterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filterUnread;

  /// No description provided for @filterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get filterArchived;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldest;

  /// No description provided for @sortRecentlyOpened.
  ///
  /// In en, this message translates to:
  /// **'Recently opened'**
  String get sortRecentlyOpened;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @labelFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get labelFavorite;

  /// No description provided for @labelArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get labelArchived;

  /// No description provided for @labelReadLater.
  ///
  /// In en, this message translates to:
  /// **'Read later'**
  String get labelReadLater;

  /// No description provided for @labelPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get labelPrivate;

  /// No description provided for @dialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmark?'**
  String get dialogDeleteTitle;

  /// No description provided for @dialogDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get dialogDeleteMessage;

  /// No description provided for @dialogUnsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get dialogUnsavedChangesTitle;

  /// No description provided for @dialogUnsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your edits will be lost if you leave now.'**
  String get dialogUnsavedChangesMessage;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @settingsAccessibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibilityLabel;

  /// No description provided for @settingsNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @statusLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get statusLoading;

  /// No description provided for @statusSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get statusSaving;

  /// No description provided for @statusEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get statusEmpty;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @feedMainContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks feed content'**
  String get feedMainContentLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
