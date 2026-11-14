import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/nfc_provider.dart';
import '../widgets/platform_adaptive.dart';
import '../widgets/platform_dialogs.dart';
import '../../models/nfc_record.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _mimeController = TextEditingController();
  NfcRecordType _selectedType = NfcRecordType.text;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClonedRecord();
    });
  }

  void _checkClonedRecord() {
    final provider = context.read<NfcProvider>();
    final cloned = provider.clonedRecord;
    if (cloned != null) {
      setState(() {
        _selectedType = cloned.type;
        _contentController.text = cloned.content;
        if (cloned.mimeType != null) {
          _mimeController.text = cloned.mimeType!;
        }
      });
      provider.setClonedRecord(null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tag data loaded into write editor'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _mimeController.dispose();
    super.dispose();
  }

  void _applyPreset(NfcRecordType type, String content, String? mime) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedType = type;
      _contentController.text = content;
      if (mime != null) {
        _mimeController.text = mime;
      }
    });
  }

  void _handleWrite() {
    if (_formKey.currentState!.validate()) {
      final record = NfcRecord(
        type: _selectedType,
        content: _contentController.text,
        mimeType: _selectedType == NfcRecordType.mime
            ? _mimeController.text
            : null,
      );
      context.read<NfcProvider>().writeTag(record);
      _showWriteDialog();
    }
  }

  Future<void> _handleEraseTag() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showPlatformConfirm(
      context,
      title: l10n.eraseTag,
      message: l10n.eraseTagConfirm,
      confirmLabel: l10n.clear,
      cancelLabel: l10n.cancel,
      destructive: true,
    );

    if (confirmed && mounted) {
      context.read<NfcProvider>().eraseTag();
      _showWriteDialog();
    }
  }

  Future<void> _handleLockTag() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showPlatformConfirm(
      context,
      title: l10n.lockTag,
      message: l10n.lockTagConfirm,
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
    );

    if (confirmed && mounted) {
      context.read<NfcProvider>().lockTag();
      _showWriteDialog();
    }
  }

  Future<void> _openWifiWizard() async {
    final ssidCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String secType = 'WPA';
    final l10n = AppLocalizations.of(context)!;

    final submitted = await showPlatformFormSheet(
      context,
      title: 'Wi-Fi Wizard',
      submitLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidCtrl,
              decoration: InputDecoration(
                labelText: 'Network Name (SSID)',
                prefixIcon: const Icon(Icons.wifi),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: secType != 'nopass',
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: secType,
              decoration: InputDecoration(
                labelText: 'Security',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'WPA',
                  child: Text('WPA / WPA2 / WPA3'),
                ),
                DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                DropdownMenuItem(
                  value: 'nopass',
                  child: Text('None (Open Network)'),
                ),
              ],
              onChanged: (v) => setDialogState(() => secType = v ?? 'WPA'),
            ),
          ],
        ),
      ),
    );

    if (submitted) {
      final ssid = ssidCtrl.text.trim();
      final pass = passCtrl.text.trim();
      if (ssid.isNotEmpty) {
        final wifiString = 'WIFI:T:$secType;S:$ssid;P:$pass;;';
        _applyPreset(NfcRecordType.text, wifiString, null);
      }
    }

    ssidCtrl.dispose();
    passCtrl.dispose();
  }

  Future<void> _openVCardWizard() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final submitted = await showPlatformFormSheet(
      context,
      title: 'vCard Business Card',
      submitLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: orgCtrl,
            decoration: InputDecoration(
              labelText: 'Company / Org',
              prefixIcon: const Icon(Icons.business_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (submitted) {
      final name = nameCtrl.text.trim();
      final phone = phoneCtrl.text.trim();
      final email = emailCtrl.text.trim();
      final org = orgCtrl.text.trim();
      if (name.isNotEmpty) {
        final vCard =
            'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nORG:$org\nTEL:$phone\nEMAIL:$email\nEND:VCARD';
        _applyPreset(NfcRecordType.mime, vCard, 'text/vcard');
      }
    }

    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    orgCtrl.dispose();
  }

  void _showWriteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<NfcProvider>(
          builder: (context, nfcProvider, child) {
            final l10n = AppLocalizations.of(context)!;
            final title = nfcProvider.status == NfcStatus.success
                ? l10n.success
                : nfcProvider.status == NfcStatus.error
                ? l10n.error
                : l10n.writing;

            final content = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (nfcProvider.status == NfcStatus.writing) ...[
                  Lottie.asset(
                    'assets/lottie/onboarding_nfc.json',
                    height: 140,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nfcProvider.message.isNotEmpty
                        ? nfcProvider.message
                        : l10n.bringCardClose,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ] else if (nfcProvider.status == NfcStatus.success) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nfcProvider.message.isNotEmpty
                        ? nfcProvider.message
                        : l10n.dataWrittenSuccess,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else if (nfcProvider.status == NfcStatus.error) ...[
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nfcProvider.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            );

            final isWriting = nfcProvider.status == NfcStatus.writing;
            final actionLabel = isWriting ? l10n.cancel : l10n.close;

            void close() {
              if (isWriting) {
                nfcProvider.stopScan();
              } else {
                nfcProvider.resetStatus();
              }
              Navigator.pop(context);
            }

            if (AppPlatform.isIOS) {
              return CupertinoAlertDialog(
                title: Text(title),
                content: content,
                actions: [
                  CupertinoDialogAction(
                    onPressed: close,
                    child: Text(actionLabel),
                  ),
                ],
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(title, textAlign: TextAlign.center),
              content: content,
              actions: [TextButton(onPressed: close, child: Text(actionLabel))],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for cloned record if navigated from History or Read
    final cloned = context.watch<NfcProvider>().clonedRecord;
    if (cloned != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkClonedRecord());
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: 40.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.selectRecordType,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (AppPlatform.isIOS)
                  CupertinoSlidingSegmentedControl<NfcRecordType>(
                    groupValue: _selectedType,
                    thumbColor: theme.colorScheme.surface,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.10,
                    ),
                    onValueChanged: (value) {
                      if (value == null) return;
                      HapticFeedback.selectionClick();
                      setState(() => _selectedType = value);
                    },
                    children: {
                      NfcRecordType.text: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(l10n.text),
                      ),
                      NfcRecordType.uri: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(l10n.uri),
                      ),
                      NfcRecordType.mime: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(l10n.mime),
                      ),
                    },
                  )
                else
                  SegmentedButton<NfcRecordType>(
                    segments: [
                      ButtonSegment(
                        value: NfcRecordType.text,
                        label: Text(l10n.text),
                        icon: const Icon(Icons.text_fields, size: 18),
                      ),
                      ButtonSegment(
                        value: NfcRecordType.uri,
                        label: Text(l10n.uri),
                        icon: const Icon(Icons.link, size: 18),
                      ),
                      ButtonSegment(
                        value: NfcRecordType.mime,
                        label: Text(l10n.mime),
                        icon: const Icon(Icons.data_object, size: 18),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (Set<NfcRecordType> newSelection) {
                      setState(() {
                        _selectedType = newSelection.first;
                      });
                    },
                  ),
                const SizedBox(height: 20),

                // Accordion Templates Section
                Row(
                  children: [
                    Icon(
                      Icons.widgets_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.templates,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTemplatesAccordion(context, isDark, l10n),

                const SizedBox(height: 24),
                TextFormField(
                  controller: _contentController,
                  maxLines: _selectedType == NfcRecordType.mime ? 4 : 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: _selectedType == NfcRecordType.uri
                        ? l10n.urlExample
                        : l10n.content,
                    hintText: _selectedType == NfcRecordType.uri
                        ? 'https://'
                        : l10n.enterContent,
                    prefixIcon: Icon(
                      _selectedType == NfcRecordType.uri
                          ? Icons.link
                          : Icons.edit_note,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterContent;
                    }
                    final isUriLike =
                        _selectedType == NfcRecordType.uri ||
                        _selectedType == NfcRecordType.smartPoster;
                    if (isUriLike &&
                        !value.startsWith('http') &&
                        !value.startsWith('tel:') &&
                        !value.startsWith('mailto:') &&
                        !value.startsWith('sms:') &&
                        !value.startsWith('geo:')) {
                      return l10n.urlError;
                    }
                    return null;
                  },
                ),
                if (_selectedType == NfcRecordType.external ||
                    _selectedType == NfcRecordType.smartPoster) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.type}: ${_selectedType == NfcRecordType.external ? l10n.external : l10n.smartPoster}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_selectedType == NfcRecordType.mime) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mimeController,
                    decoration: InputDecoration(
                      labelText: l10n.mimeType,
                      hintText: 'text/plain',
                      prefixIcon: const Icon(Icons.type_specimen),
                    ),
                    validator: (value) {
                      if (_selectedType == NfcRecordType.mime &&
                          (value == null || value.trim().isEmpty)) {
                        return l10n.enterMimeType;
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),

                // Primary Write Action Button
                FilledButton.icon(
                  onPressed: _handleWrite,
                  icon: const Icon(Icons.nfc, size: 22),
                  label: Text(
                    l10n.writeToTag,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // NFC Tools Row: Erase Tag & Lock Tag
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleEraseTag,
                        icon: const Icon(
                          Icons.cleaning_services_outlined,
                          size: 18,
                        ),
                        label: Text(
                          l10n.eraseTag,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          foregroundColor: Colors.red.shade400,
                          side: BorderSide(
                            color: Colors.red.shade300.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleLockTag,
                        icon: const Icon(Icons.lock_outline, size: 18),
                        label: Text(
                          l10n.lockTag,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          foregroundColor: Colors.orange.shade700,
                          side: BorderSide(
                            color: Colors.orange.shade300.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Pastel Aesthetic Warning Notice
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2216)
                        : const Color(0xFFFEF7EC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF4A381F)
                          : const Color(0xFFFDE5C5),
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: isDark
                            ? const Color(0xFFFFB74D)
                            : const Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.writeWarning,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFFFE0B2)
                                : const Color(0xFF78350F),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatesAccordion(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 1. Web & Social Media
          _AccordionSection(
            icon: Icons.public,
            iconColor: const Color(0xFF1E88E5),
            title: l10n.categoryWebSocial,
            count: 8,
            children: [
              _AccordionChip(
                icon: Icons.language,
                label: 'Website',
                onTap: () => _applyPreset(NfcRecordType.uri, 'https://', null),
              ),
              _AccordionChip(
                icon: Icons.play_circle_outline,
                label: 'YouTube',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  'https://youtube.com/@',
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  'https://instagram.com/',
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.tag,
                label: 'X (Twitter)',
                onTap: () =>
                    _applyPreset(NfcRecordType.uri, 'https://x.com/', null),
              ),
              _AccordionChip(
                icon: Icons.work_outline,
                label: 'LinkedIn',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  'https://linkedin.com/in/',
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.music_note,
                label: 'TikTok',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  'https://tiktok.com/@',
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.chat_bubble_outline,
                label: 'WhatsApp',
                onTap: () =>
                    _applyPreset(NfcRecordType.uri, 'https://wa.me/', null),
              ),
              _AccordionChip(
                icon: Icons.send_outlined,
                label: 'Telegram',
                onTap: () =>
                    _applyPreset(NfcRecordType.uri, 'https://t.me/', null),
              ),
            ],
          ),
          const Divider(height: 1, indent: 56),

          // 2. Network & Connectivity
          _AccordionSection(
            icon: Icons.wifi,
            iconColor: const Color(0xFF00897B),
            title: l10n.categoryConnectivity,
            count: 4,
            children: [
              ActionChip(
                avatar: const Icon(
                  Icons.auto_fix_high,
                  size: 16,
                  color: Colors.teal,
                ),
                label: const Text(
                  'Wi-Fi Wizard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: _openWifiWizard,
                backgroundColor: Colors.teal.withValues(alpha: 0.12),
              ),
              _AccordionChip(
                icon: Icons.wifi_lock,
                label: 'Wi-Fi (WPA2)',
                onTap: () => _applyPreset(
                  NfcRecordType.text,
                  l10n.templateWifiPreset,
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.wifi,
                label: 'Wi-Fi (Open)',
                onTap: () => _applyPreset(
                  NfcRecordType.text,
                  'WIFI:T:nopass;S:PublicWiFi;;',
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.bluetooth,
                label: 'Bluetooth MAC',
                onTap: () => _applyPreset(
                  NfcRecordType.mime,
                  '00:11:22:33:44:55',
                  'application/vnd.bluetooth.ep.oob',
                ),
              ),
            ],
          ),
          const Divider(height: 1, indent: 56),

          // 3. Communication & Contacts
          _AccordionSection(
            icon: Icons.contact_phone_outlined,
            iconColor: const Color(0xFF8B5CF6),
            title: l10n.categoryCommunication,
            count: 5,
            children: [
              ActionChip(
                avatar: const Icon(
                  Icons.badge,
                  size: 16,
                  color: Colors.deepPurple,
                ),
                label: const Text(
                  'vCard Wizard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: _openVCardWizard,
                backgroundColor: Colors.deepPurple.withValues(alpha: 0.12),
              ),
              _AccordionChip(
                icon: Icons.phone_outlined,
                label: 'Telephone',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  l10n.templateTelPreset,
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.sms_outlined,
                label: 'SMS Message',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  l10n.templateSmsPreset,
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.email_outlined,
                label: l10n.templateEmail,
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  l10n.templateEmailPreset,
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.emergency,
                label: 'SOS Emergency',
                onTap: () => _applyPreset(NfcRecordType.uri, 'tel:112', null),
              ),
            ],
          ),
          const Divider(height: 1, indent: 56),

          // 4. Location & Navigation
          _AccordionSection(
            icon: Icons.map_outlined,
            iconColor: const Color(0xFFE65100),
            title: l10n.categoryLocation,
            count: 3,
            children: [
              _AccordionChip(
                icon: Icons.location_on_outlined,
                label: 'GPS Geo URI',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  l10n.templateLocationPreset,
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.map,
                label: 'Google Maps',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  'https://maps.google.com/?q=41.0082,28.9784',
                  null,
                ),
              ),
              _AccordionChip(
                icon: Icons.explore_outlined,
                label: 'Apple Maps',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  'https://maps.apple.com/?ll=41.0082,28.9784',
                  null,
                ),
              ),
            ],
          ),
          const Divider(height: 1, indent: 56),

          // 5. Data & Developer
          _AccordionSection(
            icon: Icons.code,
            iconColor: const Color(0xFF546E7A),
            title: l10n.categoryDataDev,
            count: 5,
            children: [
              _AccordionChip(
                icon: Icons.data_object,
                label: 'JSON Payload',
                onTap: () => _applyPreset(
                  NfcRecordType.mime,
                  '{"app":"nfc-manager","version":"1.4"}',
                  'application/json',
                ),
              ),
              _AccordionChip(
                icon: Icons.notes,
                label: 'Plain Note',
                onTap: () =>
                    _applyPreset(NfcRecordType.text, 'NFC Manager Note', null),
              ),
              _AccordionChip(
                icon: Icons.dns_outlined,
                label: 'Smart Poster',
                onTap: () => _applyPreset(
                  NfcRecordType.smartPoster,
                  'https://41software.com',
                  null,
                ),
              ),
              if (AppPlatform.isIOS)
                _AccordionChip(
                  icon: Icons.phone_iphone,
                  label: 'App Store Link',
                  onTap: () => _applyPreset(
                    NfcRecordType.uri,
                    AppPlatform.appStoreUrl,
                    null,
                  ),
                )
              else
                _AccordionChip(
                  icon: Icons.android,
                  label: 'App Launch (AAR)',
                  onTap: () => _applyPreset(
                    NfcRecordType.external,
                    'com.software41.nfcmanager',
                    'android.com:pkg',
                  ),
                ),
              _AccordionChip(
                icon: Icons.link_outlined,
                label: 'Custom Scheme',
                onTap: () => _applyPreset(
                  NfcRecordType.uri,
                  'myapp://open?source=nfc',
                  null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccordionSection extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;
  final List<Widget> children;

  const _AccordionSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.children,
  });

  @override
  State<_AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<_AccordionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        onExpansionChanged: (value) {
          setState(() {
            _expanded = value;
          });
        },
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: widget.iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon, color: widget.iconColor, size: 18),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        // Kaç şablon olduğunu gösteren rozet + yeni liste açılacağını
        // belli eden ">" işareti.
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: widget.iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.count}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.iconColor,
                ),
              ),
              const SizedBox(width: 3),
              AnimatedRotation(
                turns: _expanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(
                  Icons.chevron_right,
                  size: 15,
                  color: widget.iconColor,
                ),
              ),
            ],
          ),
        ),
        children: [Wrap(spacing: 8, runSpacing: 8, children: widget.children)],
      ),
    );
  }
}

class _AccordionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AccordionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
