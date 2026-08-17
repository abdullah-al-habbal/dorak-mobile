import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/tokens.barrel.dart';
import 'package:design_system/src/widgets/primary_button.widget.dart';

class StatusView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final resolvedIconColor = iconColor ?? colors.onSurfaceVariant;
    final showAction = actionLabel != null && onAction != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DorakDimensions.marginMobile,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: resolvedIconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: DorakTypography.titleLg.copyWith(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: DorakTypography.bodyMd.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (showAction) ...[
              const SizedBox(height: 16),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}