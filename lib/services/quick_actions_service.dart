import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

import '../core/platform_support.dart';

/// iOS Home Screen quick actions (long-press the app icon): read, write and
/// history shortcuts. Android keeps its existing launcher behaviour.
class QuickActionsService {
  QuickActionsService._();
  static final QuickActionsService instance = QuickActionsService._();

  static const String readAction = 'read_tag';
  static const String writeAction = 'write_tag';
  static const String historyAction = 'open_history';

  static const Map<String, int> _tabForAction = {
    readAction: 0,
    writeAction: 1,
    historyAction: 3,
  };

  bool _initialized = false;

  /// Registers the shortcut handler. [onTabRequested] receives the tab index
  /// that corresponds to the tapped shortcut (also when the app was launched
  /// from a shortcut).
  Future<void> initialize(void Function(int tabIndex) onTabRequested) async {
    if (!AppPlatform.isIOS || _initialized) return;
    _initialized = true;
    try {
      await const QuickActions().initialize((shortcutType) {
        final tab = _tabForAction[shortcutType];
        if (tab != null) onTabRequested(tab);
      });
    } catch (e) {
      debugPrint('QuickActions initialize failed: $e');
    }
  }

  /// Refreshes the shortcut titles so they follow the app language.
  Future<void> setItems({
    required String readLabel,
    required String writeLabel,
    required String historyLabel,
  }) async {
    if (!AppPlatform.isIOS) return;
    try {
      await const QuickActions().setShortcutItems([
        ShortcutItem(type: readAction, localizedTitle: readLabel),
        ShortcutItem(type: writeAction, localizedTitle: writeLabel),
        ShortcutItem(type: historyAction, localizedTitle: historyLabel),
      ]);
    } catch (e) {
      debugPrint('QuickActions setShortcutItems failed: $e');
    }
  }
}
