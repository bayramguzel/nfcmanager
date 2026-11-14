// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NFC Manager';

  @override
  String get skip => 'Skip';

  @override
  String get read => 'Read';

  @override
  String get write => 'Write';

  @override
  String get expert => 'Expert';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTab => 'Settings';

  @override
  String get nfcReading => 'NFC Reading';

  @override
  String get nfcWriting => 'NFC Writing';

  @override
  String get expertMode => 'Expert Mode';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryConfirm =>
      'Are you sure you want to clear all scan history?';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get nfcActive => 'NFC Active';

  @override
  String get nfcOff => 'NFC Off - Tap to open';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get language => 'Language';

  @override
  String get userManual => 'User Manual';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get socialMedia => 'Social Media';

  @override
  String get donate => 'Donate';

  @override
  String get feedback => 'Feedback';

  @override
  String get website => 'Website';

  @override
  String get version => 'Version';

  @override
  String get aboutInfo =>
      'NFC Manager is a professional tool for reading and writing NFC tags.';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get readyToRead => 'Ready to Read';

  @override
  String get bringDeviceClose =>
      'Bring your device close to an NFC tag or card.';

  @override
  String get startScanning => 'Start Scanning';

  @override
  String get readingCard => 'Reading card...';

  @override
  String get bringCardWait =>
      'Bring the card close to the back of the device and wait.';

  @override
  String get cardReadSuccess => 'Card Read Successfully!';

  @override
  String get scanNewCard => 'Scan New Card';

  @override
  String get errorOccurred => 'An Error Occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get writing => 'Writing...';

  @override
  String get bringCardClose =>
      'Bring the card close to the back of the device.';

  @override
  String get dataWrittenSuccess => 'Data written successfully!';

  @override
  String get writeToTag => 'Write to Tag';

  @override
  String get selectRecordType => 'Select Record Type';

  @override
  String get content => 'Content';

  @override
  String get mimeType => 'MIME Type';

  @override
  String get text => 'Text';

  @override
  String get uri => 'URI';

  @override
  String get mime => 'MIME';

  @override
  String get external => 'External';

  @override
  String get smartPoster => 'Smart Poster';

  @override
  String get warning => 'Warning';

  @override
  String get writeWarning =>
      'Attention: Some cards may be write-protected or data loss may occur during the writing process.';

  @override
  String get required => 'Required';

  @override
  String get urlError => 'URL must start with http:// or https://';

  @override
  String get enterContent => 'Please enter content';

  @override
  String get enterMimeType => 'Please enter a mime type';

  @override
  String get close => 'Close';

  @override
  String get welcomeTitle => 'Welcome to NFC Manager!';

  @override
  String get welcomeSubtitle =>
      'You can read, save and share ID, bank, driver\'s license and all kinds of NFC cards.';

  @override
  String get nfcEnsureActive =>
      'Make sure NFC is enabled on your device to scan your card.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get noHistory => 'No History Yet';

  @override
  String get noHistoryDesc => 'The cards you read will be listed here.';

  @override
  String get sendApdu => 'Send APDU Command';

  @override
  String get apduHint => 'APDU (hex, e.g.: 00A4040008A0000002471001)';

  @override
  String get send => 'Send';

  @override
  String get shareCardInfo => 'Share Card Info';

  @override
  String get saveCardInfo => 'Save Card Info';

  @override
  String get nfcCardInfo => 'NFC Card Info';

  @override
  String get allowAdvancedProbes => 'Allow Advanced Probes';

  @override
  String get advancedProbesDesc =>
      'May cause some cards to disconnect or lock.';

  @override
  String get scanExpert => 'Scan (Expert Mode)';

  @override
  String get cardSaved => 'Card saved to history';

  @override
  String get expertModeTitle => 'Expert Mode';

  @override
  String get queryingCard => 'Querying Card...';

  @override
  String get doNotRemoveCard => 'Please do not remove the card';

  @override
  String get retry => 'Retry';

  @override
  String get deepAnalysis => 'Deep Card Analysis';

  @override
  String get deepAnalysisDesc =>
      'In this mode, hidden files, application IDs and low-level protocol data inside the card are queried.';

  @override
  String get startAnalysis => 'Start Analysis';

  @override
  String get advancedQueries => 'Advanced Queries';

  @override
  String get advancedQueriesDesc =>
      'Attempts to read ID, Passport and Bank card data.';

  @override
  String get supportedProtocols => 'Supported Protocols:';

  @override
  String get analysisCompleted => 'Analysis Completed';

  @override
  String get rawAndAnalysis => 'Raw Data and Analysis';

  @override
  String get lastApduResponse => 'Last APDU Response:';

  @override
  String get securityWarning => 'Security Warning';

  @override
  String get securityWarningDesc =>
      'Advanced queries attempt to read sensitive data (name, MRZ, etc.) inside the card. This process is for reading purposes only and does not harm the card.';

  @override
  String get confirm => 'Confirm';

  @override
  String get cardSavedSuccess => 'Card info saved!';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get details => 'Details';

  @override
  String get export => 'Export';

  @override
  String get exportedToClipboard => 'Exported to clipboard';

  @override
  String get open => 'Open';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get type => 'Type';

  @override
  String get uid => 'UID';

  @override
  String get standard => 'Standard';

  @override
  String get ndef => 'NDEF';

  @override
  String get available => 'Available';

  @override
  String get none => 'None';

  @override
  String get unknown => 'Unknown';

  @override
  String get protocolBankId => 'ISO 7816 (Bank/ID)';

  @override
  String get protocolJapan => 'FeliCa (Japan Standard)';

  @override
  String get protocolPassport => 'ICAO 9303 (Passport)';

  @override
  String get search => 'Search';

  @override
  String get searchHistory => 'Search in history...';

  @override
  String get noResults => 'No results found';

  @override
  String get exportHistory => 'Export History';

  @override
  String get historyExported => 'History exported to downloads';

  @override
  String get exportError => 'Failed to export history';

  @override
  String get shareApp => 'Share App';

  @override
  String get shareAppText =>
      'Check out NFC Manager - The professional NFC tool for Android and iOS! https://play.google.com/store/apps/details?id=com.software41.nfcmanager';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get save => 'Save';

  @override
  String get nfcRecord => 'NFC Record';

  @override
  String get supportDeveloper => 'Support the Developer';

  @override
  String get watchAdToSupport => 'Watch Ad & Support';

  @override
  String get watchAdToSupportDesc =>
      'Support our project by watching a short rewarded video ad.';

  @override
  String get watchAd => 'Watch Rewarded Ad';

  @override
  String get adLoading => 'Ad is preparing, please try again in a few moments.';

  @override
  String get adRewardEarned => 'Thank you for supporting us! Reward granted.';

  @override
  String get adFailed =>
      'Could not display ad. Please check your internet connection.';

  @override
  String get adFreeTitle => '24-Hour Ad-Free';

  @override
  String get adFreeActive => 'Ad-Free Mode Active';

  @override
  String get adFreeRemaining => 'Remaining Time';

  @override
  String get adFreeDesc =>
      'Watch a short rewarded video ad to remove all ads for 24 hours. You can watch again anytime to support us (Stacks up to 48 hours maximum).';

  @override
  String get adFreeActiveDesc =>
      'You are currently enjoying ad-free mode. You can watch rewarded ads again anytime to support us and extend your ad-free time (Up to 48 hours max).';

  @override
  String get adFreeThanks =>
      'Thank you very much for your support! ❤️ Your ad-free duration has been extended by 24 hours.';

  @override
  String get watchAdEarn24h => 'Watch Rewarded Ad (+24 Hours)';

  @override
  String get adFreeCapped =>
      'Maximum 48-hour ad-free limit reached. Thank you for your support!';

  @override
  String get adFreeTooltip => '24h Ad-Free';

  @override
  String get templates => 'Quick Templates';

  @override
  String get favorites => 'Favorites';

  @override
  String get total => 'total';

  @override
  String get today => 'today';

  @override
  String get exportCsv => 'Export as CSV';

  @override
  String get templateEmail => 'Email';

  @override
  String get templateLocation => 'Location';

  @override
  String get templateWifiPreset => 'WIFI:T:WPA;S:MyWifiNetwork;P:password123;;';

  @override
  String get templateTelPreset => 'tel:+1234567890';

  @override
  String get templateEmailPreset => 'mailto:info@example.com';

  @override
  String get templateSmsPreset => 'sms:+1234567890?body=Hello';

  @override
  String get templateLocationPreset => 'geo:40.7128,-74.0060';

  @override
  String get urlExample => 'URL (ex: https://google.com)';

  @override
  String get reviewTitle => 'Do you like our app?';

  @override
  String get reviewMessage =>
      'Your feedback helps us improve. Would you take a moment to rate NFC Manager on Google Play?';

  @override
  String get reviewRateNow => 'Rate Now';

  @override
  String get reviewLater => 'Later';

  @override
  String get copyUid => 'Copy UID';

  @override
  String get cloneTag => 'Write to Another Tag';

  @override
  String get eraseTag => 'Erase Tag (Clear)';

  @override
  String get eraseTagConfirm =>
      'Are you sure you want to erase all NDEF data from this tag?';

  @override
  String get lockTag => 'Lock Tag (Read-Only)';

  @override
  String get lockTagConfirm =>
      'Warning: This permanently locks the tag against any future writing. Proceed?';

  @override
  String get categoryWebSocial => 'Web & Social Media';

  @override
  String get categoryConnectivity => 'Network & Connectivity';

  @override
  String get categoryCommunication => 'Communication & Contact';

  @override
  String get categoryLocation => 'Location & Navigation';

  @override
  String get categoryDataDev => 'Data & Development';

  @override
  String get tagTools => 'NFC Tools';

  @override
  String get soundFeedback => 'Sound on Scan';

  @override
  String get iosNfcHint =>
      'On iPhone, iOS opens the NFC reader sheet for you. Hold your iPhone near the tag until it is read.';
}
