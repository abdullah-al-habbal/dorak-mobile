import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

class SkipBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSkipForNow,
    required VoidCallback onDontShowAgain,
    required VoidCallback onCancel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SkipBottomSheetContent(
        onSkipForNow: onSkipForNow,
        onDontShowAgain: onDontShowAgain,
        onCancel: onCancel,
      ),
    );
  }
}

class _SkipBottomSheetContent extends StatelessWidget {
  final VoidCallback onSkipForNow;
  final VoidCallback onDontShowAgain;
  final VoidCallback onCancel;

  const _SkipBottomSheetContent({
    required this.onSkipForNow,
    required this.onDontShowAgain,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    return BottomSheetModal(
      onDismiss: onCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.skipOnboardingQuestion,
            style: DorakTypography.headlineSm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSkipForNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondaryContainer,
                foregroundColor: colors.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: DorakDimensions.radiusDefault,
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.skipForNow,
                style: DorakTypography.labelLg,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onDontShowAgain,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: DorakDimensions.radiusDefault,
                ),
                side: BorderSide(
                  color: colors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                l10n.dontShowAgain,
                style: DorakTypography.labelLg.copyWith(
                  color: colors.error,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SkipButton(
            label: l10n.cancel,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
