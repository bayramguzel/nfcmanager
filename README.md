# NFC Expert 🚀

A professional, high-quality NFC management application built with Flutter.

## Features ✨

- **Read NFC Tags**: Scan and parse NDEF records (Text, URI, Mime).
- **Write NFC Tags**: Create your own NFC tags with custom content.
- **Scan History**: Keep track of all your scanned tags locally.
- **Modern UI/UX**: Material 3 design with smooth animations and dark mode support.
- **Share & Open**: Easily share tag content or open URLs directly from the app.
- **Cross-Platform**: Supports both Android and iOS.

## Tech Stack 🛠️

- **Flutter**: UI Framework
- **nfc_manager**: Real NFC hardware interaction
- **Provider**: State management
- **Shared Preferences**: Local data persistence
- **Lottie**: Beautiful animations
- **Google Fonts**: Premium typography

## Getting Started 🏁

1. Clone the repository.
2. Run `flutter pub get`.
3. Ensure NFC is enabled on your physical device.
4. Run `flutter run`.

## Permissions 🔐

### Android
- `android.permission.NFC`

### iOS

Everything below is already committed under `ios/`; it is listed so the Xcode
project can be re-created or audited:

- **Near Field Communication Tag Reading** capability —
  `ios/Runner/Runner.entitlements` declares the `NDEF` and `TAG` session formats.
- `NFCReaderUsageDescription` — the purpose string shown by the iOS reader sheet.
- `com.apple.developer.nfc.readersession.iso7816.select-identifiers` — the bank,
  passport and Turkish ID AIDs the expert reader may select.
- `com.apple.developer.nfc.readersession.felica.systemcodes` — required because
  the app polls ISO 18092 (FeliCa).
- `NSUserTrackingUsageDescription` + the App Tracking Transparency prompt shown
  before Unity Ads starts (App Store requirement 5.1.2).
- `SKAdNetworkItems` — attribution identifiers for Unity LevelPlay.

Bundle id: `com.software41.nfcmanager` (identical on both platforms), minimum
iOS version: **13.0**.

Before the first iOS release:

1. Open `ios/Runner.xcworkspace` in Xcode, select the **Runner** target and pick
   your team under *Signing & Capabilities* (the NFC capability must be enabled
   for your App ID in the Apple Developer portal).
2. Create the app in App Store Connect, then set the numeric id in
   `AppPlatform.appStoreId` (`lib/core/platform_support.dart`) so the App Store
   links in the review flow and the share text resolve.
3. Replace the ad placement ids in `lib/services/ad_service.dart` if the iOS
   placements differ from the Android ones.
4. In App Store Connect, declare the advertising identifier usage and complete
   the privacy nutrition labels (NFC tag contents never leave the device).
5. iOS builds need macOS with Xcode and CocoaPods (`flutter build ipa`).

### iOS-native UI and interactions

- Native iOS tab bar (`CupertinoTabBar`) with the app's theme colours, iOS
  bouncing scroll physics and UIKit page transitions (swipe back works).
- Settings use iOS inset-grouped sections, language/theme pick a native action
  sheet, the colour picker and the Wi-Fi / vCard wizards slide up as sheets.
- History has a `CupertinoSearchTextField`, a native export action sheet and a
  long-press context menu (share / copy / favourite) on every tag; the tag card
  menu and the write progress dialog are also UIKit-styled.
- iPad share sheets are anchored correctly, and destructive actions use
  `CupertinoAlertDialog`.
- Home Screen quick actions: long-press the app icon for **Read**, **Write** and
  **History** shortcuts (localized, opens the matching tab).
- `Rate Now` in Settings opens the system rating sheet, and the About screen
  uses a native iOS alert.

### iOS device targeting

The iOS target is iPhone-only (`TARGETED_DEVICE_FAMILY = 1`) and declares
`UIRequiredDeviceCapabilities = [arm64, nfc]`, so the App Store only offers it to
NFC-capable iPhones. iPad has no NFC reader, so it is excluded on purpose.

### iOS platform differences

CoreNFC is more restricted than Android NFC:

- MIFARE Classic cannot be read on iOS; Ultralight/DESFire, ISO 7816, ISO 15693
  and FeliCa are supported.
- The reader sheet belongs to iOS, so starting a scan always shows a system
  overlay and returning to the app keeps the last scanned tag. Backgrounding
  the app cancels an open session; the UI returns to idle on resume.
- In-app rating uses `SKStoreReviewController` instead of a custom dialog, and
  the developer donation links are hidden (App Store Review 3.1.1).

---

## Advanced Readers & Parsers 🧩

This app now includes advanced, best-effort, non-destructive readers and parsers for a variety of standards (enabled from the **Gelişmiş Kart Okuma** screen):

- **EMV** (bank cards): automatic EMV TLV parsing for common AIDs and records.
- **MIFARE Classic**: safe read-only block reads and basic block parsing.
- **ISO‑15693 (NFC‑V)**: Get System Info and single-block reads with UID extraction.
- **FeliCa**: capture PMm and try gentle probes when available.
- **ICAO Passport (DG1)**: attempt DG1 (MRZ) reads and parse MRZ text when available.
- **Turkish ID (EF.PERSO)**: example probe and a safe preview parser (explicit user consent required).

Notes:
- Advanced probes are disabled by default; you must enable them in the advanced reader screen (toggle with confirmation).
- The app only performs **safe, non-destructive** read operations by default. Writes or destructive commands are not run automatically.

---

Made with ❤️ by the NFC Expert Team

## Building the iOS IPA with GitHub Actions

`.github/workflows/ios-ipa.yml` builds the iOS app on a macOS runner for every
push to `main` (and on demand from the Actions tab) and uploads an **unsigned**
IPA as the `nfcmanager-unsigned-ipa` artifact.

The IPA is not code signed, so iOS will not install it as-is. To test on a
physical iPhone:

1. Open a workflow run, download `nfcmanager-unsigned-ipa` and unzip it.
2. Install the `.ipa` with Sideloadly (or AltStore/SideStore) using your Apple
   ID. A free Apple ID works; the app then expires after 7 days.
3. On the iPhone trust the profile under Settings → General → VPN & Device
   Management.
4. NFC only exists on real iPhones (7 or newer); the iOS simulator has no NFC
   reader, so scanning can only be tested on a device.

With a paid Apple Developer account you can publish a signed IPA instead: add
the certificate, provisioning profile and team id as repository secrets and run
`flutter build ipa --release` after importing them in the workflow.
