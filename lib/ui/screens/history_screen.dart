import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';
import '../../models/nfc_record.dart';
import '../../providers/nfc_provider.dart';
import '../widgets/app_banner_ad.dart';
import '../widgets/platform_adaptive.dart';
import '../widgets/record_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _favoritesOnly = false;

  /// Her N kartın arasına bir banner reklamı yerleştirilir.
  static const int _cardsPerBlock = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _itemCount(int cardCount) => cardCount + cardCount ~/ _cardsPerBlock;

  Widget _buildItem(
    int index,
    List<NfcRecord> filteredHistory,
    NfcProvider nfcProvider,
  ) {
    final blockSize = _cardsPerBlock + 1;
    final block = index ~/ blockSize;
    final posInBlock = index % blockSize;

    // Blok sonunda bir reklam bandı.
    if (posInBlock == _cardsPerBlock) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: AppBannerAd(height: 56),
      );
    }

    final record = filteredHistory[block * _cardsPerBlock + posInBlock];
    final card = RecordCard(
      record: record,
      pastelBackground: true,
      onDelete: () => nfcProvider.deleteRecord(record.id),
      onToggleFavorite: () => nfcProvider.toggleFavorite(record.id),
      onClone: () => nfcProvider.setClonedRecord(record),
    );

    if (!AppPlatform.isIOS) {
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: card);
    }

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CupertinoContextMenu(
        actions: <Widget>[
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.share,
            onPressed: () {
              Navigator.pop(context);
              SharePlus.instance.share(
                ShareParams(
                  text: '${record.content}\n\n${record.metadata ?? {}}',
                  subject: l10n.nfcRecord,
                  sharePositionOrigin: AppPlatform.shareOrigin(context),
                ),
              );
            },
            child: Text(l10n.share),
          ),
          CupertinoContextMenuAction(
            trailingIcon: CupertinoIcons.doc_on_clipboard,
            onPressed: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: record.content));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.copy),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(l10n.copy),
          ),
          CupertinoContextMenuAction(
            trailingIcon: record.isFavorite
                ? CupertinoIcons.star_fill
                : CupertinoIcons.star,
            onPressed: () {
              Navigator.pop(context);
              nfcProvider.toggleFavorite(record.id);
            },
            child: Text(l10n.favorites),
          ),
        ],
        child: card,
      ),
    );
  }

  Future<void> _showExportOptions(
    BuildContext context,
    AppLocalizations l10n,
    NfcProvider nfcProvider,
  ) async {
    final choice = await showPlatformChoiceSheet(
      context,
      title: l10n.exportHistory,
      cancelLabel: l10n.cancel,
      options: {l10n.exportHistory: 'json', l10n.exportCsv: 'csv'},
    );
    if (choice == null || !context.mounted) return;
    await _export(context, l10n, nfcProvider, choice);
  }

  Future<void> _export(
    BuildContext context,
    AppLocalizations l10n,
    NfcProvider nfcProvider,
    String value,
  ) async {
    try {
      final origin = AppPlatform.shareOrigin(context);
      if (value == 'csv') {
        await nfcProvider.exportHistoryCsv(sharePositionOrigin: origin);
      } else {
        await nfcProvider.exportHistory(sharePositionOrigin: origin);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportError)));
    }
  }

  Widget _buildSearchField(BuildContext context, AppLocalizations l10n) {
    if (AppPlatform.isIOS) {
      return CupertinoSearchTextField(
        controller: _searchController,
        placeholder: l10n.searchHistory,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onSuffixTap: () {
          setState(() {
            _searchController.clear();
            _searchQuery = '';
          });
        },
      );
    }

    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: l10n.searchHistory,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nfcProvider = context.watch<NfcProvider>();
    final l10n = AppLocalizations.of(context)!;

    final filteredHistory = nfcProvider.history.where((record) {
      if (_favoritesOnly && !record.isFavorite) return false;
      final query = _searchQuery.toLowerCase();
      return record.content.toLowerCase().contains(query) ||
          (record.mimeType?.toLowerCase().contains(query) ?? false) ||
          record.type.toString().toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: nfcProvider.history.isEmpty
          ? null
          : AppBar(
              toolbarHeight: 80,
              title: _buildSearchField(context, l10n),
              actions: [
                if (_searchQuery.isEmpty)
                  AppPlatform.isIOS
                      ? IconButton(
                          icon: const Icon(Icons.ios_share),
                          tooltip: l10n.exportHistory,
                          onPressed: () =>
                              _showExportOptions(context, l10n, nfcProvider),
                        )
                      : PopupMenuButton<String>(
                          icon: const Icon(Icons.ios_share),
                          tooltip: l10n.exportHistory,
                          onSelected: (value) =>
                              _export(context, l10n, nfcProvider, value),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'json',
                              child: Text(l10n.exportHistory),
                            ),
                            PopupMenuItem(
                              value: 'csv',
                              child: Text(l10n.exportCsv),
                            ),
                          ],
                        ),
                const SizedBox(width: 8),
              ],
            ),
      body: nfcProvider.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/onboarding_nfc.json',
                    height: 180,
                    repeat: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.noHistory,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noHistoryDesc,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : filteredHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noResults,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      _StatPill(
                        icon: Icons.history,
                        label: '${nfcProvider.totalScans} ${l10n.total}',
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        icon: Icons.today,
                        label: '${nfcProvider.todayScans} ${l10n.today}',
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        icon: Icons.star_rounded,
                        label: '${nfcProvider.favorites.length} ★',
                      ),
                      const Spacer(),
                      FilterChip(
                        label: Text(l10n.favorites),
                        selected: _favoritesOnly,
                        avatar: const Icon(
                          Icons.star_outline_rounded,
                          size: 16,
                        ),
                        onSelected: (v) => setState(() => _favoritesOnly = v),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      MediaQuery.viewPaddingOf(context).bottom + 80,
                    ),
                    itemCount: _itemCount(filteredHistory.length),
                    itemBuilder: (context, index) =>
                        _buildItem(index, filteredHistory, nfcProvider),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
