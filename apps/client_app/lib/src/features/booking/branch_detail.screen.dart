import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

import 'package:client_app/src/features/booking/branch_detail.bloc.dart';
import 'package:client_app/src/features/booking/branch_detail.event.dart';
import 'package:client_app/src/features/booking/branch_detail.state.dart';
import 'package:client_app/src/features/booking/widgets/floor_plan_grid.widget.dart';

class BranchDetailScreen extends StatefulWidget {
  const BranchDetailScreen({
    super.key,
    required this.bloc,
    required this.branchId,
    required this.onLocaleToggle,
    required this.onViewBookings,
  });

  final BranchDetailBloc bloc;
  final String branchId;
  final VoidCallback onLocaleToggle;
  final VoidCallback onViewBookings;

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(BranchDetailStarted(widget.branchId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<BranchDetailBloc, BranchDetailState>(
          bloc: widget.bloc,
          buildWhen: (previous, current) =>
              previous.detail?.name != current.detail?.name,
          builder: (context, state) => Text(state.detail?.name ?? ''),
        ),
        actions: [
          LocaleSwitcher(
            label: isArabic ? l10n.localeEnglish : l10n.localeArabic,
            onPressed: widget.onLocaleToggle,
          ),
        ],
      ),
      body: BlocBuilder<BranchDetailBloc, BranchDetailState>(
        bloc: widget.bloc,
        builder: (context, state) {
          if (state.error != null && state.detail == null) {
            return StatusView(
              icon: Icons.error_outline,
              title: l10n.errorTitleGeneric,
              message: l10n.errorNetwork,
              actionLabel: l10n.actionRetry,
              onAction: () =>
                  widget.bloc.add(const BranchDetailRetried()),
            );
          }
          if (state.isLoading || state.detail == null) {
            return const AppLoader.page();
          }
          if (state.succeeded) {
            return StatusView(
              icon: Icons.check_circle_outline,
              title: l10n.bookingSuccessTitle,
              message: l10n.bookingSuccessMessage,
              actionLabel: l10n.bookingViewBookings,
              onAction: widget.onViewBookings,
            );
          }
          return _BranchDetailBody(
            bloc: widget.bloc,
            state: state,
          );
        },
      ),
    );
  }
}

class _BranchDetailBody extends StatelessWidget {
  const _BranchDetailBody({
    required this.bloc,
    required this.state,
  });

  final BranchDetailBloc bloc;
  final BranchDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final detail = state.detail!;
    return ListView(
      padding: const EdgeInsets.all(DorakDimensions.marginMobile),
      children: [
        Text(
          detail.name,
          style: DorakTypography.headlineLgMobile.copyWith(
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.branchChairsCount(detail.chairsCount),
          style: DorakTypography.bodyMd.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: DorakDimensions.spacingLarge),
        if (state.plan != null) ...[
          FloorPlanGrid(
            chairs: state.plan!.chairs,
            selectedChairId: state.selectedChairId,
            onChairSelected: (id) =>
                bloc.add(BranchDetailChairSelected(id)),
            availableLabel: l10n.branchAvailableLabel,
            occupiedLabel: l10n.branchOccupiedLabel,
          ),
          const SizedBox(height: DorakDimensions.spacingLarge),
        ] else if (state.planFailed) ...[
          StatusBanner(
            message: l10n.errorNetwork,
            actionLabel: l10n.actionRetry,
            onAction: () => bloc.add(const BranchDetailRetried()),
          ),
          const SizedBox(height: DorakDimensions.spacingLarge),
        ],
        if (detail.barbers.isNotEmpty) ...[
          Text(
            l10n.branchBarbersTitle,
            style: DorakTypography.titleLg,
          ),
          const SizedBox(height: DorakDimensions.spacingSmall),
          Text(
            detail.barbers.map((barber) => barber.name).join(' · '),
            style: DorakTypography.bodyMd.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: DorakDimensions.spacingLarge),
        ],
        if (detail.services.isNotEmpty) ...[
          Text(
            l10n.bookingSelectServices,
            style: DorakTypography.titleLg,
          ),
          ...detail.services.map(
            (service) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(service.name),
              value: state.selectedServiceIds.contains(service.id),
              activeColor: colors.primary,
              onChanged: (selected) {
                final ids = List<String>.of(state.selectedServiceIds);
                if (selected == true) {
                  ids.add(service.id);
                } else {
                  ids.remove(service.id);
                }
                bloc.add(BranchDetailServicesChanged(ids));
              },
            ),
          ),
          const SizedBox(height: DorakDimensions.spacingMedium),
        ],
        Text(
          l10n.bookingSelectTime,
          style: DorakTypography.titleLg,
        ),
        const SizedBox(height: DorakDimensions.spacingSmall),
        SecondaryButton(
          label: state.selectedTime == null
              ? l10n.bookingSelectTime
              : DateFormat.yMMMd(
                      Localizations.localeOf(context).languageCode,
                    ).add_Hm().format(state.selectedTime!.toLocal()),
          onPressed: () => _pickTime(context),
        ),
        const SizedBox(height: DorakDimensions.spacingMedium),
        if (state.submitError != null) ...[
          StatusBanner(message: _submitMessage(context)),
          const SizedBox(height: DorakDimensions.spacingSmall),
        ],
        PrimaryButton(
          label: l10n.bookingConfirmAction,
          onPressed: () => bloc.add(const BranchDetailBookingSubmitted()),
          isDisabled: !state.canSubmit,
          isLoading: state.isSubmitting,
        ),
      ],
    );
  }

  String _submitMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = state.submitError;
    if (error is ApiException && error.statusCode == 409) {
      return l10n.bookingConflictMessage;
    }
    if (error is ValidationException) {
      final fields =
          error.errors.values.expand((messages) => messages).join('\n');
      if (fields.isNotEmpty) return fields;
    }
    if (error is NetworkException) return l10n.errorNetwork;
    return l10n.errorGeneric;
  }

  Future<void> _pickTime(BuildContext context) async {
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
    bloc.add(
      BranchDetailTimeChanged(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
    );
  }
}
