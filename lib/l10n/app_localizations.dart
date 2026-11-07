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

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

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

  /// No description provided for @snackbarBookmarkArchived.
  ///
  /// In en, this message translates to:
  /// **'Bookmark archived'**
  String get snackbarBookmarkArchived;

  /// No description provided for @snackbarBookmarkUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Bookmark unarchived'**
  String get snackbarBookmarkUnarchived;

  /// No description provided for @snackbarMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'Marked as read'**
  String get snackbarMarkedAsRead;

  /// No description provided for @snackbarMarkedAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Marked as unread'**
  String get snackbarMarkedAsUnread;

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

  /// No description provided for @themeOled.
  ///
  /// In en, this message translates to:
  /// **'OLED black'**
  String get themeOled;

  /// No description provided for @exitWarning.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get exitWarning;

  /// No description provided for @settingsAnimationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get settingsAnimationsLabel;

  /// No description provided for @settingsDashboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get settingsDashboardLabel;

  /// No description provided for @settingsBackupLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackupLabel;

  /// No description provided for @settingsAutomationLabel.
  ///
  /// In en, this message translates to:
  /// **'Automation rules'**
  String get settingsAutomationLabel;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navigationLibrary;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library is quiet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save a link from anywhere — paste, share, or add manually.'**
  String get homeEmptyBody;

  /// No description provided for @homeAddLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Add a link'**
  String get homeAddLinkAction;

  /// No description provided for @homeNoFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get homeNoFavoritesTitle;

  /// No description provided for @homeNoFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any bookmark to save it here.'**
  String get homeNoFavoritesBody;

  /// No description provided for @homeBrowseAllAction.
  ///
  /// In en, this message translates to:
  /// **'Browse all'**
  String get homeBrowseAllAction;

  /// No description provided for @homeAllCaughtUpTitle.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get homeAllCaughtUpTitle;

  /// No description provided for @homeAllCaughtUpBody.
  ///
  /// In en, this message translates to:
  /// **'Everything has been read.'**
  String get homeAllCaughtUpBody;

  /// No description provided for @homeArchiveEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive is empty'**
  String get homeArchiveEmptyTitle;

  /// No description provided for @homeArchiveEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Swipe to archive bookmarks you want to keep but hide.'**
  String get homeArchiveEmptyBody;

  /// No description provided for @homeGridTooltip.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get homeGridTooltip;

  /// No description provided for @homeListTooltip.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get homeListTooltip;

  /// No description provided for @homeSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get homeSortTooltip;

  /// No description provided for @homeSelectAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get homeSelectAllTooltip;

  /// No description provided for @homeSelectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 selected} other {{count} selected}}'**
  String homeSelectionCount(int count);

  /// No description provided for @searchSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Search saved'**
  String get searchSavedSnackbar;

  /// No description provided for @searchRemovedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Search removed'**
  String get searchRemovedSnackbar;

  /// No description provided for @searchRemoveSavedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove saved search'**
  String get searchRemoveSavedTooltip;

  /// No description provided for @searchLandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Find anything'**
  String get searchLandingTitle;

  /// No description provided for @searchLandingBody.
  ///
  /// In en, this message translates to:
  /// **'Search titles, domains, tags, and operators like tag:dart or is:favorite.'**
  String get searchLandingBody;

  /// No description provided for @searchSavedSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved searches'**
  String get searchSavedSearchesTitle;

  /// No description provided for @searchSavedSearchesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Save useful searches with the star button.'**
  String get searchSavedSearchesEmpty;

  /// No description provided for @searchRecentSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecentSearchesTitle;

  /// No description provided for @searchRecentSearchesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Recent searches appear after you search.'**
  String get searchRecentSearchesEmpty;

  /// No description provided for @searchOperatorsHelp.
  ///
  /// In en, this message translates to:
  /// **'Operators: tag:, is:favorite, domain:, before:, after:'**
  String get searchOperatorsHelp;

  /// No description provided for @addIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste, share, or type a link'**
  String get addIntroTitle;

  /// No description provided for @addPasteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get addPasteTooltip;

  /// No description provided for @addViewDetailTooltip.
  ///
  /// In en, this message translates to:
  /// **'View detail'**
  String get addViewDetailTooltip;

  /// No description provided for @addSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get addSavedTitle;

  /// No description provided for @addSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New bookmark captured.'**
  String get addSavedSubtitle;

  /// No description provided for @addDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get addDuplicateTitle;

  /// No description provided for @addDuplicateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This URL is in your library.'**
  String get addDuplicateSubtitle;

  /// No description provided for @addInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get addInvalidTitle;

  /// No description provided for @addInvalidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Could not find a valid link in the input.'**
  String get addInvalidSubtitle;

  /// No description provided for @addErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get addErrorTitle;

  /// No description provided for @addErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get addErrorSubtitle;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @librarySettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get librarySettingsTooltip;

  /// No description provided for @libraryTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get libraryTagsTitle;

  /// No description provided for @libraryCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get libraryCollectionsTitle;

  /// No description provided for @libraryNoTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Tap + to create one.'**
  String get libraryNoTags;

  /// No description provided for @libraryLoadingTags.
  ///
  /// In en, this message translates to:
  /// **'Loading tags...'**
  String get libraryLoadingTags;

  /// No description provided for @libraryCouldNotLoadTags.
  ///
  /// In en, this message translates to:
  /// **'Could not load tags.'**
  String get libraryCouldNotLoadTags;

  /// No description provided for @libraryNoCollections.
  ///
  /// In en, this message translates to:
  /// **'No collections yet. Tap + to create one.'**
  String get libraryNoCollections;

  /// No description provided for @libraryLoadingCollections.
  ///
  /// In en, this message translates to:
  /// **'Loading collections...'**
  String get libraryLoadingCollections;

  /// No description provided for @libraryCouldNotLoadCollections.
  ///
  /// In en, this message translates to:
  /// **'Could not load collections.'**
  String get libraryCouldNotLoadCollections;

  /// No description provided for @librarySmartBadge.
  ///
  /// In en, this message translates to:
  /// **'SMART'**
  String get librarySmartBadge;

  /// No description provided for @libraryLiveSmartCollection.
  ///
  /// In en, this message translates to:
  /// **'Live smart collection'**
  String get libraryLiveSmartCollection;

  /// No description provided for @libraryCollectionItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 item} other {{count} items}}'**
  String libraryCollectionItemCount(int count);

  /// No description provided for @libraryCollectionActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collection actions'**
  String get libraryCollectionActionsTooltip;

  /// No description provided for @libraryDeleteTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String libraryDeleteTagTitle(Object name);

  /// No description provided for @libraryDeleteTagMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the tag from all bookmarks.'**
  String get libraryDeleteTagMessage;

  /// No description provided for @libraryDeleteCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String libraryDeleteCollectionTitle(Object title);

  /// No description provided for @libraryDeleteCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks inside will not be deleted.'**
  String get libraryDeleteCollectionMessage;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Behaviour'**
  String get settingsSectionBehaviour;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsSectionAutomation.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get settingsSectionAutomation;

  /// No description provided for @settingsSectionInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get settingsSectionInsights;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsExportBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Export backup (JSON)'**
  String get settingsExportBackupTitle;

  /// No description provided for @settingsRestoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup (JSON)'**
  String get settingsRestoreBackupTitle;

  /// No description provided for @settingsRestoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicates are merged safely'**
  String get settingsRestoreBackupSubtitle;

  /// No description provided for @settingsAutomationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-tag, archive, and more'**
  String get settingsAutomationSubtitle;

  /// No description provided for @settingsOnLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsOnLabel;

  /// No description provided for @settingsOffLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsOffLabel;

  /// No description provided for @settingsEnabledState.
  ///
  /// In en, this message translates to:
  /// **'enabled'**
  String get settingsEnabledState;

  /// No description provided for @settingsDisabledState.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get settingsDisabledState;

  /// No description provided for @settingsChangedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{label} {state}'**
  String settingsChangedSnackbar(Object label, Object state);

  /// No description provided for @automationGuideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Automation guide'**
  String get automationGuideTooltip;

  /// No description provided for @automationGuideCardTitle.
  ///
  /// In en, this message translates to:
  /// **'How rules work'**
  String get automationGuideCardTitle;

  /// No description provided for @automationGuideCardBody.
  ///
  /// In en, this message translates to:
  /// **'Rules run after a link is saved. Pick one “When” trigger, then chain one or more “Then” actions. Start narrow, keep rules named clearly, and check Debug logs if a rule did not fire.'**
  String get automationGuideCardBody;

  /// No description provided for @automationGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Automation guide'**
  String get automationGuideTitle;

  /// No description provided for @automationGuideTriggerTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Choose a trigger'**
  String get automationGuideTriggerTitle;

  /// No description provided for @automationGuideTriggerBody.
  ///
  /// In en, this message translates to:
  /// **'Use domain equals for exact sites like youtube.com, domain contains for broader matches like github, or URL contains for folders such as /blog/.'**
  String get automationGuideTriggerBody;

  /// No description provided for @automationGuideActionTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Chain actions'**
  String get automationGuideActionTitle;

  /// No description provided for @automationGuideActionBody.
  ///
  /// In en, this message translates to:
  /// **'Add a tag, add to a collection, favorite, archive, pin, or add a reminder. Actions run top-to-bottom inside each rule.'**
  String get automationGuideActionBody;

  /// No description provided for @automationGuideTestTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Test with one link'**
  String get automationGuideTestTitle;

  /// No description provided for @automationGuideTestBody.
  ///
  /// In en, this message translates to:
  /// **'Save a matching link, then open Debug logs from this screen to see whether the rule matched and what it changed.'**
  String get automationGuideTestBody;

  /// No description provided for @automationGuideExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get automationGuideExamplesTitle;

  /// No description provided for @automationGuideExamplesBody.
  ///
  /// In en, this message translates to:
  /// **'github → add tag “Code” + pin; youtube.com → add to collection “Watch later” + reminder in 2 days; /pricing → archive; unread for 30 days → add tag “Review”.'**
  String get automationGuideExamplesBody;

  /// No description provided for @automationRulesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No automation rules yet.\nTap + to create one.'**
  String get automationRulesEmpty;

  /// No description provided for @settingsDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stats & analytics'**
  String get settingsDashboardSubtitle;

  /// No description provided for @settingsResetDefaultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get settingsResetDefaultsTitle;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset settings?'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This only resets preferences (theme, language, etc.) — your bookmarks and data stay intact.'**
  String get settingsResetDialogBody;

  /// No description provided for @settingsResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetAction;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsExportFailed(Object error);

  /// No description provided for @settingsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsImportFailed(Object error);

  /// No description provided for @settingsImportSummary.
  ///
  /// In en, this message translates to:
  /// **'Imported {bookmarksImported} bookmarks ({bookmarksMerged} merged, {bookmarksSkipped} skipped), {tagsImported} tags, {collectionsImported} collections.'**
  String settingsImportSummary(int bookmarksImported, int bookmarksMerged,
      int bookmarksSkipped, int tagsImported, int collectionsImported);

  /// No description provided for @settingsBackupShareText.
  ///
  /// In en, this message translates to:
  /// **'Marky backup'**
  String get settingsBackupShareText;

  /// No description provided for @settingsSectionGestures.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get settingsSectionGestures;

  /// No description provided for @settingsSwipeRightLabel.
  ///
  /// In en, this message translates to:
  /// **'Swipe right'**
  String get settingsSwipeRightLabel;

  /// No description provided for @settingsSwipeLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'Swipe left'**
  String get settingsSwipeLeftLabel;

  /// No description provided for @settingsSwipeActionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select swipe action'**
  String get settingsSwipeActionDialogTitle;

  /// No description provided for @swipeActionToggleRead.
  ///
  /// In en, this message translates to:
  /// **'Read / Unread'**
  String get swipeActionToggleRead;

  /// No description provided for @swipeActionToggleArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive / Unarchive'**
  String get swipeActionToggleArchive;

  /// No description provided for @swipeActionToggleFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite / Unfavorite'**
  String get swipeActionToggleFavorite;

  /// No description provided for @swipeActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get swipeActionDelete;

  /// No description provided for @swipeActionOpenReader.
  ///
  /// In en, this message translates to:
  /// **'Open in Reader'**
  String get swipeActionOpenReader;

  /// No description provided for @swipeActionTogglePin.
  ///
  /// In en, this message translates to:
  /// **'Pin / Unpin'**
  String get swipeActionTogglePin;

  /// No description provided for @swipeActionNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get swipeActionNone;

  /// No description provided for @snackbarBookmarkPinned.
  ///
  /// In en, this message translates to:
  /// **'Bookmark pinned'**
  String get snackbarBookmarkPinned;

  /// No description provided for @snackbarBookmarkUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Bookmark unpinned'**
  String get snackbarBookmarkUnpinned;

  /// No description provided for @readingTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min read'**
  String readingTimeMinutes(int count);

  /// No description provided for @contentTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get contentTypeVideo;

  /// No description provided for @contentTypeCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get contentTypeCode;

  /// No description provided for @contentTypeDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get contentTypeDiscussion;

  /// No description provided for @contentTypeDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get contentTypeDocument;

  /// No description provided for @contentTypeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get contentTypeAudio;

  /// No description provided for @contentTypeProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get contentTypeProduct;

  /// No description provided for @contentTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get contentTypeImage;

  /// No description provided for @contentTypeArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get contentTypeArticle;

  /// No description provided for @snackbarMarkedAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get snackbarMarkedAsFavorite;

  /// No description provided for @snackbarMarkedAsUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get snackbarMarkedAsUnfavorite;

  /// No description provided for @actionUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get actionUnarchive;

  /// No description provided for @shareLinkSaved.
  ///
  /// In en, this message translates to:
  /// **'Shared link saved'**
  String get shareLinkSaved;

  /// No description provided for @shareLinkAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Link already saved'**
  String get shareLinkAlreadySaved;

  /// No description provided for @shareNoLinkFound.
  ///
  /// In en, this message translates to:
  /// **'No link found to save'**
  String get shareNoLinkFound;

  /// No description provided for @shareCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save shared link'**
  String get shareCouldNotSave;

  /// No description provided for @shareOverlaySavingTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get shareOverlaySavingTitle;

  /// No description provided for @shareOverlaySavingMessage.
  ///
  /// In en, this message translates to:
  /// **'Sending the shared item to Marky.'**
  String get shareOverlaySavingMessage;

  /// No description provided for @shareOverlaySavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get shareOverlaySavedTitle;

  /// No description provided for @shareOverlaySavedMessage.
  ///
  /// In en, this message translates to:
  /// **'1 shared item was saved to Marky.'**
  String get shareOverlaySavedMessage;

  /// No description provided for @shareOverlayDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get shareOverlayDuplicateTitle;

  /// No description provided for @shareOverlayDuplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'This shared item is already in your library.'**
  String get shareOverlayDuplicateMessage;

  /// No description provided for @shareOverlayInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not save'**
  String get shareOverlayInvalidTitle;

  /// No description provided for @shareOverlayInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'No saveable link was found in the shared item.'**
  String get shareOverlayInvalidMessage;

  /// No description provided for @shareOverlayErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get shareOverlayErrorTitle;

  /// No description provided for @shareOverlayErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not save this shared item. Please try again.'**
  String get shareOverlayErrorMessage;

  /// No description provided for @shareOverlayErrorMessageWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Could not save this shared item: {detail}'**
  String shareOverlayErrorMessageWithDetail(Object detail);

  /// No description provided for @shareOverlayOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open app'**
  String get shareOverlayOpenApp;

  /// No description provided for @detailBookmarkDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bookmark deleted'**
  String get detailBookmarkDeleted;

  /// No description provided for @detailCouldNotLoadBookmark.
  ///
  /// In en, this message translates to:
  /// **'Could not load bookmark'**
  String get detailCouldNotLoadBookmark;

  /// No description provided for @detailDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get detailDescriptionLabel;

  /// No description provided for @detailPreviewImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview image for {title}'**
  String detailPreviewImageLabel(Object title);

  /// No description provided for @detailFilterByDomainLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by domain {domain}'**
  String detailFilterByDomainLabel(Object domain);

  /// No description provided for @detailActionUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfav'**
  String get detailActionUnfavorite;

  /// No description provided for @detailActionUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get detailActionUnarchive;

  /// No description provided for @detailActionRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get detailActionRead;

  /// No description provided for @detailActionUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get detailActionUnread;

  /// No description provided for @detailActionPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get detailActionPin;

  /// No description provided for @detailActionUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get detailActionUnpin;

  /// No description provided for @detailLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get detailLinkCopied;

  /// No description provided for @detailDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get detailDeleteMessage;

  /// No description provided for @detailMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get detailMetadataTitle;

  /// No description provided for @detailMetaAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get detailMetaAuthor;

  /// No description provided for @detailMetaSite.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get detailMetaSite;

  /// No description provided for @detailMetaPublisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get detailMetaPublisher;

  /// No description provided for @detailMetaCanonical.
  ///
  /// In en, this message translates to:
  /// **'Canonical'**
  String get detailMetaCanonical;

  /// No description provided for @detailMetaSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get detailMetaSaved;

  /// No description provided for @detailMetaPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get detailMetaPublished;

  /// No description provided for @detailMetaLastOpened.
  ///
  /// In en, this message translates to:
  /// **'Last opened'**
  String get detailMetaLastOpened;

  /// No description provided for @detailMetaOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get detailMetaOpened;

  /// No description provided for @detailMetaSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get detailMetaSource;

  /// No description provided for @detailMetaType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get detailMetaType;

  /// No description provided for @detailMetaScraping.
  ///
  /// In en, this message translates to:
  /// **'Scraping'**
  String get detailMetaScraping;

  /// No description provided for @detailOpenedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 time} other {{count} times}}'**
  String detailOpenedTimes(int count);

  /// No description provided for @detailRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get detailRemindersTitle;

  /// No description provided for @detailAddReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get detailAddReminderTooltip;

  /// No description provided for @detailNoReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders set.'**
  String get detailNoReminders;

  /// No description provided for @detailInlineError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String detailInlineError(Object error);

  /// No description provided for @detailTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add tags'**
  String get detailTagsEmpty;

  /// No description provided for @detailAddTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get detailAddTagTitle;

  /// No description provided for @detailAllTagsAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'All tags already added.'**
  String get detailAllTagsAlreadyAdded;

  /// No description provided for @detailCollectionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add to a collection'**
  String get detailCollectionsEmpty;

  /// No description provided for @detailAddToCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get detailAddToCollectionTitle;

  /// No description provided for @detailNoCollectionsLeft.
  ///
  /// In en, this message translates to:
  /// **'No collections left to add to.'**
  String get detailNoCollectionsLeft;

  /// No description provided for @detailNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get detailNotesTitle;

  /// No description provided for @detailAddNoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get detailAddNoteTooltip;

  /// No description provided for @detailNoNotes.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a personal note.'**
  String get detailNoNotes;

  /// No description provided for @detailCouldNotLoadNotes.
  ///
  /// In en, this message translates to:
  /// **'Could not load notes: {error}'**
  String detailCouldNotLoadNotes(Object error);

  /// No description provided for @detailAddNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get detailAddNoteTitle;

  /// No description provided for @detailEditNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get detailEditNoteTitle;

  /// No description provided for @detailDeleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get detailDeleteNoteTitle;

  /// No description provided for @detailNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Type your note…'**
  String get detailNoteHint;

  /// No description provided for @detailNoteEdited.
  ///
  /// In en, this message translates to:
  /// **'· edited'**
  String get detailNoteEdited;

  /// No description provided for @detailLegacyNote.
  ///
  /// In en, this message translates to:
  /// **'Legacy note'**
  String get detailLegacyNote;

  /// No description provided for @detailConvertToNote.
  ///
  /// In en, this message translates to:
  /// **'Convert to note'**
  String get detailConvertToNote;

  /// No description provided for @detailMissingTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag #{id}'**
  String detailMissingTagLabel(int id);

  /// No description provided for @detailMissingCollectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection #{id}'**
  String detailMissingCollectionLabel(int id);

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

  /// No description provided for @reminderSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get reminderSheetTitle;

  /// No description provided for @reminderTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight (20:00)'**
  String get reminderTonight;

  /// No description provided for @reminderTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow (09:00)'**
  String get reminderTomorrow;

  /// No description provided for @reminderThisWeekend.
  ///
  /// In en, this message translates to:
  /// **'This weekend (Sat 10:00)'**
  String get reminderThisWeekend;

  /// No description provided for @reminderPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a date & time…'**
  String get reminderPickDateTime;

  /// No description provided for @reminderFutureTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a future reminder time'**
  String get reminderFutureTimeRequired;

  /// No description provided for @reminderPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required'**
  String get reminderPermissionRequired;

  /// No description provided for @reminderExactAlarmUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms are not available'**
  String get reminderExactAlarmUnavailable;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set'**
  String get reminderSet;

  /// No description provided for @detailActionRefetch.
  ///
  /// In en, this message translates to:
  /// **'Refetch'**
  String get detailActionRefetch;

  /// No description provided for @detailRefetchingMetadata.
  ///
  /// In en, this message translates to:
  /// **'Refetching metadata…'**
  String get detailRefetchingMetadata;

  /// No description provided for @detailMetadataRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Metadata refreshed'**
  String get detailMetadataRefreshed;

  /// No description provided for @colorPickerCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get colorPickerCustomColor;

  /// No description provided for @colorPickerHexLabel.
  ///
  /// In en, this message translates to:
  /// **'Hex color'**
  String get colorPickerHexLabel;

  /// No description provided for @colorPickerHexError.
  ///
  /// In en, this message translates to:
  /// **'Use #RRGGBB or #AARRGGBB'**
  String get colorPickerHexError;

  /// No description provided for @colorPickerUseColor.
  ///
  /// In en, this message translates to:
  /// **'Use color'**
  String get colorPickerUseColor;

  /// No description provided for @tagNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagNameHint;

  /// No description provided for @collectionNameHint.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get collectionNameHint;

  /// No description provided for @collectionDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get collectionDescriptionHint;

  /// No description provided for @pinToTop.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get pinToTop;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get actionUpdate;

  /// No description provided for @automationWhen.
  ///
  /// In en, this message translates to:
  /// **'When…'**
  String get automationWhen;

  /// No description provided for @automationThen.
  ///
  /// In en, this message translates to:
  /// **'Then…'**
  String get automationThen;

  /// No description provided for @automationAllFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required.'**
  String get automationAllFieldsRequired;

  /// No description provided for @automationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String automationSaveFailed(Object error);

  /// No description provided for @automationNoLogs.
  ///
  /// In en, this message translates to:
  /// **'No automation logs yet.'**
  String get automationNoLogs;

  /// No description provided for @automationDeleteRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String automationDeleteRuleTitle(Object name);

  /// No description provided for @automationEditRule.
  ///
  /// In en, this message translates to:
  /// **'Edit Rule'**
  String get automationEditRule;

  /// No description provided for @automationNewRule.
  ///
  /// In en, this message translates to:
  /// **'New Rule'**
  String get automationNewRule;

  /// No description provided for @automationRuleName.
  ///
  /// In en, this message translates to:
  /// **'Rule name'**
  String get automationRuleName;

  /// No description provided for @automationRuleDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get automationRuleDescription;

  /// No description provided for @automationRuleEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get automationRuleEnabled;

  /// No description provided for @automationRulePriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get automationRulePriority;

  /// No description provided for @automationRulePriorityHint.
  ///
  /// In en, this message translates to:
  /// **'Lower numbers run first.'**
  String get automationRulePriorityHint;

  /// No description provided for @automationTriggerType.
  ///
  /// In en, this message translates to:
  /// **'Trigger type'**
  String get automationTriggerType;

  /// No description provided for @automationActionType.
  ///
  /// In en, this message translates to:
  /// **'Action type'**
  String get automationActionType;

  /// No description provided for @automationAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add action'**
  String get automationAddAction;

  /// No description provided for @batchDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmarks?'**
  String get batchDeleteTitle;

  /// No description provided for @batchDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {This will permanently delete 1 bookmark.} other {This will permanently delete {count} bookmarks.}}'**
  String batchDeleteMessage(int count);

  /// No description provided for @homeFilteredLabel.
  ///
  /// In en, this message translates to:
  /// **'Filtered: {label}'**
  String homeFilteredLabel(Object label);

  /// No description provided for @remindersAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersAppBarTitle;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New Tag'**
  String get newTag;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTag;

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New Collection'**
  String get newCollection;

  /// No description provided for @editCollection.
  ///
  /// In en, this message translates to:
  /// **'Edit Collection'**
  String get editCollection;

  /// No description provided for @shareOpenBookmark.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get shareOpenBookmark;

  /// No description provided for @navigationQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get navigationQuickAdd;

  /// No description provided for @dashboardLibraryOverview.
  ///
  /// In en, this message translates to:
  /// **'LIBRARY OVERVIEW'**
  String get dashboardLibraryOverview;

  /// No description provided for @dashboardSavedLinks.
  ///
  /// In en, this message translates to:
  /// **'saved links'**
  String get dashboardSavedLinks;

  /// No description provided for @dashboardPercentRead.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% Read'**
  String dashboardPercentRead(int percentage);

  /// No description provided for @dashboardRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get dashboardRead;

  /// No description provided for @dashboardUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get dashboardUnread;

  /// No description provided for @dashboardFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get dashboardFavorites;

  /// No description provided for @dashboardArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get dashboardArchived;

  /// No description provided for @dashboardTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get dashboardTotal;

  /// No description provided for @dashboardUnreadStats.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get dashboardUnreadStats;

  /// No description provided for @dashboardThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get dashboardThisWeek;

  /// No description provided for @dashboardReadRate.
  ///
  /// In en, this message translates to:
  /// **'Read Rate'**
  String get dashboardReadRate;

  /// No description provided for @dashboardTopDomain.
  ///
  /// In en, this message translates to:
  /// **'Top Source'**
  String get dashboardTopDomain;

  /// No description provided for @dashboardLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days Activity'**
  String get dashboardLast7Days;

  /// No description provided for @dashboardSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String dashboardSavedCount(int count);

  /// No description provided for @dashboardTopDomainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Read Sources'**
  String get dashboardTopDomainsTitle;

  /// No description provided for @dashboardSourceBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Source Breakdown'**
  String get dashboardSourceBreakdownTitle;

  /// No description provided for @dashboardTopTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular Tags'**
  String get dashboardTopTagsTitle;

  /// No description provided for @readerRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get readerRetry;

  /// No description provided for @readerOpenOriginal.
  ///
  /// In en, this message translates to:
  /// **'Open Original Page in Browser'**
  String get readerOpenOriginal;

  /// No description provided for @readerThemePaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get readerThemePaper;

  /// No description provided for @readerThemeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get readerThemeSepia;

  /// No description provided for @readerThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get readerThemeDark;

  /// No description provided for @readerFontSerif.
  ///
  /// In en, this message translates to:
  /// **'Serif'**
  String get readerFontSerif;

  /// No description provided for @readerFontSans.
  ///
  /// In en, this message translates to:
  /// **'Sans'**
  String get readerFontSans;

  /// No description provided for @automationCreateRule.
  ///
  /// In en, this message translates to:
  /// **'Create rule'**
  String get automationCreateRule;

  /// No description provided for @automationMatchAll.
  ///
  /// In en, this message translates to:
  /// **'ALL (AND)'**
  String get automationMatchAll;

  /// No description provided for @automationMatchAny.
  ///
  /// In en, this message translates to:
  /// **'ANY (OR)'**
  String get automationMatchAny;

  /// No description provided for @automationAddCondition.
  ///
  /// In en, this message translates to:
  /// **'Add Condition'**
  String get automationAddCondition;

  /// No description provided for @automationAddActionBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Action'**
  String get automationAddActionBtn;

  /// No description provided for @automationFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get automationFillRequiredFields;

  /// No description provided for @automationRuleSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save rule: {error}'**
  String automationRuleSaveError(String error);

  /// No description provided for @automationTourBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get automationTourBack;

  /// No description provided for @automationTourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get automationTourSkip;

  /// No description provided for @automationTourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get automationTourNext;

  /// No description provided for @settingsUnreadReminderDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String settingsUnreadReminderDaily(String time);

  /// No description provided for @settingsUnreadReminderWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every {weekday} at {time}'**
  String settingsUnreadReminderWeekly(String weekday, String time);

  /// No description provided for @settingsUnreadReminderOffMsg.
  ///
  /// In en, this message translates to:
  /// **'Unread reminders disabled'**
  String get settingsUnreadReminderOffMsg;

  /// No description provided for @settingsUnreadReminderEmptyMsg.
  ///
  /// In en, this message translates to:
  /// **'Reminders will start when unread links are added'**
  String get settingsUnreadReminderEmptyMsg;

  /// No description provided for @settingsUnreadReminderDailySet.
  ///
  /// In en, this message translates to:
  /// **'Set for every day at {time}'**
  String settingsUnreadReminderDailySet(String time);

  /// No description provided for @settingsUnreadReminderWeeklySet.
  ///
  /// In en, this message translates to:
  /// **'Set for every {weekday} at {time}'**
  String settingsUnreadReminderWeeklySet(String weekday, String time);
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
