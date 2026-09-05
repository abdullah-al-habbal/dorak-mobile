import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'package:design_system/design_system.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    return Scaffold(
      body: StatusView(
        icon: Icons.person_outline,
        title: l10n.profileTitle,
        message: l10n.profileSubtitle,
        actionLabel: l10n.profileActionLabel,
        onAction: () => DefaultTabController.of(context).animateTo(0),
        iconColor: colors.primary,
      ),
    );
  }
}