import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

import 'package:client_app/src/features/profile/history.bloc.dart';
import 'package:client_app/src/features/profile/history.event.dart';
import 'package:client_app/src/features/profile/history.state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.history,
    required this.clientName,
    required this.onChangePassword,
    required this.onViewBookings,
  });

  final HistoryBloc history;
  final String? clientName;
  final VoidCallback onChangePassword;
  final VoidCallback onViewBookings;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.history.add(const HistoryStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          bloc: widget.history,
          builder: (context, state) {
            if (state.rebooked) return _successView(context);
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification &&
                    notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                  widget.history.add(const HistoryLoadMoreRequested());
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  widget.history.add(const HistoryRefreshRequested());
                },
                child: ListView(
                  padding: const EdgeInsets.all(DorakDimensions.marginMobile),
                  children: [
                    _profileHeader(context),
                    const SizedBox(height: DorakDimensions.spacingLarge),
                    SecondaryButton(
                      label: AppLocalizations.of(context)!.changePasswordTitle,
                      onPressed: widget.onChangePassword,
                    ),
                    const SizedBox(height: DorakDimensions.spacingLarge),
                    Text(
                      AppLocalizations.of(context)!.historyTitle,
                      style: DorakTypography.titleLg,
                    ),
                    const SizedBox(height: DorakDimensions.spacingSmall),
                    ..._historySection(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _successView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusView(
      icon: Icons.check_circle_outline,
      title: l10n.historyRebookSuccessTitle,
      message: l10n.historyRebookSuccessMessage,
      actionLabel: l10n.bookingViewBookings,
      onAction: () {
        widget.history.add(const HistoryRebookAcknowledged());
        widget.onViewBookings();
      },
    );
  }

  Widget _profileHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final name = widget.clientName;
    final initial = (name == null || name.isEmpty)
        ? '?'
        : name.characters.first.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(DorakDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: DorakDimensions.radiusMd,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.onPrimaryContainer,
            child: Text(initial, style: DorakTypography.titleLg),
          ),
          const SizedBox(width: DorakDimensions.spacingMedium),
          Expanded(
            child: Text(
              (name == null || name.isEmpty) ? l10n.profileMemberLabel : name,
              style: DorakTypography.headlineLgMobile.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _historySection(BuildContext context, HistoryState state) {
    if (state.page.hasFailedFirst) {
      return [
        StatusView(
          icon: Icons.error_outline,
          title: AppLocalizations.of(context)!.errorTitleGeneric,
          message: AppLocalizations.of(context)!.errorNetwork,
          actionLabel: AppLocalizations.of(context)!.actionRetry,
          onAction: () => widget.history.add(const HistoryRetryRequested()),
        ),
      ];
    }
    if (state.page.isFirstLoad) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: DorakDimensions.spacingMedium,
          ),
          child: Center(child: AppLoader.inline()),
        ),
      ];
    }
    if (state.page.isEmpty) {
      return [
        StatusView(
          icon: Icons.history_outlined,
          title: AppLocalizations.of(context)!.historyEmptyTitle,
          message: AppLocalizations.of(context)!.historyEmptyMessage,
        ),
      ];
    }
    final localeCode = Localizations.localeOf(context).languageCode;
    final children = <Widget>[];
    if (state.rebookError != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(
            bottom: DorakDimensions.spacingSmall,
          ),
          child: StatusBanner(message: _rebookMessage(context, state.rebookError)),
        ),
      );
    }
    final items = _itemNames(localeCode, state.page.items);
    for (var i = 0; i < state.page.items.length; i++) {
      final item = state.page.items[i];
      children.add(
        Padding(
          padding: const EdgeInsets.only(
            bottom: DorakDimensions.spacingMedium,
          ),
          child: _HistoryCard(
            item: item,
            itemName: items[i],
            localeCode: localeCode,
            rebookLabel: AppLocalizations.of(context)!.historyRebookAction,
            isRebooking: state.rebookingId == item.id,
            onRebook: () => _pickRebookTime(context, item),
          ),
        ),
      );
    }
    children.add(_feedFooter(context, state));
    return children;
  }

  Widget _feedFooter(BuildContext context, HistoryState state) {
    if (state.page.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: DorakDimensions.spacingMedium),
        child: Center(child: AppLoader.inline()),
      );
    }
    if (state.page.hasFailedMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DorakDimensions.spacingSmall,
        ),
        child: StatusBanner(
          message: AppLocalizations.of(context)!.errorNetwork,
          actionLabel: AppLocalizations.of(context)!.actionRetry,
          onAction: () => widget.history.add(const HistoryRetryRequested()),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  static List<String> _itemNames(
    String localeCode,
    List<ServiceHistoryDto> items,
  ) {
    return items.map((item) {
      final names = item.catalogItem?.name ?? const <String, String>{};
      return names[localeCode] ?? names['en'] ?? '';
    }).toList();
  }

  String _rebookMessage(BuildContext context, Object? error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is ApiException && error.statusCode == 409) {
      return l10n.bookingConflictMessage;
    }
    if (error is NetworkException) return l10n.errorNetwork;
    return l10n.errorGeneric;
  }

  Object? stateRebookErrorOf(BuildContext context) {
    final state = context.read<HistoryBloc>().state;
    return state.rebookError;
  }

  Future<void> _pickRebookTime(
    BuildContext context,
    ServiceHistoryDto item,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    widget.history.add(
      HistoryRebookRequested(
        item.id,
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.itemName,
    required this.localeCode,
    required this.rebookLabel,
    required this.isRebooking,
    required this.onRebook,
  });

  final ServiceHistoryDto item;
  final String itemName;
  final String localeCode;
  final String rebookLabel;
  final bool isRebooking;
  final VoidCallback onRebook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final performedAt = item.performedAt;
    final metaLines = [
      if (itemName.isNotEmpty) itemName,
      if (item.barber != null) l10n.bookingWithBarber(item.barber!.name),
      if (item.branch != null) item.branch!.name,
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
                  performedAt == null
                      ? ''
                      : DateFormat.yMMMd(localeCode)
                          .add_Hm()
                          .format(performedAt.toLocal()),
                  style: DorakTypography.titleLg,
                ),
              ),
              if (isRebooking)
                const AppLoader.inline()
              else
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onRebook,
                  child: Text(rebookLabel),
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
        ],
      ),
    );
  }
}