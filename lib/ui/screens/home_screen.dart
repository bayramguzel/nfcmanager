import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/nfc_provider.dart';
import '../../services/ad_service.dart';
import '../../services/quick_actions_service.dart';
import '../../services/review_service.dart';
import 'read_screen.dart';
import 'write_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'advanced_read_screen.dart';
import '../widgets/bottom_banner_widget.dart';
import '../widgets/platform_dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ReadScreen(),
    const WriteScreen(),
    const AdvancedReadScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowReviewDialog();
      _initQuickActions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        AppPlatform.isIOS &&
        (context.read<NfcProvider>().status == NfcStatus.scanning ||
            context.read<NfcProvider>().status == NfcStatus.writing)) {
      // CoreNFC invalidates the reader session when iOS backgrounds the app.
      context.read<NfcProvider>().stopScan();
    }
    if (state == AppLifecycleState.resumed) {
      context.read<NfcProvider>().checkNfcStatus();
      AdService.instance.loadAdFreeStatus();
    }
  }

  Future<void> _showClearHistoryDialog(
    BuildContext context,
    NfcProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showPlatformConfirm(
      context,
      title: l10n.clearHistory,
      message: l10n.clearHistoryConfirm,
      confirmLabel: l10n.clear,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed) provider.clearHistory();
  }

  Future<void> _maybeShowReviewDialog() async {
    if (!mounted || !ReviewService.instance.shouldShow) return;

    // App Review expects the system rating sheet on iOS; a custom in-app
    // prompt with a store link is not the supported flow there.
    if (AppPlatform.isIOS) {
      await ReviewService.instance.requestIosInAppReview();
      await ReviewService.instance.remindLater();
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.amber.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.reviewTitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                dialogContext,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.reviewMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'later'),
            child: Text(l10n.reviewLater),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.star_rounded, size: 20),
            label: Text(l10n.reviewRateNow),
            onPressed: () => Navigator.pop(dialogContext, 'rate'),
          ),
        ],
      ),
    );

    if (result == 'rate') {
      await ReviewService.instance.markRated();
      await ReviewService.instance.openStoreListing();
    } else {
      // Kullanıcı istemi kapatmış veya "Daha Sonra" seçmiş.
      await ReviewService.instance.remindLater();
    }
  }

  void _showAdFreeModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return ListenableBuilder(
          listenable: AdService.instance,
          builder: (context, _) {
            final isAdFree = AdService.instance.isAdFree;
            final remainingText = AdService.instance.formattedRemainingTime;

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade300, Colors.amber.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.adFreeTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (isAdFree) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n.adFreeActive} • $remainingText',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.adFreeActiveDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ] else ...[
                    Text(
                      l10n.adFreeDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.play_circle_fill, size: 24),
                      label: Text(
                        l10n.watchAdEarn24h,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        AdService.instance.showRewardedAd(
                          onReward: () {
                            AdService.instance.addAdFreeHours(24);
                            if (Navigator.canPop(modalContext)) {
                              Navigator.pop(modalContext);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 10),
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
                                duration: const Duration(seconds: 4),
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
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  /// iOS Home Screen quick actions (long-press the app icon).
  Future<void> _initQuickActions() async {
    if (!AppPlatform.isIOS || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await QuickActionsService.instance.initialize((tab) {
      if (!mounted) return;
      setState(() {
        _selectedIndex = tab;
      });
    });
    await QuickActionsService.instance.setItems(
      readLabel: l10n.read,
      writeLabel: l10n.write,
      historyLabel: l10n.history,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nfcProvider = context.watch<NfcProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (nfcProvider.clonedRecord != null && _selectedIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedIndex != 1) {
          setState(() {
            _selectedIndex = 1;
          });
        }
      });
    }

    List<Widget> actions = [];

    // Golden Star icon for 24h Ad-Free / Support
    actions.add(
      ListenableBuilder(
        listenable: AdService.instance,
        builder: (context, _) {
          final isAdFree = AdService.instance.isAdFree;
          return IconButton(
            icon: Icon(
              isAdFree ? Icons.stars_rounded : Icons.star_rounded,
              color: Colors.amber.shade600,
              size: 24,
            ),
            tooltip: isAdFree
                ? '${l10n.adFreeActive} (${AdService.instance.formattedRemainingTime})'
                : l10n.adFreeTooltip,
            onPressed: () => _showAdFreeModal(context),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 36),
            splashRadius: 18,
          );
        },
      ),
    );

    if (_selectedIndex == 3 && nfcProvider.history.isNotEmpty) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.delete_sweep, size: 22),
          tooltip: l10n.clearHistory,
          onPressed: () => _showClearHistoryDialog(context, nfcProvider),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 34, minHeight: 36),
          splashRadius: 18,
        ),
      );
    }

    actions.add(
      IconButton(
        icon: Icon(
          nfcProvider.isNfcAvailable ? Icons.nfc : Icons.nfc_outlined,
          color: nfcProvider.isNfcAvailable ? Colors.green : Colors.red,
          size: 22,
        ),
        tooltip: nfcProvider.isNfcAvailable ? l10n.nfcActive : l10n.nfcOff,
        onPressed: () {
          if (!nfcProvider.isNfcAvailable) {
            nfcProvider.openSettings();
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.nfcActive)));
          }
        },
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 36),
        splashRadius: 18,
      ),
    );
    actions.add(
      IconButton(
        icon: const Icon(Icons.share, size: 20),
        tooltip: l10n.shareApp,
        onPressed: () {
          SharePlus.instance.share(
            ShareParams(
              text: AppPlatform.shareTextFor(l10n.shareAppText),
              sharePositionOrigin: AppPlatform.shareOrigin(context),
            ),
          );
        },
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 36),
        splashRadius: 18,
      ),
    );
    actions.add(const SizedBox(width: 4));

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 12.0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset(
                'assets/logo.png',
                width: 26,
                height: 26,
                errorBuilder: (_, __, ___) => const Icon(Icons.nfc, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'NFC Manager',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: actions,
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.04),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: IndexedStack(
          key: ValueKey(_selectedIndex),
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BottomBannerWidget(),
          _buildBottomNavigation(context, l10n, _selectedIndex, _selectTab),
        ],
      ),
    );
  }
}

/// Bottom navigation that follows the host platform: the native iOS tab bar on
/// iPhone/iPad, Material's navigation bar on Android.
Widget _buildBottomNavigation(
  BuildContext context,
  AppLocalizations l10n,
  int selectedIndex,
  ValueChanged<int> onSelected,
) {
  final items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: const Icon(Icons.nfc_outlined),
      activeIcon: const Icon(Icons.nfc),
      label: l10n.read,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.edit_note_outlined),
      activeIcon: const Icon(Icons.edit_note),
      label: l10n.write,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.psychology_outlined),
      activeIcon: const Icon(Icons.psychology),
      label: l10n.expert,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.history_outlined),
      activeIcon: const Icon(Icons.history),
      label: l10n.history,
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.settings_outlined),
      activeIcon: const Icon(Icons.settings),
      label: l10n.settingsTab,
    ),
  ];

  if (AppPlatform.isIOS) {
    final surface = Theme.of(context).colorScheme.surface;
    return ColoredBox(
      color: surface,
      child: SafeArea(
        top: false,
        child: CupertinoTabBar(
          items: items,
          currentIndex: selectedIndex,
          onTap: onSelected,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Colors.grey,
          backgroundColor: surface.withValues(alpha: 0.94),
          iconSize: 26,
          height: 50,
        ),
      ),
    );
  }

  return NavigationBar(
    height: 68,
    backgroundColor: Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: 0.95),
    indicatorColor: Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.12),
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    destinations: [
      NavigationDestination(
        icon: const Icon(Icons.nfc_outlined),
        selectedIcon: const Icon(Icons.nfc),
        label: l10n.read,
      ),
      NavigationDestination(
        icon: const Icon(Icons.edit_note_outlined),
        selectedIcon: const Icon(Icons.edit_note),
        label: l10n.write,
      ),
      NavigationDestination(
        icon: const Icon(Icons.psychology_outlined),
        selectedIcon: const Icon(Icons.psychology),
        label: l10n.expert,
      ),
      NavigationDestination(
        icon: const Icon(Icons.history_outlined),
        selectedIcon: const Icon(Icons.history),
        label: l10n.history,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.settingsTab,
      ),
    ],
  );
}
