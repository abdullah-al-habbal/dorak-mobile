import 'package:equatable/equatable.dart';

class DiscoveryFilters extends Equatable {
  const DiscoveryFilters({
    this.universe = 'men',
    this.radius = 10,
    this.perPage = 20,
    this.availableNow,
    this.priceRangeMin,
    this.priceRangeMax,
    this.ratingMin,
  });

  final String universe;
  final double radius;
  final int perPage;
  final bool? availableNow;
  final double? priceRangeMin;
  final double? priceRangeMax;
  final double? ratingMin;

  DiscoveryFilters copyWith({
    String? universe,
    double? radius,
    int? perPage,
    bool? availableNow,
    bool clearAvailableNow = false,
    double? priceRangeMin,
    double? priceRangeMax,
    bool clearPriceRange = false,
    double? ratingMin,
    bool clearRatingMin = false,
  }) {
    return DiscoveryFilters(
      universe: universe ?? this.universe,
      radius: radius ?? this.radius,
      perPage: perPage ?? this.perPage,
      availableNow:
          clearAvailableNow ? null : availableNow ?? this.availableNow,
      priceRangeMin:
          clearPriceRange ? null : priceRangeMin ?? this.priceRangeMin,
      priceRangeMax:
          clearPriceRange ? null : priceRangeMax ?? this.priceRangeMax,
      ratingMin: clearRatingMin ? null : ratingMin ?? this.ratingMin,
    );
  }

  @override
  List<Object?> get props => [
        universe,
        radius,
        perPage,
        availableNow,
        priceRangeMin,
        priceRangeMax,
        ratingMin,
      ];
}
