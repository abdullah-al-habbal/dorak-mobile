import 'package:equatable/equatable.dart';

import 'package:client_app/src/features/discovery/discovery_filter.entity.dart';

sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

class DiscoveryLocationRequested extends DiscoveryEvent {
  const DiscoveryLocationRequested();
}

class DiscoveryUniverseChanged extends DiscoveryEvent {
  const DiscoveryUniverseChanged(this.universe);

  final String universe;

  @override
  List<Object?> get props => [universe];
}

class DiscoveryFiltersChanged extends DiscoveryEvent {
  const DiscoveryFiltersChanged(this.filters);

  final DiscoveryFilters filters;

  @override
  List<Object?> get props => [filters];
}

class DiscoveryLoadMoreRequested extends DiscoveryEvent {
  const DiscoveryLoadMoreRequested();
}

class DiscoveryRefreshRequested extends DiscoveryEvent {
  const DiscoveryRefreshRequested();
}

class DiscoveryRetryRequested extends DiscoveryEvent {
  const DiscoveryRetryRequested();
}
