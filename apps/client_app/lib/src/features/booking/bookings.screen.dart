import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'package:design_system/design_system.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BookingsView();
  }
}

class _BookingsView extends StatelessWidget {
  const _BookingsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    return Scaffold(
      body: StatusView(
        icon: Icons.calendar_month_outlined,
        title: l10n.bookingsTitle,
        message: l10n.bookingsSubtitle,
        actionLabel: l10n.bookingsActionLabel,
        onAction: () => DefaultTabController.of(context).animateTo(0),
        iconColor: colors.primary,
      ),
    );
  }
}