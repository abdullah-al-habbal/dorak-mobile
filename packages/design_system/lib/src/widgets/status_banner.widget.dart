import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/tokens.barrel.dart';

class StatusBanner extends StatelessWidget {
  final String message;
  final Color? color;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StatusBanner({
    super.key,
    required this.message,
    this.color,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final resolvedColor = color ?? colors.error;

    return Row(
      children: [
        Icon(Icons.error_outline, size: 18, color: resolvedColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: DorakTypography.labelMd.copyWith(color: resolvedColor),
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: resolvedColor,
              textStyle: DorakTypography.labelLg.copyWith(
                color: resolvedColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}