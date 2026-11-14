import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/nfc_provider.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nfcProvider = context.watch<NfcProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isTr = nfcProvider.locale.languageCode == 'tr';
    final assetPath = isTr ? 'assets/manual_tr.md' : 'assets/manual_en.md';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userManual)),
      body: FutureBuilder(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Markdown(data: snapshot.data!);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
