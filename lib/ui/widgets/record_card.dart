import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';
import '../../models/nfc_record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class _PastelPalette {
  final Color bg;
  final Color fg;
  final Color border;

  const _PastelPalette({
    required this.bg,
    required this.fg,
    required this.border,
  });
}

class RecordCard extends StatelessWidget {
  final NfcRecord record;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onClone;

  /// Kart arka planı kayıt tipine göre pastel renklerle boyansın mı?
  /// (Geçmiş ekranındaki kartlarda kullanılır.)
  final bool pastelBackground;

  const RecordCard({
    super.key,
    required this.record,
    this.onDelete,
    this.onToggleFavorite,
    this.onClone,
    this.pastelBackground = false,
  });

  dynamic _getIconForType(NfcRecordType type) {
    switch (type) {
      case NfcRecordType.text:
        return FontAwesomeIcons.fileLines;
      case NfcRecordType.uri:
        return FontAwesomeIcons.link;
      case NfcRecordType.mime:
        return FontAwesomeIcons.file;
      case NfcRecordType.external:
        return FontAwesomeIcons.fileCode;
      case NfcRecordType.smartPoster:
        return FontAwesomeIcons.image;
      case NfcRecordType.unknown:
        return FontAwesomeIcons.question;
    }
  }

  _PastelPalette _getPastel(NfcRecordType type, bool isDark) {
    switch (type) {
      case NfcRecordType.text:
        return _PastelPalette(
          bg: isDark ? const Color(0xFF192A38) : const Color(0xFFEBF3FC),
          fg: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1E88E5),
          border: isDark ? const Color(0xFF294459) : const Color(0xFFBBDEFB),
        );
      case NfcRecordType.uri:
        return _PastelPalette(
          bg: isDark ? const Color(0xFF162D21) : const Color(0xFFE8F6ED),
          fg: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
          border: isDark ? const Color(0xFF264C37) : const Color(0xFFC8E6C9),
        );
      case NfcRecordType.mime:
        return _PastelPalette(
          bg: isDark ? const Color(0xFF332415) : const Color(0xFFFEF3E4),
          fg: isDark ? const Color(0xFFFFCC80) : const Color(0xFFE65100),
          border: isDark ? const Color(0xFF553D23) : const Color(0xFFFFE0B2),
        );
      case NfcRecordType.external:
        return _PastelPalette(
          bg: isDark ? const Color(0xFF261D36) : const Color(0xFFF3EAFE),
          fg: isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2),
          border: isDark ? const Color(0xFF453460) : const Color(0xFFE1BEE7),
        );
      case NfcRecordType.smartPoster:
        return _PastelPalette(
          bg: isDark ? const Color(0xFF132B29) : const Color(0xFFE2F6F4),
          fg: isDark ? const Color(0xFF80CBC4) : const Color(0xFF00796B),
          border: isDark ? const Color(0xFF224B47) : const Color(0xFFB2DFDB),
        );
      case NfcRecordType.unknown:
        return _PastelPalette(
          bg: isDark ? const Color(0xFF202528) : const Color(0xFFF1F3F5),
          fg: isDark ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A),
          border: isDark ? const Color(0xFF353D42) : const Color(0xFFCFD8DC),
        );
    }
  }

  String _formatType(NfcRecordType type, AppLocalizations l10n) {
    switch (type) {
      case NfcRecordType.text:
        return l10n.text;
      case NfcRecordType.uri:
        return l10n.uri;
      case NfcRecordType.mime:
        return l10n.mime;
      case NfcRecordType.external:
        return l10n.external;
      case NfcRecordType.smartPoster:
        return l10n.smartPoster;
      case NfcRecordType.unknown:
        return l10n.unknown;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Cihazda özel bir uygulama ile açılamazsa platform varsayılanına düş.
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  String? _findUid() {
    if (record.metadata == null) return null;
    final meta = record.metadata!;
    return (meta['uid'] ?? meta['tag_uid'])?.toString();
  }

  String get _shareText => '${record.content}\n\n${record.metadata ?? {}}';

  void _handleAction(
    BuildContext context,
    AppLocalizations l10n,
    String value,
  ) {
    if (value == 'share') {
      SharePlus.instance.share(
        ShareParams(
          text: _shareText,
          subject: l10n.nfcRecord,
          sharePositionOrigin: AppPlatform.shareOrigin(context),
        ),
      );
    } else if (value == 'export') {
      Clipboard.setData(ClipboardData(text: _shareText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.exportedToClipboard),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// iOS action sheet for the card menu (UIKit style instead of a popup menu).
  Future<void> _showActions(BuildContext context, AppLocalizations l10n) async {
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext, 'share'),
            child: Text(l10n.share),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext, 'export'),
            child: Text(l10n.export),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: Text(l10n.cancel),
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    _handleAction(context, l10n, action);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final pastel = _getPastel(record.type, isDark);
    final uid = _findUid();

    // Pastel zeminli kartlarda rozetlerin okunabilir kalması için arka plan.
    final badgeBg = pastelBackground
        ? (isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.72))
        : pastel.bg;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: pastel.border.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.2,
        ),
      ),
      color: pastelBackground ? pastel.bg : theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (record.type == NfcRecordType.uri) {
            _launchUrl(record.content);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: pastel.border.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(
                      _getIconForType(record.type),
                      color: pastel.fg,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _formatType(record.type, l10n),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: pastel.fg,
                                ),
                              ),
                            ),
                            if (record.mimeType != null) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    record.mimeType!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • HH:mm',
                          ).format(record.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onToggleFavorite != null)
                    IconButton(
                      icon: Icon(
                        record.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 22,
                      ),
                      onPressed: onToggleFavorite,
                      color: Colors.amber.shade600,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      color: Colors.red.shade400,
                      visualDensity: VisualDensity.compact,
                    ),
                  AppPlatform.isIOS
                      ? IconButton(
                          icon: const Icon(Icons.more_horiz, size: 20),
                          onPressed: () => _showActions(context, l10n),
                          visualDensity: VisualDensity.compact,
                        )
                      : PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) =>
                              _handleAction(context, l10n, value),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'share',
                              child: Text(l10n.share),
                            ),
                            PopupMenuItem(
                              value: 'export',
                              child: Text(l10n.export),
                            ),
                          ],
                        ),
                ],
              ),
              if (uid != null && uid.isNotEmpty) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _copyToClipboard(context, uid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: pastel.border.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.nfc, size: 14, color: pastel.fg),
                        const SizedBox(width: 6),
                        Text(
                          'UID: $uid',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: pastel.fg,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.copy,
                          size: 12,
                          color: pastel.fg.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pastelBackground
                      ? (isDark
                            ? Colors.black.withValues(alpha: 0.28)
                            : Colors.white.withValues(alpha: 0.72))
                      : (isDark
                            ? const Color(0xFF14191B)
                            : const Color(0xFFF3F6F5)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      record.content,
                      maxLines: 6,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    if (record.metadata != null &&
                        record.metadata!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          dense: true,
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.details,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: pastel.fg,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: record.metadata!.entries
                                    .map(
                                      (e) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          '${e.key}: ${e.value}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontFamily: 'monospace',
                                                fontSize: 11,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onClone != null)
                    TextButton.icon(
                      onPressed: onClone,
                      icon: const Icon(Icons.copy_all, size: 16),
                      label: Text(
                        l10n.cloneTag,
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  if (record.type == NfcRecordType.uri)
                    TextButton.icon(
                      onPressed: () => _launchUrl(record.content),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(
                        l10n.open,
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(context, record.content),
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(
                      l10n.copy,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
