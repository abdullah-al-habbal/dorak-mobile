import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';

class DiscoveryFilterBar extends StatelessWidget {
  const DiscoveryFilterBar({
    super.key,
    required this.selectedUniverse,
    required this.menLabel,
    required this.womenLabel,
    required this.onUniverseChanged,
    required this.availableNow,
    required this.onAvailableNowChanged,
    required this.availableNowLabel,
    required this.priceMin,
    required this.priceMax,
    required this.onPriceChanged,
    required this.priceLabel,
    required this.ratingMin,
    required this.onRatingChanged,
    required this.ratingLabel,
    required this.rankedByDistanceLabel,
  });

  static const double maxPrice = 500;

  final String selectedUniverse;
  final String menLabel;
  final String womenLabel;
  final ValueChanged<String> onUniverseChanged;
  final bool? availableNow;
  final ValueChanged<bool?> onAvailableNowChanged;
  final String availableNowLabel;
  final double? priceMin;
  final double? priceMax;
  final ValueChanged<RangeValues> onPriceChanged;
  final String priceLabel;
  final double? ratingMin;
  final ValueChanged<double?> onRatingChanged;
  final String ratingLabel;
  final String rankedByDistanceLabel;

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'men', label: Text(menLabel)),
              ButtonSegment(value: 'women', label: Text(womenLabel)),
            ],
            selected: {selectedUniverse},
            onSelectionChanged: (selection) =>
                onUniverseChanged(selection.first),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(availableNowLabel, style: DorakTypography.labelLg),
          value: availableNow ?? false,
          activeThumbColor: colors.primary,
          onChanged: (value) => onAvailableNowChanged(value ? true : null),
        ),
        Text(
          '$priceLabel: ${(priceMin ?? 0).round()} - ${(priceMax ?? maxPrice).round()}',
          style: DorakTypography.labelLg,
        ),
        RangeSlider(
          values: RangeValues(priceMin ?? 0, priceMax ?? maxPrice),
          min: 0,
          max: maxPrice,
          divisions: 50,
          activeColor: colors.primary,
          onChanged: onPriceChanged,
        ),
        Text(
          '$ratingLabel: ${(ratingMin ?? 0).toStringAsFixed(1)}',
          style: DorakTypography.labelLg,
        ),
        Slider(
          value: ratingMin ?? 0,
          min: 0,
          max: 5,
          divisions: 10,
          activeColor: colors.primary,
          onChanged: (value) => onRatingChanged(value <= 0 ? null : value),
        ),
        Text(
          rankedByDistanceLabel,
          style: DorakTypography.labelMd.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
