import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/onboarding/widgets/booking_visual.widget.dart';

class BookingContent extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const BookingContent({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const BookingVisual(),
        const SizedBox(height: 16),
        Text(
          l10n.bookingTitle,
          style: DorakTypography.headlineLgMobile,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bookingSubtitle,
          style: DorakTypography.bodyLg,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const ProgressDots(
          count: 4,
          activeIndex: 2,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.previous,
                onPressed: onPrevious,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: l10n.next,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
