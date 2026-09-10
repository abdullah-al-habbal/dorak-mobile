import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'package:design_system/design_system.dart';

class FloorPlanGrid extends StatelessWidget {
  const FloorPlanGrid({
    super.key,
    required this.chairs,
    required this.selectedChairId,
    required this.onChairSelected,
    required this.availableLabel,
    required this.occupiedLabel,
  });

  final List<FloorChairDto> chairs;
  final String? selectedChairId;
  final ValueChanged<String> onChairSelected;
  final String availableLabel;
  final String occupiedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendDot(color: colors.primary, label: availableLabel),
            const SizedBox(width: DorakDimensions.spacingMedium),
            _LegendDot(color: colors.error, label: occupiedLabel),
          ],
        ),
        const SizedBox(height: DorakDimensions.spacingMedium),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: chairs.length,
          itemBuilder: (context, index) {
            final chair = chairs[index];
            final selectable = chair.status == 'available';
            final selected = chair.id == selectedChairId;
            final background = selected
                ? colors.primary
                : !selectable
                    ? colors.surfaceContainerHighest
                    : colors.primaryContainer;
            final foreground = selected
                ? colors.onPrimary
                : !selectable
                    ? colors.outline
                    : colors.primary;
            return Padding(
              padding: const EdgeInsets.all(DorakDimensions.spacingSmall / 2),
              child: GestureDetector(
                onTap: selectable
                    ? () => onChairSelected(chair.id)
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: DorakDimensions.radiusMd,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.content_cut, color: foreground),
                      const SizedBox(height: 4),
                      Text(
                        chair.label ?? chair.id,
                        style: DorakTypography.labelMd.copyWith(
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: DorakTypography.labelMd),
      ],
    );
  }
}
