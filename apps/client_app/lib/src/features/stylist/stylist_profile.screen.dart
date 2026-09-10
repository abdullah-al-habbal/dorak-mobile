import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

import 'package:client_app/src/features/stylist/stylist_profile.bloc.dart';
import 'package:client_app/src/features/stylist/stylist_profile.event.dart';
import 'package:client_app/src/features/stylist/stylist_profile.state.dart';

class StylistProfileScreen extends StatefulWidget {
  const StylistProfileScreen({
    super.key,
    required this.bloc,
    required this.barberId,
    required this.onLocaleToggle,
  });

  final StylistProfileBloc bloc;
  final String barberId;
  final VoidCallback onLocaleToggle;

  @override
  State<StylistProfileScreen> createState() => _StylistProfileScreenState();
}

class _StylistProfileScreenState extends State<StylistProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(StylistProfileStarted(widget.barberId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<StylistProfileBloc, StylistProfileState>(
          bloc: widget.bloc,
          buildWhen: (previous, current) =>
              previous.profile?.name != current.profile?.name,
          builder: (context, state) => Text(state.profile?.name ?? ''),
        ),
        actions: [
          LocaleSwitcher(
            label: isArabic ? l10n.localeEnglish : l10n.localeArabic,
            onPressed: widget.onLocaleToggle,
          ),
        ],
      ),
      body: BlocBuilder<StylistProfileBloc, StylistProfileState>(
        bloc: widget.bloc,
        builder: (context, state) {
          if (state.error != null && state.profile == null) {
            return StatusView(
              icon: Icons.error_outline,
              title: l10n.errorTitleGeneric,
              message: l10n.errorNetwork,
              actionLabel: l10n.actionRetry,
              onAction: () =>
                  widget.bloc.add(const StylistProfileRetried()),
            );
          }
          if (state.isLoading || state.profile == null) {
            return const AppLoader.page();
          }
          return _StylistProfileBody(
            bloc: widget.bloc,
            state: state,
          );
        },
      ),
    );
  }
}

class _StylistProfileBody extends StatelessWidget {
  const _StylistProfileBody({
    required this.bloc,
    required this.state,
  });

  final StylistProfileBloc bloc;
  final StylistProfileState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final profile = state.profile!;
    return ListView(
      padding: const EdgeInsets.all(DorakDimensions.marginMobile),
      children: [
        _buildHeader(profile, colors, l10n),
        const SizedBox(height: DorakDimensions.spacingLarge),
        _buildStats(profile, colors, l10n),
        const SizedBox(height: DorakDimensions.spacingLarge),
        _buildServices(profile, colors, l10n, localeCode),
      ],
    );
  }

  Widget _buildHeader(
    BarberProfileDto profile,
    DorakColors colors,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: colors.surfaceContainerHigh,
          child: Text(
            profile.name.characters.firstOrNull ?? '?',
            style: DorakTypography.headlineLgMobile.copyWith(
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: DorakTypography.headlineLgMobile.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (profile.rank != null) ...[
                    Text(
                      l10n.discoverRankBadge(profile.rank!),
                      style: DorakTypography.bodyMd.copyWith(
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (profile.compatibilityScore != null)
                    Text(
                      l10n
                          .discoverCompatibilityBadge(
                            (profile.compatibilityScore! * 100).round(),
                          )
                          .toString(),
                      style: DorakTypography.bodyMd.copyWith(
                        color: colors.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
    BarberProfileDto profile,
    DorakColors colors,
    AppLocalizations l10n,
  ) {
    final stats = <_StatItem>[];
    stats.add(
      _StatItem(
        value: '${profile.services.length}',
        label: l10n.stylistStatServicesLabel,
      ),
    );
    if (profile.rank != null) {
      stats.add(
        _StatItem(
          value: l10n.discoverRankBadge(profile.rank!),
          label: l10n.stylistStatRankLabel,
        ),
      );
    }
    if (profile.compatibilityScore != null) {
      stats.add(
        _StatItem(
          value: l10n
              .discoverCompatibilityBadge(
                (profile.compatibilityScore! * 100).round(),
              )
              .toString(),
          label: l10n.stylistStatCompatibilityLabel,
        ),
      );
    }
    if (stats.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: DorakDimensions.spacingLarge),
          Expanded(
            child: Column(
              children: [
                Text(
                  stats[i].value,
                  style: DorakTypography.titleLg.copyWith(
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stats[i].label,
                  style: DorakTypography.bodyMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServices(
    BarberProfileDto profile,
    DorakColors colors,
    AppLocalizations l10n,
    String localeCode,
  ) {
    if (profile.services.isEmpty) {
      return Text(
        l10n.stylistNoServicesMessage,
        style: DorakTypography.bodyMd.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    }
    final currencyById = <String, CurrencyDto>{};
    for (final c in state.currencies) {
      currencyById[c.id] = c;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stylistServicesTitle,
          style: DorakTypography.titleLg,
        ),
        const SizedBox(height: DorakDimensions.spacingSmall),
        ...profile.services.map(
          (service) => _buildServiceCard(
            service,
            currencyById,
            colors,
            l10n,
            localeCode,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BarberServiceDto service,
    Map<String, CurrencyDto> currencyById,
    DorakColors colors,
    AppLocalizations l10n,
    String localeCode,
  ) {
    final currencyCode =
        currencyById[service.currencyId]?.code ?? '';
    final formattedPrice = NumberFormat.decimalPattern(localeCode)
        .format(service.price);
    return Container(
      margin: const EdgeInsets.only(bottom: DorakDimensions.spacingSmall),
      padding: const EdgeInsets.all(DorakDimensions.spacingSmall),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: DorakDimensions.radiusMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: DorakTypography.labelLg,
                ),
                if (service.description != null &&
                    service.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    style: DorakTypography.bodyMd.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (service.atHome) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.home,
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.serviceAtHomeLabel,
                        style: DorakTypography.labelMd.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: DorakDimensions.spacingSmall),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.servicePrice(formattedPrice, currencyCode),
                style: DorakTypography.labelLg.copyWith(
                  color: colors.primary,
                ),
              ),
              if (service.duration != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.serviceDurationLabel(service.duration!),
                  style: DorakTypography.labelMd.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;
}
