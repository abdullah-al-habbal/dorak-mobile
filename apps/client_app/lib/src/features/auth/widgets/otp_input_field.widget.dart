import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:design_system/design_system.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspaceWhenEmpty;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspaceWhenEmpty,
    this.autofocus = false,
    this.hasError = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    const topRadius = BorderRadius.vertical(top: Radius.circular(8));

    UnderlineInputBorder border(Color color, double width) {
      return UnderlineInputBorder(
        borderRadius: topRadius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final idleColor = hasError ? colors.error : colors.outlineVariant;

    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controller.text.isEmpty) {
          onBackspaceWhenEmpty();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: enabled,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: DorakTypography.headlineSm.copyWith(color: colors.onSurface),
        cursorColor: colors.primary,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: colors.inputBgSoft,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: border(idleColor, 1),
          enabledBorder: border(idleColor, 1),
          disabledBorder: border(idleColor, 1),
          focusedBorder: border(hasError ? colors.error : colors.primary, 2),
        ),
      ),
    );
  }
}
