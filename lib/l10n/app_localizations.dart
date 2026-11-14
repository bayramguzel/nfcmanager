import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('pt'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NFC Manager'**
  String get appTitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @nfcReading.
  ///
  /// In en, this message translates to:
  /// **'NFC Reading'**
  String get nfcReading;

  /// No description provided for @nfcWriting.
  ///
  /// In en, this message translates to:
  /// **'NFC Writing'**
  String get nfcWriting;

  /// No description provided for @expertMode.
  ///
  /// In en, this message translates to:
  /// **'Expert Mode'**
  String get expertMode;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all scan history?'**
  String get clearHistoryConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @nfcActive.
  ///
  /// In en, this message translates to:
  /// **'NFC Active'**
  String get nfcActive;

  /// No description provided for @nfcOff.
  ///
  /// In en, this message translates to:
  /// **'NFC Off - Tap to open'**
  String get nfcOff;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @userManual.
  ///
  /// In en, this message translates to:
  /// **'User Manual'**
  String get userManual;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get socialMedia;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @aboutInfo.
  ///
  /// In en, this message translates to:
  /// **'NFC Manager is a professional tool for reading and writing NFC tags.'**
  String get aboutInfo;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @readyToRead.
  ///
  /// In en, this message translates to:
  /// **'Ready to Read'**
  String get readyToRead;

  /// No description provided for @bringDeviceClose.
  ///
  /// In en, this message translates to:
  /// **'Bring your device close to an NFC tag or card.'**
  String get bringDeviceClose;

  /// No description provided for @startScanning.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get startScanning;

  /// No description provided for @readingCard.
  ///
  /// In en, this message translates to:
  /// **'Reading card...'**
  String get readingCard;

  /// No description provided for @bringCardWait.
  ///
  /// In en, this message translates to:
  /// **'Bring the card close to the back of the device and wait.'**
  String get bringCardWait;

  /// No description provided for @cardReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card Read Successfully!'**
  String get cardReadSuccess;

  /// No description provided for @scanNewCard.
  ///
  /// In en, this message translates to:
  /// **'Scan New Card'**
  String get scanNewCard;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @writing.
  ///
  /// In en, this message translates to:
  /// **'Writing...'**
  String get writing;

  /// No description provided for @bringCardClose.
  ///
  /// In en, this message translates to:
  /// **'Bring the card close to the back of the device.'**
  String get bringCardClose;

  /// No description provided for @dataWrittenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data written successfully!'**
  String get dataWrittenSuccess;

  /// No description provided for @writeToTag.
  ///
  /// In en, this message translates to:
  /// **'Write to Tag'**
  String get writeToTag;

  /// No description provided for @selectRecordType.
  ///
  /// In en, this message translates to:
  /// **'Select Record Type'**
  String get selectRecordType;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @mimeType.
  ///
  /// In en, this message translates to:
  /// **'MIME Type'**
  String get mimeType;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @uri.
  ///
  /// In en, this message translates to:
  /// **'URI'**
  String get uri;

  /// No description provided for @mime.
  ///
  /// In en, this message translates to:
  /// **'MIME'**
  String get mime;

  /// No description provided for @external.
  ///
  /// In en, this message translates to:
  /// **'External'**
  String get external;

  /// No description provided for @smartPoster.
  ///
  /// In en, this message translates to:
  /// **'Smart Poster'**
  String get smartPoster;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @writeWarning.
  ///
  /// In en, this message translates to:
  /// **'Attention: Some cards may be write-protected or data loss may occur during the writing process.'**
  String get writeWarning;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @urlError.
  ///
  /// In en, this message translates to:
  /// **'URL must start with http:// or https://'**
  String get urlError;

  /// No description provided for @enterContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter content'**
  String get enterContent;

  /// No description provided for @enterMimeType.
  ///
  /// In en, this message translates to:
  /// **'Please enter a mime type'**
  String get enterMimeType;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to NFC Manager!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can read, save and share ID, bank, driver\'s license and all kinds of NFC cards.'**
  String get welcomeSubtitle;

  /// No description provided for @nfcEnsureActive.
  ///
  /// In en, this message translates to:
  /// **'Make sure NFC is enabled on your device to scan your card.'**
  String get nfcEnsureActive;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No History Yet'**
  String get noHistory;

  /// No description provided for @noHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'The cards you read will be listed here.'**
  String get noHistoryDesc;

  /// No description provided for @sendApdu.
  ///
  /// In en, this message translates to:
  /// **'Send APDU Command'**
  String get sendApdu;

  /// No description provided for @apduHint.
  ///
  /// In en, this message translates to:
  /// **'APDU (hex, e.g.: 00A4040008A0000002471001)'**
  String get apduHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @shareCardInfo.
  ///
  /// In en, this message translates to:
  /// **'Share Card Info'**
  String get shareCardInfo;

  /// No description provided for @saveCardInfo.
  ///
  /// In en, this message translates to:
  /// **'Save Card Info'**
  String get saveCardInfo;

  /// No description provided for @nfcCardInfo.
  ///
  /// In en, this message translates to:
  /// **'NFC Card Info'**
  String get nfcCardInfo;

  /// No description provided for @allowAdvancedProbes.
  ///
  /// In en, this message translates to:
  /// **'Allow Advanced Probes'**
  String get allowAdvancedProbes;

  /// No description provided for @advancedProbesDesc.
  ///
  /// In en, this message translates to:
  /// **'May cause some cards to disconnect or lock.'**
  String get advancedProbesDesc;

  /// No description provided for @scanExpert.
  ///
  /// In en, this message translates to:
  /// **'Scan (Expert Mode)'**
  String get scanExpert;

  /// No description provided for @cardSaved.
  ///
  /// In en, this message translates to:
  /// **'Card saved to history'**
  String get cardSaved;

  /// No description provided for @expertModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Expert Mode'**
  String get expertModeTitle;

  /// No description provided for @queryingCard.
  ///
  /// In en, this message translates to:
  /// **'Querying Card...'**
  String get queryingCard;

  /// No description provided for @doNotRemoveCard.
  ///
  /// In en, this message translates to:
  /// **'Please do not remove the card'**
  String get doNotRemoveCard;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @deepAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Deep Card Analysis'**
  String get deepAnalysis;

  /// No description provided for @deepAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'In this mode, hidden files, application IDs and low-level protocol data inside the card are queried.'**
  String get deepAnalysisDesc;

  /// No description provided for @startAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Start Analysis'**
  String get startAnalysis;

  /// No description provided for @advancedQueries.
  ///
  /// In en, this message translates to:
  /// **'Advanced Queries'**
  String get advancedQueries;

  /// No description provided for @advancedQueriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Attempts to read ID, Passport and Bank card data.'**
  String get advancedQueriesDesc;

  /// No description provided for @supportedProtocols.
  ///
  /// In en, this message translates to:
  /// **'Supported Protocols:'**
  String get supportedProtocols;

  /// No description provided for @analysisCompleted.
  ///
  /// In en, this message translates to:
  /// **'Analysis Completed'**
  String get analysisCompleted;

  /// No description provided for @rawAndAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Raw Data and Analysis'**
  String get rawAndAnalysis;

  /// No description provided for @lastApduResponse.
  ///
  /// In en, this message translates to:
  /// **'Last APDU Response:'**
  String get lastApduResponse;

  /// No description provided for @securityWarning.
  ///
  /// In en, this message translates to:
  /// **'Security Warning'**
  String get securityWarning;

  /// No description provided for @securityWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Advanced queries attempt to read sensitive data (name, MRZ, etc.) inside the card. This process is for reading purposes only and does not harm the card.'**
  String get securityWarningDesc;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cardSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card info saved!'**
  String get cardSavedSuccess;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Exported to clipboard'**
  String get exportedToClipboard;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @uid.
  ///
  /// In en, this message translates to:
  /// **'UID'**
  String get uid;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @ndef.
  ///
  /// In en, this message translates to:
  /// **'NDEF'**
  String get ndef;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @protocolBankId.
  ///
  /// In en, this message translates to:
  /// **'ISO 7816 (Bank/ID)'**
  String get protocolBankId;

  /// No description provided for @protocolJapan.
  ///
  /// In en, this message translates to:
  /// **'FeliCa (Japan Standard)'**
  String get protocolJapan;

  /// No description provided for @protocolPassport.
  ///
  /// In en, this message translates to:
  /// **'ICAO 9303 (Passport)'**
  String get protocolPassport;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search in history...'**
  String get searchHistory;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @exportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get exportHistory;

  /// No description provided for @historyExported.
  ///
  /// In en, this message translates to:
  /// **'History exported to downloads'**
  String get historyExported;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Failed to export history'**
  String get exportError;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'Check out NFC Manager - The professional NFC tool for Android and iOS! https://play.google.com/store/apps/details?id=com.software41.nfcmanager'**
  String get shareAppText;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @nfcRecord.
  ///
  /// In en, this message translates to:
  /// **'NFC Record'**
  String get nfcRecord;

  /// No description provided for @supportDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Support the Developer'**
  String get supportDeveloper;

  /// No description provided for @watchAdToSupport.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad & Support'**
  String get watchAdToSupport;

  /// No description provided for @watchAdToSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Support our project by watching a short rewarded video ad.'**
  String get watchAdToSupportDesc;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Rewarded Ad'**
  String get watchAd;

  /// No description provided for @adLoading.
  ///
  /// In en, this message translates to:
  /// **'Ad is preparing, please try again in a few moments.'**
  String get adLoading;

  /// No description provided for @adRewardEarned.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting us! Reward granted.'**
  String get adRewardEarned;

  /// No description provided for @adFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not display ad. Please check your internet connection.'**
  String get adFailed;

  /// No description provided for @adFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'24-Hour Ad-Free'**
  String get adFreeTitle;

  /// No description provided for @adFreeActive.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free Mode Active'**
  String get adFreeActive;

  /// No description provided for @adFreeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining Time'**
  String get adFreeRemaining;

  /// No description provided for @adFreeDesc.
  ///
  /// In en, this message translates to:
  /// **'Watch a short rewarded video ad to remove all ads for 24 hours. You can watch again anytime to support us (Stacks up to 48 hours maximum).'**
  String get adFreeDesc;

  /// No description provided for @adFreeActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'You are currently enjoying ad-free mode. You can watch rewarded ads again anytime to support us and extend your ad-free time (Up to 48 hours max).'**
  String get adFreeActiveDesc;

  /// No description provided for @adFreeThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you very much for your support! ❤️ Your ad-free duration has been extended by 24 hours.'**
  String get adFreeThanks;

  /// No description provided for @watchAdEarn24h.
  ///
  /// In en, this message translates to:
  /// **'Watch Rewarded Ad (+24 Hours)'**
  String get watchAdEarn24h;

  /// No description provided for @adFreeCapped.
  ///
  /// In en, this message translates to:
  /// **'Maximum 48-hour ad-free limit reached. Thank you for your support!'**
  String get adFreeCapped;

  /// No description provided for @adFreeTooltip.
  ///
  /// In en, this message translates to:
  /// **'24h Ad-Free'**
  String get adFreeTooltip;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Quick Templates'**
  String get templates;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportCsv;

  /// No description provided for @templateEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get templateEmail;

  /// No description provided for @templateLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get templateLocation;

  /// No description provided for @templateWifiPreset.
  ///
  /// In en, this message translates to:
  /// **'WIFI:T:WPA;S:MyWifiNetwork;P:password123;;'**
  String get templateWifiPreset;

  /// No description provided for @templateTelPreset.
  ///
  /// In en, this message translates to:
  /// **'tel:+1234567890'**
  String get templateTelPreset;

  /// No description provided for @templateEmailPreset.
  ///
  /// In en, this message translates to:
  /// **'mailto:info@example.com'**
  String get templateEmailPreset;

  /// No description provided for @templateSmsPreset.
  ///
  /// In en, this message translates to:
  /// **'sms:+1234567890?body=Hello'**
  String get templateSmsPreset;

  /// No description provided for @templateLocationPreset.
  ///
  /// In en, this message translates to:
  /// **'geo:40.7128,-74.0060'**
  String get templateLocationPreset;

  /// No description provided for @urlExample.
  ///
  /// In en, this message translates to:
  /// **'URL (ex: https://google.com)'**
  String get urlExample;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you like our app?'**
  String get reviewTitle;

  /// No description provided for @reviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve. Would you take a moment to rate NFC Manager on Google Play?'**
  String get reviewMessage;

  /// No description provided for @reviewRateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get reviewRateNow;

  /// No description provided for @reviewLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get reviewLater;

  /// No description provided for @copyUid.
  ///
  /// In en, this message translates to:
  /// **'Copy UID'**
  String get copyUid;

  /// No description provided for @cloneTag.
  ///
  /// In en, this message translates to:
  /// **'Write to Another Tag'**
  String get cloneTag;

  /// No description provided for @eraseTag.
  ///
  /// In en, this message translates to:
  /// **'Erase Tag (Clear)'**
  String get eraseTag;

  /// No description provided for @eraseTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to erase all NDEF data from this tag?'**
  String get eraseTagConfirm;

  /// No description provided for @lockTag.
  ///
  /// In en, this message translates to:
  /// **'Lock Tag (Read-Only)'**
  String get lockTag;

  /// No description provided for @lockTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Warning: This permanently locks the tag against any future writing. Proceed?'**
  String get lockTagConfirm;

  /// No description provided for @categoryWebSocial.
  ///
  /// In en, this message translates to:
  /// **'Web & Social Media'**
  String get categoryWebSocial;

  /// No description provided for @categoryConnectivity.
  ///
  /// In en, this message translates to:
  /// **'Network & Connectivity'**
  String get categoryConnectivity;

  /// No description provided for @categoryCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication & Contact'**
  String get categoryCommunication;

  /// No description provided for @categoryLocation.
  ///
  /// In en, this message translates to:
  /// **'Location & Navigation'**
  String get categoryLocation;

  /// No description provided for @categoryDataDev.
  ///
  /// In en, this message translates to:
  /// **'Data & Development'**
  String get categoryDataDev;

  /// No description provided for @tagTools.
  ///
  /// In en, this message translates to:
  /// **'NFC Tools'**
  String get tagTools;

  /// No description provided for @soundFeedback.
  ///
  /// In en, this message translates to:
  /// **'Sound on Scan'**
  String get soundFeedback;

  /// No description provided for @iosNfcHint.
  ///
  /// In en, this message translates to:
  /// **'On iPhone, iOS opens the NFC reader sheet for you. Hold your iPhone near the tag until it is read.'**
  String get iosNfcHint;
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
      <String>['de', 'en', 'pt', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
