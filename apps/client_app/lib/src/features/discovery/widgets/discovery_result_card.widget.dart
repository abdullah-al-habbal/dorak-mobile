import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'package:design_system/design_system.dart';

class DiscoveryResultCard extends StatelessWidget {
  const DiscoveryResultCard({
    super.key,
    required this.branch,
    required this.rankBadge,
    required this.compatibilityBadge,
    required this.distanceLabel,
    required this.bookNowLabel,
    required this.onBookNow,
    required this.viewDetailsLabel,
    this.onViewDetails,
  });

  final BranchDto branch;
  final String? rankBadge;
  final String? compatibilityBadge;
  final String? distanceLabel;
  final String bookNowLabel;
  final VoidCallback onBookNow;
  final String viewDetailsLabel;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final viewDetails = onViewDetails;
    final badges = [rankBadge, compatibilityBadge, distanceLabel]
        .whereType<String>()
        .join('  ·  ');
    return Container(
      padding: const EdgeInsets.all(DorakDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
              borderRadius: DorakDimensions.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(branch.name, style: DorakTypography.titleLg),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: DorakDimensions.spacingSmall / 2),
            Text(
              badges,
              style: DorakTypography.bodyMd.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: DorakDimensions.spacingMedium),
          PrimaryButton(label: bookNowLabel, onPressed: onBookNow),
          if (viewDetails != null)
            Center(
              child: SkipButton(
                label: viewDetailsLabel,
                onPressed: viewDetails,
              ),
            ),
        ],
      ),
    );
  }
}
