import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'package:design_system/design_system.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FavoritesView();
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    return Scaffold(
      body: StatusView(
        icon: Icons.favorite_border_outlined,
        title: l10n.favoritesTitle,
        message: l10n.favoritesSubtitle,
        actionLabel: l10n.favoritesActionLabel,
        onAction: () => DefaultTabController.of(context).animateTo(0),
        iconColor: colors.primary,
      ),
    );
  }
}