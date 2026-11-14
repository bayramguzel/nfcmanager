import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';
import '../../models/nfc_record.dart';
import '../../providers/nfc_provider.dart';
import '../../services/ad_service.dart';
import '../../services/nfc_advanced_service.dart';
import '../widgets/platform_adaptive.dart';
import '../widgets/platform_dialogs.dart';

class AdvancedReadScreen extends StatefulWidget {
  const AdvancedReadScreen({super.key});

  @override
  State<AdvancedReadScreen> createState() => _AdvancedReadScreenState();
}

class _AdvancedReadScreenState extends State<AdvancedReadScreen> {
  Map<String, dynamic>? _cardInfo;
  String? _apduResult;
  bool _loading = false;
  String? _error;
  bool _allowAdvanced = false;

  Future<void> _scanCard() async {
    setState(() {
      _loading = true;
      _error = null;
      _cardInfo = null;
      _apduResult = null;
    });
    final info = await NfcAdvancedService.pollCard(
      allowAdvanced: _allowAdvanced,
    );
    if (info['error'] != null) {
      setState(() {
        _error = info['error'];
        _loading = false;
      });
      return;
    }
    setState(() {
      _cardInfo = info;
      _loading = false;
    });
  }

  Future<void> _sendApdu() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showPlatformTextPrompt(
      context,
      title: l10n.sendApdu,
      hint: l10n.apduHint,
      submitLabel: l10n.send,
      cancelLabel: l10n.cancel,
      controller: controller,
    );
    controller.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() => _loading = true);
      final apduResult = await NfcAdvancedService.sendApdu(result);
      setState(() {
        _apduResult = apduResult;
        _loading = false;
      });
    }
  }

  void _shareCardInfo() {
    final l10n = AppLocalizations.of(context)!;
    if (_cardInfo != null) {
      final text = _cardInfo!.entries
          .map((e) => "${e.key}: ${e.value}")
          .join("\n");
      SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: l10n.nfcCardInfo,
          sharePositionOrigin: AppPlatform.shareOrigin(context),
        ),
      );
    }
  }

  void _saveCardInfo() {
    final l10n = AppLocalizations.of(context)!;
    if (_cardInfo != null) {
      final provider = Provider.of<NfcProvider>(context, listen: false);
      NfcRecordType bestType = NfcRecordType.unknown;
      try {
        final ndef = _cardInfo!['ndef'];
        if (ndef != null &&
            ndef is Map &&
            ndef['records'] is List &&
            (ndef['records'] as List).isNotEmpty) {
          final first = (ndef['records'] as List).first as Map<String, dynamic>;
          switch (first['category']) {
            case 'text':
              bestType = NfcRecordType.text;
              break;
            case 'uri':
              bestType = NfcRecordType.uri;
              break;
            case 'mime':
              bestType = NfcRecordType.mime;
              break;
            case 'external':
              bestType = NfcRecordType.external;
              break;
            case 'smartposter':
              bestType = NfcRecordType.smartPoster;
              break;
            default:
              bestType = NfcRecordType.unknown;
          }
        }
      } catch (_) {}

      final record = NfcRecord(
        type: bestType,
        content: _cardInfo!.entries
            .map((e) => "${e.key}: ${e.value}")
            .join("\n"),
        metadata: _cardInfo,
      );
      provider.addRecord(record);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cardSavedSuccess)));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allowAdvanced = prefs.getBool('allow_advanced_probes') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expertModeTitle),
        actions: [
          if (_cardInfo != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareCardInfo,
              tooltip: l10n.share,
            ),
          if (_cardInfo != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveCardInfo,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AdaptiveActivityIndicator(radius: 22, size: 44),
                  const SizedBox(height: 24),
                  Text(l10n.queryingCard, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    l10n.doNotRemoveCard,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _scanCard,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            )
          : _cardInfo == null
          ? _buildIdleState(context)
          : _buildResultState(context),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 24.0 + bottomPad,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Icon(Icons.psychology, size: 100, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            l10n.deepAnalysis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.deepAnalysisDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
          if (AppPlatform.isIOS) ...[
            const SizedBox(height: 12),
            Text(
              l10n.iosNfcHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _scanCard,
            icon: const Icon(Icons.search),
            label: Text(l10n.startAnalysis),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              AdService.instance.showRewardedAd(
                onReward: () {
                  AdService.instance.addAdFreeHours(24);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.adFreeThanks,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onFailed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.adLoading),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.stars_rounded, color: Colors.amber),
            label: Text(l10n.watchAdToSupport),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF282115)
                  : const Color(0xFFFEF7ED),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF4A381F)
                    : const Color(0xFFFDE5C5),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SwitchListTile.adaptive(
              title: Text(
                l10n.advancedQueries,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l10n.advancedQueriesDesc),
              value: _allowAdvanced,
              onChanged: _toggleAdvanced,
              secondary: const Icon(Icons.security, color: Color(0xFFD97706)),
            ),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.supportedProtocols,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          _buildProtocolList(),
        ],
      ),
    );
  }

  Widget _buildProtocolList() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final protocols = [
      {'name': l10n.protocolBankId, 'icon': Icons.credit_card},
      {'name': 'ISO 14443 (NFC-A/B)', 'icon': Icons.nfc},
      {'name': 'ISO 15693 (NFC-V)', 'icon': Icons.settings_input_antenna},
      // CoreNFC has no MIFARE Classic support; only Ultralight/DESFire are read.
      if (!AppPlatform.isIOS)
        {'name': 'MIFARE Classic/DESFire', 'icon': Icons.memory},
      if (AppPlatform.isIOS)
        {'name': 'MIFARE Ultralight / DESFire', 'icon': Icons.memory},
      {'name': l10n.protocolJapan, 'icon': Icons.payment},
      {'name': l10n.protocolPassport, 'icon': Icons.import_contacts},
    ];

    return Column(
      children: protocols
          .map(
            (p) => ListTile(
              leading: Icon(
                p['icon'] as IconData,
                color: theme.colorScheme.primary,
              ),
              title: Text(p['name'] as String),
              dense: true,
            ),
          )
          .toList(),
    );
  }

  Widget _buildResultState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + bottomPad,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.rawAndAnalysis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton.icon(
                onPressed: _sendApdu,
                icon: const Icon(Icons.code),
                label: Text(l10n.sendApdu),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._cardInfo!.entries.map((e) => _buildDataEntry(e.key, e.value)),
          if (_apduResult != null) ...[
            const Divider(),
            Text(
              l10n.lastApduResponse,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _apduResult!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF162D2B), const Color(0xFF1B3834)]
              : [const Color(0xFFE2F4F2), const Color(0xFFEAF7EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF28504B) : const Color(0xFFBFE5E0),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF234B45)
                      : const Color(0xFFC7EBE6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00897B),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.analysisCompleted,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF133633),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSummaryChip(
                l10n.type,
                _cardInfo!['type'] ?? l10n.unknown,
                isDark,
              ),
              _buildSummaryChip(
                l10n.uid,
                _cardInfo!['uid'] ?? l10n.none,
                isDark,
              ),
              _buildSummaryChip(
                l10n.standard,
                _cardInfo!['standard'] ?? l10n.unknown,
                isDark,
              ),
              if (_cardInfo!['ndef'] != null)
                _buildSummaryChip(l10n.ndef, l10n.available, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF133633),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDataEntry(String key, dynamic value) {
    if (value == null || key == 'probes_log') return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _getIconForKey(key),
          ),
          title: Text(
            _formatKey(key),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildValueContent(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueContent(dynamic value) {
    final theme = Theme.of(context);
    if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(child: Text('${e.value}')),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }
    return SelectableText(
      '$value',
      style: const TextStyle(fontFamily: 'monospace'),
    );
  }

  Icon _getIconForKey(String key) {
    if (key.contains('parsed')) {
      return const Icon(Icons.analytics, color: Colors.green);
    }
    if (key.contains('error')) {
      return const Icon(Icons.warning, color: Colors.orange);
    }
    if (key.contains('ndef')) {
      return const Icon(Icons.description, color: Colors.blue);
    }
    return const Icon(Icons.data_array, color: Colors.grey);
  }

  String _formatKey(String key) {
    return key.replaceAll('_', ' ').toUpperCase();
  }

  Future<void> _toggleAdvanced(bool v) async {
    final l10n = AppLocalizations.of(context)!;
    if (v == true) {
      final ok = await showPlatformConfirm(
        context,
        title: l10n.securityWarning,
        message: l10n.securityWarningDesc,
        confirmLabel: l10n.confirm,
        cancelLabel: l10n.cancel,
      );
      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('allow_advanced_probes', true);
        setState(() => _allowAdvanced = true);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('allow_advanced_probes', false);
      setState(() => _allowAdvanced = false);
    }
  }
}
