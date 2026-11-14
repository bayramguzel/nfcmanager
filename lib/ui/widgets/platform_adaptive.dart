import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/platform_support.dart';

/// Activity indicator that matches the host platform: UIKit's spinner on iOS,
/// Material's circular progress indicator elsewhere.
class AdaptiveActivityIndicator extends StatelessWidget {
  /// Radius used by [CupertinoActivityIndicator] (iOS).
  final double radius;

  /// Box size used by [CircularProgressIndicator] (Android).
  final double size;

  final Color? color;

  const AdaptiveActivityIndicator({
    super.key,
    this.radius = 20,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.isIOS) {
      return CupertinoActivityIndicator(radius: radius, color: color);
    }
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 3, color: color),
    );
  }
}

/// Picks one value from a short list.
///
/// iOS gets the native action sheet sliding up from the bottom; Android keeps a
/// Material dialog with check marks.
Future<String?> showPlatformChoiceSheet(
  BuildContext context, {
  required String title,
  required Map<String, String> options,
  String? selectedValue,
  String cancelLabel = 'Cancel',
}) async {
  if (AppPlatform.isIOS) {
    return showCupertinoModalPopup<String>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(title),
        actions: options.entries
            .map(
              (entry) => CupertinoActionSheetAction(
                isDefaultAction: entry.value == selectedValue,
                onPressed: () => Navigator.pop(sheetContext, entry.value),
                child: Text(entry.key),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: Text(cancelLabel),
        ),
      ),
    );
  }

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries
              .map(
                (entry) => ListTile(
                  title: Text(entry.key),
                  trailing: entry.value == selectedValue
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(dialogContext, entry.value),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

/// Shows a panel with free content (colour picker, etc.).
///
/// iOS presents a bottom sheet, Android an alert dialog.
Future<void> showPlatformPanel(
  BuildContext context, {
  required String title,
  required Widget child,
  String closeLabel = 'Close',
}) async {
  if (AppPlatform.isIOS) {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) {
        final theme = CupertinoTheme.of(sheetContext);
        return Container(
          decoration: BoxDecoration(
            color: theme.barBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.viewPaddingOf(sheetContext).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4.resolveFrom(sheetContext),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Text(title, style: theme.textTheme.navTitleTextStyle),
              const SizedBox(height: 18),
              child,
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(closeLabel),
                ),
              ),
            ],
          ),
        );
      },
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: child,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(closeLabel),
        ),
      ],
    ),
  );
}

/// Form sheet used by the Wi-Fi / vCard wizards.
///
/// Returns `true` when the user taps the submit action.
Future<bool> showPlatformFormSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  required String submitLabel,
  String cancelLabel = 'Cancel',
}) async {
  if (AppPlatform.isIOS) {
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        final theme = CupertinoTheme.of(sheetContext);
        return Container(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.82),
          decoration: BoxDecoration(
            color: theme.barBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(bottom: media.viewPadding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(
                        sheetContext,
                      ),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: Text(cancelLabel),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.navTitleTextStyle,
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onPressed: () => Navigator.pop(sheetContext, true),
                      child: Text(
                        submitLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: builder(sheetContext),
                ),
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(child: builder(dialogContext)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(submitLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Single-line text prompt (APDU entry etc.).
Future<String?> showPlatformTextPrompt(
  BuildContext context, {
  required String title,
  required String hint,
  required TextEditingController controller,
  String submitLabel = 'OK',
  String cancelLabel = 'Cancel',
}) async {
  if (AppPlatform.isIOS) {
    return showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: hint,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.pop(dialogContext, value),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(cancelLabel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(submitLabel),
          ),
        ],
      ),
    );
  }

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (value) => Navigator.pop(dialogContext, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: Text(submitLabel),
        ),
      ],
    ),
  );
}
