import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/nfc_provider.dart';
import '../../core/platform_support.dart';
import '../widgets/record_card.dart';
import '../widgets/platform_adaptive.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start scan if user enabled it and NFC is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NfcProvider>();
      if (provider.autoScan &&
          provider.isNfcAvailable &&
          provider.status == NfcStatus.idle) {
        provider.startScan();
      }
    });
  }

  void _handleTap(NfcProvider provider) {
    if (provider.status == NfcStatus.idle) {
      provider.startScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nfcProvider = context.watch<NfcProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: GestureDetector(
        onTap: () => _handleTap(nfcProvider),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildContent(context, nfcProvider, l10n),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent(
    BuildContext context,
    NfcProvider nfcProvider,
    AppLocalizations l10n,
  ) {
    if (nfcProvider.status == NfcStatus.idle) {
      return Column(
        key: const ValueKey('idle'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/onboarding_nfc.json',
            height: 200,
            repeat: true,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.readyToRead,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.bringDeviceClose,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          if (AppPlatform.isIOS) ...[
            const SizedBox(height: 12),
            Text(
              l10n.iosNfcHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: Text(l10n.startScanning),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            onPressed: () => nfcProvider.startScan(),
          ),
        ],
      );
    } else if (nfcProvider.status == NfcStatus.scanning) {
      return Column(
        key: const ValueKey('scanning'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AdaptiveActivityIndicator(
                radius: 42,
                size: 180,
                color: Theme.of(context).colorScheme.primary,
              ),
              Lottie.asset('assets/lottie/onboarding_nfc.json', height: 120),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            l10n.readingCard,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(l10n.bringCardWait, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => nfcProvider.stopScan(),
            icon: const Icon(Icons.close),
            label: Text(l10n.cancel, style: const TextStyle(fontSize: 16)),
          ),
        ],
      );
    } else if (nfcProvider.status == NfcStatus.success &&
        nfcProvider.lastReadRecord != null) {
      return SingleChildScrollView(
        key: const ValueKey('success'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              l10n.cardReadSuccess,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            RecordCard(
              record: nfcProvider.lastReadRecord!,
              onToggleFavorite: () =>
                  nfcProvider.toggleFavorite(nfcProvider.lastReadRecord!.id),
              onClone: () =>
                  nfcProvider.setClonedRecord(nfcProvider.lastReadRecord!),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => nfcProvider.startScan(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.scanNewCard),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      );
    } else if (nfcProvider.status == NfcStatus.error) {
      return Column(
        key: const ValueKey('error'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 100, color: Colors.red),
          const SizedBox(height: 24),
          Text(
            l10n.errorOccurred,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              nfcProvider.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => nfcProvider.startScan(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.tryAgain),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
