import 'package:equatable/equatable.dart';
import 'package:core/core.dart';

import 'package:client_app/src/features/discovery/discovery_filter.entity.dart';

class DiscoveryState extends Equatable {
  const DiscoveryState({
    this.locationStatus,
    this.latitude,
    this.longitude,
    this.filters = const DiscoveryFilters(),
    this.page = const Paged<BranchDto>.initial(),
    this.isStale = false,
  });

  final LocationPermissionStatus? locationStatus;
  final double? latitude;
  final double? longitude;
  final DiscoveryFilters filters;
  final Paged<BranchDto> page;
  final bool isStale;

  bool get locationReady =>
      locationStatus == LocationPermissionStatus.granted &&
      latitude != null &&
      longitude != null;

  DiscoveryState copyWith({
    LocationPermissionStatus? locationStatus,
    double? latitude,
    double? longitude,
    DiscoveryFilters? filters,
    Paged<BranchDto>? page,
    bool? isStale,
  }) {
    return DiscoveryState(
      locationStatus: locationStatus ?? this.locationStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      filters: filters ?? this.filters,
      page: page ?? this.page,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  List<Object?> get props => [
        locationStatus,
        latitude,
        longitude,
        filters,
        page,
        isStale,
      ];
}
