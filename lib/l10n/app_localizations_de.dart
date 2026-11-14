// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'NFC Manager';

  @override
  String get skip => 'Überspringen';

  @override
  String get read => 'Lesen';

  @override
  String get write => 'Schreiben';

  @override
  String get expert => 'Experte';

  @override
  String get history => 'Verlauf';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsTab => 'Eins.';

  @override
  String get nfcReading => 'NFC-Lesen';

  @override
  String get nfcWriting => 'NFC-Schreiben';

  @override
  String get expertMode => 'Expertenmodus';

  @override
  String get clearHistory => 'Verlauf löschen';

  @override
  String get clearHistoryConfirm =>
      'Möchten Sie den gesamten Scanverlauf wirklich löschen?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get clear => 'Löschen';

  @override
  String get nfcActive => 'NFC Aktiv';

  @override
  String get nfcOff => 'NFC Aus - Zum Aktivieren tippen';

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get language => 'Sprache';

  @override
  String get userManual => 'Benutzerhandbuch';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get about => 'Über uns';

  @override
  String get socialMedia => 'Soziale Medien';

  @override
  String get donate => 'Spenden';

  @override
  String get feedback => 'Feedback';

  @override
  String get website => 'Webseite';

  @override
  String get version => 'Version';

  @override
  String get aboutInfo =>
      'NFC Manager ist ein professionelles Werkzeug zum Lesen und Schreiben von NFC-Tags.';

  @override
  String get contactUs => 'Kontaktieren Sie uns';

  @override
  String get themeColor => 'Designfarbe';

  @override
  String get readyToRead => 'Bereit zum Lesen';

  @override
  String get bringDeviceClose =>
      'Halten Sie Ihr Gerät an einen NFC-Tag oder eine Karte.';

  @override
  String get startScanning => 'Scan starten';

  @override
  String get readingCard => 'Karte wird gelesen...';

  @override
  String get bringCardWait =>
      'Halten Sie die Karte an die Rückseite des Geräts und warten Sie.';

  @override
  String get cardReadSuccess => 'Karte erfolgreich gelesen!';

  @override
  String get scanNewCard => 'Neue Karte scannen';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get success => 'Erfolg';

  @override
  String get error => 'Fehler';

  @override
  String get writing => 'Wird geschrieben...';

  @override
  String get bringCardClose =>
      'Halten Sie die Karte an die Rückseite des Geräts.';

  @override
  String get dataWrittenSuccess => 'Daten erfolgreich geschrieben!';

  @override
  String get writeToTag => 'Auf Tag schreiben';

  @override
  String get selectRecordType => 'Datensatztyp auswählen';

  @override
  String get content => 'Inhalt';

  @override
  String get mimeType => 'MIME-Typ';

  @override
  String get text => 'Text';

  @override
  String get uri => 'URI';

  @override
  String get mime => 'MIME';

  @override
  String get external => 'Extern';

  @override
  String get smartPoster => 'Smart Poster';

  @override
  String get warning => 'Warnung';

  @override
  String get writeWarning =>
      'Achtung: Einige Karten sind möglicherweise schreibgeschützt oder es kann beim Schreibvorgang zu Datenverlust kommen.';

  @override
  String get required => 'Erforderlich';

  @override
  String get urlError => 'URL muss mit http:// oder https:// beginnen';

  @override
  String get enterContent => 'Bitte Inhalt eingeben';

  @override
  String get enterMimeType => 'Bitte MIME-Typ eingeben';

  @override
  String get close => 'Schließen';

  @override
  String get welcomeTitle => 'Willkommen beim NFC Manager!';

  @override
  String get welcomeSubtitle =>
      'Sie können Ausweise, Bankkarten, Führerscheine und alle Arten von NFC-Karten lesen, speichern und teilen.';

  @override
  String get nfcEnsureActive =>
      'Stellen Sie sicher, dass NFC auf Ihrem Gerät aktiviert ist, um Ihre Karte zu scannen.';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get noHistory => 'Noch kein Verlauf';

  @override
  String get noHistoryDesc => 'Karten, die Sie lesen, werden hier aufgelistet.';

  @override
  String get sendApdu => 'APDU-Befehl senden';

  @override
  String get apduHint => 'APDU (Hex, z.B.: 00A4040008A0000002471001)';

  @override
  String get send => 'Senden';

  @override
  String get shareCardInfo => 'Karteninfo teilen';

  @override
  String get saveCardInfo => 'Karteninfo speichern';

  @override
  String get nfcCardInfo => 'NFC-Karteninfo';

  @override
  String get allowAdvancedProbes => 'Erweiterte Scans erlauben';

  @override
  String get advancedProbesDesc =>
      'Kann dazu führen, dass einige Karten die Verbindung trennen oder sperren.';

  @override
  String get scanExpert => 'Scannen (Expertenmodus)';

  @override
  String get cardSaved => 'Karte im Verlauf gespeichert';

  @override
  String get expertModeTitle => 'Expertenmodus';

  @override
  String get queryingCard => 'Karte wird abgefragt...';

  @override
  String get doNotRemoveCard => 'Bitte Karte nicht entfernen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get deepAnalysis => 'Tiefenanalyse der Karte';

  @override
  String get deepAnalysisDesc =>
      'In diesem Modus werden versteckte Dateien, Anwendungs-IDs und Low-Level-Protokolldaten der Karte abgefragt.';

  @override
  String get startAnalysis => 'Analyse starten';

  @override
  String get advancedQueries => 'Erweiterte Abfragen';

  @override
  String get advancedQueriesDesc =>
      'Versucht, Ausweis-, Reisepass- und Bankkartendaten zu lesen.';

  @override
  String get supportedProtocols => 'Unterstützte Protokolle:';

  @override
  String get analysisCompleted => 'Analyse abgeschlossen';

  @override
  String get rawAndAnalysis => 'Rohdaten und Analyse';

  @override
  String get lastApduResponse => 'Letzte APDU-Antwort:';

  @override
  String get securityWarning => 'Sicherheitswarnung';

  @override
  String get securityWarningDesc =>
      'Erweiterte Abfragen versuchen, sensible Daten (Name, MRZ usw.) der Karte zu lesen. Dieser Vorgang dient ausschließlich Lesezwecken und beschädigt die Karte nicht.';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get cardSavedSuccess => 'Karteninfo gespeichert!';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get details => 'Details';

  @override
  String get export => 'Exportieren';

  @override
  String get exportedToClipboard => 'In die Zwischenablage exportiert';

  @override
  String get open => 'Öffnen';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get type => 'Typ';

  @override
  String get uid => 'UID';

  @override
  String get standard => 'Standard';

  @override
  String get ndef => 'NDEF';

  @override
  String get available => 'Verfügbar';

  @override
  String get none => 'Keine';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get protocolBankId => 'ISO 7816 (Bank/Ausweis)';

  @override
  String get protocolJapan => 'FeliCa (Japan-Standard)';

  @override
  String get protocolPassport => 'ICAO 9303 (Reisepass)';

  @override
  String get search => 'Suchen';

  @override
  String get searchHistory => 'Im Verlauf suchen...';

  @override
  String get noResults => 'Keine Ergebnisse gefunden';

  @override
  String get exportHistory => 'Verlauf exportieren';

  @override
  String get historyExported => 'Verlauf in Downloads exportiert';

  @override
  String get exportError => 'Fehler beim Exportieren des Verlaufs';

  @override
  String get shareApp => 'App teilen';

  @override
  String get shareAppText =>
      'Entdecken Sie den NFC Manager - Das professionelle NFC-Tool für Android & iOS! https://play.google.com/store/apps/details?id=com.software41.nfcmanager';

  @override
  String get copy => 'Kopieren';

  @override
  String get share => 'Teilen';

  @override
  String get save => 'Speichern';

  @override
  String get nfcRecord => 'NFC-Datensatz';

  @override
  String get supportDeveloper => 'Entwickler unterstützen';

  @override
  String get watchAdToSupport => 'Werbung ansehen & unterstützen';

  @override
  String get watchAdToSupportDesc =>
      'Unterstützen Sie unser Projekt, indem Sie sich ein kurzes belohntes Werbevideo ansehen.';

  @override
  String get watchAd => 'Belohnungswerbung ansehen';

  @override
  String get adLoading =>
      'Werbung wird vorbereitet, bitte versuchen Sie es gleich erneut.';

  @override
  String get adRewardEarned =>
      'Vielen Dank für Ihre Unterstützung! Belohnung gewährt.';

  @override
  String get adFailed =>
      'Werbung konnte nicht geladen werden. Bitte Internetverbindung prüfen.';

  @override
  String get adFreeTitle => '24 Stunden werbefrei';

  @override
  String get adFreeActive => 'Werbefreier Modus aktiv';

  @override
  String get adFreeRemaining => 'Verbleibende Zeit';

  @override
  String get adFreeDesc =>
      'Sehen Sie sich ein kurzes belohntes Video an, um 24 Stunden lang alle Werbungen zu entfernen. Jederzeit verlängerbar (bis max. 48 Stunden).';

  @override
  String get adFreeActiveDesc =>
      'Sie nutzen derzeit den werbefreien Modus. Sie können jederzeit weitere Videos ansehen, um die werbefreie Zeit zu verlängern (max. 48 Stunden).';

  @override
  String get adFreeThanks =>
      'Vielen Dank für Ihre Unterstützung! ❤️ Ihre werbefreie Zeit wurde um 24 Stunden verlängert.';

  @override
  String get watchAdEarn24h => 'Belohnungsvideo ansehen (+24 Stunden)';

  @override
  String get adFreeCapped =>
      'Maximales 48-Stunden-Limit erreicht. Vielen Dank für Ihre Unterstützung!';

  @override
  String get adFreeTooltip => '24h Werbefrei';

  @override
  String get templates => 'Schnellvorlagen';

  @override
  String get favorites => 'Favoriten';

  @override
  String get total => 'gesamt';

  @override
  String get today => 'heute';

  @override
  String get exportCsv => 'Als CSV exportieren';

  @override
  String get templateEmail => 'E-Mail';

  @override
  String get templateLocation => 'Standort';

  @override
  String get templateWifiPreset => 'WIFI:T:WPA;S:MeinWLAN;P:passwort123;;';

  @override
  String get templateTelPreset => 'tel:+491234567890';

  @override
  String get templateEmailPreset => 'mailto:info@beispiel.de';

  @override
  String get templateSmsPreset => 'sms:+491234567890?body=Hallo';

  @override
  String get templateLocationPreset => 'geo:52.5200,13.4050';

  @override
  String get urlExample => 'URL (z.B.: https://google.com)';

  @override
  String get reviewTitle => 'Gefällt Ihnen unsere App?';

  @override
  String get reviewMessage =>
      'Ihr Feedback hilft uns sehr. Hätten Sie einen Moment Zeit, um NFC Manager auf Google Play zu bewerten?';

  @override
  String get reviewRateNow => 'Jetzt bewerten';

  @override
  String get reviewLater => 'Später';

  @override
  String get copyUid => 'UID kopieren';

  @override
  String get cloneTag => 'Auf Tag kopieren';

  @override
  String get eraseTag => 'Tag löschen (Leeren)';

  @override
  String get eraseTagConfirm =>
      'Möchten Sie alle NDEF-Daten von diesem Tag wirklich löschen?';

  @override
  String get lockTag => 'Tag sperren (Nur Lesen)';

  @override
  String get lockTagConfirm =>
      'Achtung: Dies sperrt den Tag DAUERHAFT gegen weiteres Beschreiben. Fortfahren?';

  @override
  String get categoryWebSocial => 'Web & Soziale Netzwerke';

  @override
  String get categoryConnectivity => 'Netzwerk & Verbindungen';

  @override
  String get categoryCommunication => 'Kommunikation & Kontakte';

  @override
  String get categoryLocation => 'Standort & Karten';

  @override
  String get categoryDataDev => 'Daten & Entwickler';

  @override
  String get tagTools => 'NFC-Tools';

  @override
  String get soundFeedback => 'Tonsignal beim Scannen';

  @override
  String get iosNfcHint =>
      'Auf dem iPhone öffnet iOS das NFC-Lesefenster. Halten Sie das iPhone an den Tag, bis er gelesen ist.';
}
