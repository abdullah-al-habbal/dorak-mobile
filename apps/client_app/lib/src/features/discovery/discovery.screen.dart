import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';

import 'package:design_system/design_system.dart';

import 'package:client_app/src/features/discovery/discovery.bloc.dart';
import 'package:client_app/src/features/discovery/discovery.event.dart';
import 'package:client_app/src/features/discovery/discovery.state.dart';
import 'package:client_app/src/features/discovery/widgets/discovery_filter_bar.widget.dart';
import 'package:client_app/src/features/discovery/widgets/discovery_result_card.widget.dart';

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({
    super.key,
    required this.bloc,
    required this.onLocaleToggle,
    required this.onBookNow,
    this.onViewDetails,
  });

  final DiscoveryBloc bloc;
  final VoidCallback onLocaleToggle;
  final VoidCallback onBookNow;
  final ValueChanged<String>? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: _DiscoveryView(
        bloc: bloc,
        onLocaleToggle: onLocaleToggle,
        onBookNow: onBookNow,
        onViewDetails: onViewDetails,
      ),
    );
  }
}

class _DiscoveryView extends StatelessWidget {
  const _DiscoveryView({
    required this.bloc,
    required this.onLocaleToggle,
    required this.onBookNow,
    required this.onViewDetails,
  });

  final DiscoveryBloc bloc;
  final VoidCallback onLocaleToggle;
  final VoidCallback onBookNow;
  final ValueChanged<String>? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discoveryTitle),
        actions: [
          LocaleSwitcher(
            label: isArabic ? l10n.localeEnglish : l10n.localeArabic,
            onPressed: onLocaleToggle,
          ),
        ],
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        bloc: bloc,
        builder: (context, state) {
          if (!state.locationReady) {
            return StatusView(
              icon: Icons.location_on_outlined,
              title: l10n.locationRequiredTitle,
              message: l10n.locationRequiredMessage,
              actionLabel: l10n.enableLocationAction,
              onAction: () =>
                  bloc.add(const DiscoveryLocationRequested()),
            );
          }
          if (state.page.hasFailedFirst) {
            return StatusView(
              icon: Icons.error_outline,
              title: l10n.errorTitleGeneric,
              message: l10n.errorNetwork,
              actionLabel: l10n.actionRetry,
              onAction: () => bloc.add(const DiscoveryRetryRequested()),
            );
          }
          if (state.page.isFirstLoad) {
            return const AppLoader.page();
          }
          if (state.page.isEmpty) {
            return StatusView(
              icon: Icons.search_off_outlined,
              title: l10n.emptyTitleGeneric,
              message: l10n.emptyMessageGeneric,
              actionLabel: l10n.actionRetry,
              onAction: () => bloc.add(const DiscoveryRetryRequested()),
            );
          }
          return _DiscoveryFeed(
            bloc: bloc,
            state: state,
            onBookNow: onBookNow,
            onViewDetails: onViewDetails,
          );
        },
      ),
    );
  }
}

class _DiscoveryFeed extends StatelessWidget {
  const _DiscoveryFeed({
    required this.bloc,
    required this.state,
    required this.onBookNow,
    required this.onViewDetails,
  });

  final DiscoveryBloc bloc;
  final DiscoveryState state;
  final VoidCallback onBookNow;
  final ValueChanged<String>? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final items = state.page.items;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          bloc.add(const DiscoveryLoadMoreRequested());
        }
        return false;
      },
      child: RefreshIndicator(
        color: colors.primary,
        onRefresh: () async {
          bloc.add(const DiscoveryRefreshRequested());
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(DorakDimensions.marginMobile),
          itemCount: items.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) return _feedHeader(context);
            if (index == items.length + 1) return _feedFooter(context);
            final branch = items[index - 1];
            return Padding(
              padding: const EdgeInsets.only(
                bottom: DorakDimensions.spacingMedium,
              ),
              child: DiscoveryResultCard(
                branch: branch,
                rankBadge: branch.rank == null
                    ? null
                    : l10n.discoverRankBadge(branch.rank!),
                compatibilityBadge: branch.compatibilityScore == null
                    ? null
                    : l10n.discoverCompatibilityBadge(
                        (branch.compatibilityScore! * 100).round(),
                      ),
                distanceLabel: branch.distance == null
                    ? null
                    : l10n.discoverDistanceLabel(branch.distance!),
                bookNowLabel: l10n.bookNow,
                onBookNow: onBookNow,
                viewDetailsLabel: l10n.viewDetails,
                onViewDetails: onViewDetails == null
                    ? null
                    : () => onViewDetails!(branch.id.toString()),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _feedHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final filters = state.filters;
    return Padding(
      padding: const EdgeInsets.only(bottom: DorakDimensions.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isStale)
            Padding(
              padding: const EdgeInsets.only(
                bottom: DorakDimensions.spacingSmall,
              ),
              child: StatusBanner(
                message: l10n.discoverStaleLabel,
                color: colors.secondary,
              ),
            ),
          if (state.page.hasFailedRefresh)
            Padding(
              padding: const EdgeInsets.only(
                bottom: DorakDimensions.spacingSmall,
              ),
              child: StatusBanner(
                message: l10n.errorNetwork,
                actionLabel: l10n.actionRetry,
                onAction: () => bloc.add(const DiscoveryRetryRequested()),
              ),
            ),
          DiscoveryFilterBar(
            selectedUniverse: filters.universe,
            menLabel: l10n.discoverUniverseMen,
            womenLabel: l10n.discoverUniverseWomen,
            onUniverseChanged: (universe) =>
                bloc.add(DiscoveryUniverseChanged(universe)),
            availableNow: filters.availableNow,
            onAvailableNowChanged: (value) => bloc.add(
              DiscoveryFiltersChanged(
                value == null
                    ? filters.copyWith(clearAvailableNow: true)
                    : filters.copyWith(availableNow: value),
              ),
            ),
            availableNowLabel: l10n.availableNow,
            priceMin: filters.priceRangeMin,
            priceMax: filters.priceRangeMax,
            onPriceChanged: (range) => bloc.add(
              DiscoveryFiltersChanged(
                range.start <= 0 &&
                        range.end >= DiscoveryFilterBar.maxPrice
                    ? filters.copyWith(clearPriceRange: true)
                    : filters.copyWith(
                        priceRangeMin: range.start,
                        priceRangeMax: range.end,
                      ),
              ),
            ),
            priceLabel: l10n.price,
            ratingMin: filters.ratingMin,
            onRatingChanged: (value) => bloc.add(
              DiscoveryFiltersChanged(
                value == null
                    ? filters.copyWith(clearRatingMin: true)
                    : filters.copyWith(ratingMin: value),
              ),
            ),
            ratingLabel: l10n.rating,
            rankedByDistanceLabel: l10n.discoverRankedByDistance,
          ),
        ],
      ),
    );
  }

  Widget _feedFooter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (state.page.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: DorakDimensions.spacingMedium),
        child: AppLoader.inline(),
      );
    }
    if (state.page.hasFailedMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DorakDimensions.spacingSmall,
        ),
        child: StatusBanner(
          message: l10n.errorNetwork,
          actionLabel: l10n.actionRetry,
          onAction: () => bloc.add(const DiscoveryRetryRequested()),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
