import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_expert/l10n/app_localizations.dart';
import 'package:nfc_expert/models/nfc_record.dart';
import 'package:nfc_expert/providers/nfc_provider.dart';
import 'package:nfc_expert/ui/screens/history_screen.dart';
import 'package:nfc_expert/ui/screens/settings_screen.dart';
import 'package:nfc_expert/ui/screens/write_screen.dart';

Widget _wrap(Widget child, NfcProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('tr'),
      home: child,
    ),
  );
}

/// Verifies the iOS-only widget branches render without throwing. The app
/// cannot be built on Windows, so these checks guard the Cupertino paths.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('iOS settings uses inset-grouped sections', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final provider = NfcProvider();
    await tester.pumpWidget(_wrap(const SettingsScreen(), provider));
    await tester.pump();

    expect(find.byType(CupertinoListSection), findsWidgets);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS history uses the native search field and context menu', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final provider = NfcProvider();
    provider.addRecord(
      NfcRecord(type: NfcRecordType.text, content: 'merhaba etiket'),
    );
    await tester.pumpWidget(_wrap(const HistoryScreen(), provider));
    await tester.pump();

    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    expect(find.byType(CupertinoContextMenu), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS write screen uses the sliding segmented control', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final provider = NfcProvider();
    await tester.pumpWidget(_wrap(const WriteScreen(), provider));
    await tester.pump();

    expect(
      find.byType(CupertinoSlidingSegmentedControl<NfcRecordType>),
      findsOneWidget,
    );
    debugDefaultTargetPlatformOverride = null;
  });
}
