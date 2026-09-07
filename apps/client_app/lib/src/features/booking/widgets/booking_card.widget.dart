import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';

import 'package:design_system/design_system.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.localeCode,
    required this.statusLabel,
    required this.barberLine,
    required this.chairLine,
    required this.cancelLabel,
    required this.isCancelling,
    this.onCancel,
  });

  final BookingDto booking;
  final String localeCode;
  final String statusLabel;
  final String? barberLine;
  final String? chairLine;
  final String cancelLabel;
  final bool isCancelling;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final cancel = onCancel;
    final metaLines = [
      ?barberLine,
      ?chairLine,
      if (booking.services.isNotEmpty)
        booking.services.map((service) => service.name).join(' · '),
    ];
    return Container(
      padding: const EdgeInsets.all(DorakDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
              borderRadius: DorakDimensions.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat.yMMMd(localeCode)
                      .add_Hm()
                      .format(booking.timeSlot.toLocal()),
                  style: DorakTypography.titleLg,
                ),
              ),
              Text(
                statusLabel,
                style: DorakTypography.labelLg.copyWith(
                  color: colors.primary,
                ),
              ),
            ],
          ),
          if (metaLines.isNotEmpty) ...[
            const SizedBox(height: DorakDimensions.spacingSmall / 2),
            Text(
              metaLines.join('\n'),
              style: DorakTypography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (cancel != null) ...[
            const SizedBox(height: DorakDimensions.spacingSmall),
            if (isCancelling)
              const AppLoader.inline()
            else
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: colors.error,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: cancel,
                child: Text(cancelLabel),
              ),
          ],
        ],
      ),
    );
  }
}
