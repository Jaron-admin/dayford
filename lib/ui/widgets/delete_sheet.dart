import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/scope.dart';
import '../theme/tokens.dart';
import 'chrome.dart';

/// iOS keeps the system action sheet. Android uses a Material bottom sheet
/// whose destructive action is the theme's brick-red token.
Future<bool> confirmDeleteModel(
  BuildContext context, {
  required String modelName,
  required String sizeLabel,
}) async {
  final tokens = TokenScope.of(context);
  final platform = Theme.of(context).platform;
  if (platform == TargetPlatform.iOS) {
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('删除「$modelName」？'),
        message: const Text('删除后日记都还在，只是暂时不会有回应。'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '删除',
              style: TextStyle(
                color: tokens.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
      ),
    );
    return result ?? false;
  }
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: tokens.card,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) => TokenScope(
      tokens: tokens,
      child: _AndroidDeleteSheet(
        tokens: tokens,
        modelName: modelName,
        sizeLabel: sizeLabel,
      ),
    ),
  );
  return result ?? false;
}

class _AndroidDeleteSheet extends StatelessWidget {
  const _AndroidDeleteSheet({
    required this.tokens,
    required this.modelName,
    required this.sizeLabel,
  });

  final DayfordTokens tokens;
  final String modelName;
  final String sizeLabel;

  @override
  Widget build(BuildContext context) {
    final styles = DayfordStyles(tokens);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(26, 10, 26, mathMax(24, bottom)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: tokens.chip,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '删除「$modelName」？',
            style: styles.sans(size: 17, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '会释放 $sizeLabel。删除后日记都还在，只是暂时不会有回应。',
            textAlign: TextAlign.center,
            style: styles.sans(size: 13, line: 20, color: tokens.ink2),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              key: const Key('confirm-delete'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                '删除',
                style: styles.sans(
                  size: 17,
                  weight: FontWeight.w600,
                  color: tokens.danger,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          DayfordButton(
            label: '取消',
            ghost: true,
            enabled: true,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}

double mathMax(double a, double b) => a > b ? a : b;

/// Confirms swapping the on-device model. Android stays a Material sheet.
Future<bool> confirmReplaceModel(
  BuildContext context, {
  required String modelName,
}) async {
  final tokens = TokenScope.of(context);
  final platform = Theme.of(context).platform;
  if (platform == TargetPlatform.iOS) {
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('换成「$modelName」？'),
        message: const Text('会开始下载，下载好之后用它来回应。'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('换成这个'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
      ),
    );
    return result ?? false;
  }
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: tokens.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) => TokenScope(
      tokens: tokens,
      child: _ReplaceSheet(tokens: tokens, modelName: modelName),
    ),
  );
  return result ?? false;
}

class _ReplaceSheet extends StatelessWidget {
  const _ReplaceSheet({required this.tokens, required this.modelName});

  final DayfordTokens tokens;
  final String modelName;

  @override
  Widget build(BuildContext context) {
    final styles = DayfordStyles(tokens);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(26, 18, 26, mathMax(24, bottom)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '换成「$modelName」？',
            style: styles.sans(size: 17, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '会开始下载，下载好之后用它来回应。',
            textAlign: TextAlign.center,
            style: styles.sans(size: 13, line: 20, color: tokens.ink2),
          ),
          const SizedBox(height: 18),
          DayfordButton(
            label: '换成这个',
            small: true,
            onPressed: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: 8),
          DayfordButton(
            label: '取消',
            ghost: true,
            small: true,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}
