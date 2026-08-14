import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';

class AuthGuestButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthGuestButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<AuthGuestButton> createState() => _AuthGuestButtonState();
}

class _AuthGuestButtonState extends State<AuthGuestButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _hovered ? colors.primary : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _hovered ? colors.primary : colors.secondary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: DorakTypography.labelLg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label),
              const SizedBox(width: 4),
              Icon(
                isRtl ? Icons.arrow_back : Icons.arrow_forward,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
