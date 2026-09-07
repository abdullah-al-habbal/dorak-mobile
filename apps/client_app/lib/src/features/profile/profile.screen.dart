import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'package:design_system/design_system.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onChangePassword;

  const ProfileScreen({super.key, required this.onChangePassword});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StatusView(
              icon: Icons.person_outline,
              title: l10n.profileTitle,
              message: l10n.profileSubtitle,
              actionLabel: l10n.profileActionLabel,
              onAction: () => DefaultTabController.of(context).animateTo(0),
              iconColor: colors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DorakDimensions.marginMobile),
            child: SecondaryButton(
              label: l10n.changePasswordTitle,
              onPressed: onChangePassword,
            ),
          ),
        ],
      ),
    );
  }
}
