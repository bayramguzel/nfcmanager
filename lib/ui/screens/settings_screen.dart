import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/nfc_provider.dart';
import '../../services/ad_service.dart';
import '../../services/review_service.dart';
import '../widgets/platform_adaptive.dart';
import 'manual_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showThemeDialog(
    BuildContext context,
    NfcProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showPlatformChoiceSheet(
      context,
      title: '${l10n.lightTheme} / ${l10n.darkTheme}',
      selectedValue: provider.themeMode.name,
      cancelLabel: l10n.cancel,
      options: {
        'System': 'system',
        l10n.lightTheme: 'light',
        l10n.darkTheme: 'dark',
      },
    );
    if (choice == null) return;
    await provider.setThemeMode(ThemeMode.values.byName(choice));
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    NfcProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showPlatformChoiceSheet(
      context,
      title: l10n.language,
      selectedValue: provider.locale.languageCode,
      cancelLabel: l10n.cancel,
      options: const {
        'English': 'en',
        'Türkçe': 'tr',
        'Deutsch': 'de',
        'Português': 'pt',
      },
    );
    if (choice == null) return;
    await provider.setLocale(Locale(choice));
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'de':
        return 'Deutsch';
      case 'pt':
        return 'Português';
      case 'en':
      default:
        return 'English';
    }
  }

  Future<void> _showColorDialog(
    BuildContext context,
    NfcProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    const colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];
    await showPlatformPanel(
      context,
      title: l10n.themeColor,
      closeLabel: l10n.close,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: colors.map((color) {
          final selected = provider.themeColor == color;
          return GestureDetector(
            onTap: () async {
              await provider.setThemeColor(color);
              if (context.mounted) Navigator.pop(context);
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nfcProvider = context.watch<NfcProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.viewPaddingOf(context).bottom + 32,
        ),
        children: [
          // ── Dil ──────────────────────────────────────────────
          _PastelSection(
            title: l10n.language,
            icon: Icons.language,
            accent: Colors.indigo,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  _getLanguageName(nfcProvider.locale.languageCode),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, nfcProvider),
              ),
            ],
          ),

          // ── NFC Durumu ───────────────────────────────────────
          _PastelSection(
            title: l10n.nfcActive,
            icon: Icons.nfc,
            accent: Colors.teal,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        (nfcProvider.isNfcAvailable ? Colors.green : Colors.red)
                            .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    nfcProvider.isNfcAvailable ? Icons.nfc : Icons.nfc_outlined,
                    color: nfcProvider.isNfcAvailable
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(l10n.nfcActive),
                subtitle: Text(
                  nfcProvider.isNfcAvailable ? l10n.active : l10n.inactive,
                ),
                trailing: OutlinedButton(
                  onPressed: () => nfcProvider.openSettings(),
                  child: Text(l10n.settings),
                ),
              ),
            ],
          ),

          // ── Tercihler ────────────────────────────────────────
          _PastelSection(
            title: l10n.settings,
            icon: Icons.tune,
            accent: Colors.purple,
            children: [
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.auto_awesome_outlined),
                title: const Text('Auto Scan'),
                subtitle: const Text('Start scanning when app opens'),
                value: nfcProvider.autoScan,
                onChanged: (v) => nfcProvider.setAutoScan(v),
              ),
              SwitchListTile.adaptive(
                secondary: const Icon(Icons.volume_up_outlined),
                title: Text(l10n.soundFeedback),
                subtitle: const Text(
                  'Sound confirmation when tag is read or written',
                ),
                value: nfcProvider.soundEnabled,
                onChanged: (v) => nfcProvider.setSoundEnabled(v),
              ),
            ],
          ),

          // ── Görünüm ──────────────────────────────────────────
          _PastelSection(
            title: l10n.themeColor,
            icon: Icons.palette_outlined,
            accent: Colors.orange,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text("${l10n.darkTheme} / ${l10n.lightTheme}"),
                subtitle: Text(_formatThemeMode(nfcProvider.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, nfcProvider),
              ),
              ListTile(
                leading: Icon(Icons.color_lens, color: nfcProvider.themeColor),
                title: Text(l10n.themeColor),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showColorDialog(context, nfcProvider),
              ),
            ],
          ),

          // ── Hakkında ─────────────────────────────────────────
          _PastelSection(
            title: l10n.about,
            icon: Icons.info_outline,
            accent: Colors.blue,
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.userManual),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManualScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.privacyPolicy),
                subtitle: const Text('41software.com/privacy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _launchUrl('https://www.41software.com/privacy'),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(l10n.shareApp),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: AppPlatform.shareTextFor(l10n.shareAppText),
                      sharePositionOrigin: AppPlatform.shareOrigin(context),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.about),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context, l10n),
              ),
              ListTile(
                leading: const Icon(
                  Icons.star_outline_rounded,
                  color: Colors.amber,
                ),
                title: Text(l10n.reviewRateNow),
                subtitle: Text(AppPlatform.isIOS ? 'App Store' : 'Google Play'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ReviewService.instance.openStoreListing(),
              ),
              ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: Text(l10n.version),
                subtitle: const Text('1.4.6+36'),
              ),
            ],
          ),

          // ── Sosyal Medya ─────────────────────────────────────
          _PastelSection(
            title: l10n.socialMedia,
            icon: Icons.public,
            accent: Colors.pink,
            children: [
              _SocialTile(
                icon: FontAwesomeIcons.youtube,
                title: 'Youtube',
                subtitle: '@41softwarecom',
                onTap: () => _launchUrl('https://youtube.com/@41softwarecom'),
              ),
              _SocialTile(
                icon: FontAwesomeIcons.instagram,
                title: 'Instagram',
                subtitle: '41software',
                onTap: () => _launchUrl('https://instagram.com/41software'),
              ),
              _SocialTile(
                icon: FontAwesomeIcons.twitter,
                title: 'Twitter',
                subtitle: '@41software',
                onTap: () => _launchUrl('https://twitter.com/41software'),
              ),
              _SocialTile(
                icon: FontAwesomeIcons.tiktok,
                title: 'Tiktok',
                subtitle: '@41software',
                onTap: () => _launchUrl('https://tiktok.com/@41software'),
              ),
            ],
          ),

          // ── Geliştiriciyi Destekle ───────────────────────────
          _PastelSection(
            title: l10n.supportDeveloper,
            icon: Icons.favorite_outline,
            accent: Colors.amber.shade700,
            children: [
              ListenableBuilder(
                listenable: AdService.instance,
                builder: (context, _) {
                  final isAdFree = AdService.instance.isAdFree;
                  final rem = AdService.instance.formattedRemainingTime;

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: Colors.amber,
                        size: 26,
                      ),
                    ),
                    title: Text(
                      isAdFree
                          ? "${l10n.watchAdToSupport} (+24h)"
                          : l10n.watchAdToSupport,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isAdFree
                          ? "⭐ ${l10n.adFreeActive} ($rem)\n${l10n.watchAdToSupportDesc}"
                          : l10n.watchAdToSupportDesc,
                    ),
                    isThreeLine: isAdFree,
                    trailing: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.amber,
                      size: 28,
                    ),
                    onTap: () {
                      AdService.instance.showRewardedAd(
                        onReward: () {
                          AdService.instance.addAdFreeHours(24);
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
                  );
                },
              ),
              // App Store Review 3.1.1: no external payment links that unlock
              // app content on iOS, so the donation links stay Android-only.
              if (!AppPlatform.isIOS)
                ListTile(
                  leading: const Icon(Icons.coffee, color: Colors.brown),
                  title: const Text('Buy Me a Coffee'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _launchUrl('https://buymeacoffee.com/41software'),
                ),
              if (!AppPlatform.isIOS)
                ListTile(
                  leading: const Icon(Icons.paypal, color: Colors.blue),
                  title: const Text('PayPal'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _launchUrl('https://paypal.me/asbaypc'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Made with ❤️ by 41Software',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    final links = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.aboutInfo),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _launchUrl(AppPlatform.websiteUrl),
          child: const Text(
            'Website: www.41software.com',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _launchUrl('mailto:info@41software.com'),
          child: const Text(
            'Email: info@41software.com',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );

    if (AppPlatform.isIOS) {
      showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('NFC Manager'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1.4.6+36'),
                const SizedBox(height: 12),
                links,
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
      return;
    }

    showAboutDialog(
      context: context,
      applicationName: 'NFC Manager',
      applicationVersion: '1.4.6+36',
      applicationIcon: Image.asset('assets/logo.png', width: 50, height: 50),
      children: [links],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    // canLaunchUrl yerine doğrudan açmayı dene: Android 11+ paket
    // görünürlüğü yüzünden canLaunchUrl yanlış "false" dönebiliyor.
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  String _formatThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

class _SocialTile extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SocialTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FaIcon(icon, size: 20),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

/// Ayarlar sayfasındaki bölümleri pastel renklerle kutulayan widget.
class _PastelSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final List<Widget> children;

  const _PastelSection({
    required this.title,
    required this.icon,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (AppPlatform.isIOS) {
      return CupertinoListSection.insetGrouped(
        header: Text(title.toUpperCase()),
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        // The inset-grouped section paints its own background, so each Material
        // row needs its own transparent Material for ink effects.
        children: children
            .map(
              (child) =>
                  Material(type: MaterialType.transparency, child: child),
            )
            .toList(),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.10 : 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.32 : 0.24),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 16, color: accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
