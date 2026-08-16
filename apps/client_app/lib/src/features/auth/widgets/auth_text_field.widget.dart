import 'package:flutter/material.dart';

import 'package:design_system/design_system.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool enabled;
  final String? helperText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.enabled = true,
    this.helperText,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final hasFocus = _focusNode.hasFocus;
    const topRadius = BorderRadius.vertical(top: Radius.circular(8));

    UnderlineInputBorder border(Color color, double width) {
      return UnderlineInputBorder(
        borderRadius: topRadius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: _obscure,
      enabled: widget.enabled,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: DorakTypography.bodyLg.copyWith(color: colors.onSurface),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        filled: true,
        fillColor: hasFocus ? colors.inputBgFocus : colors.inputBgSoft,
        labelStyle: DorakTypography.bodyLg.copyWith(
          color: colors.onSurfaceVariant,
        ),
        floatingLabelStyle: DorakTypography.labelMd.copyWith(
          color: hasFocus ? colors.primary : colors.onSurfaceVariant,
        ),
        helperStyle: DorakTypography.labelMd.copyWith(color: colors.outline),
        errorStyle: DorakTypography.labelMd.copyWith(color: colors.error),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: border(colors.outlineVariant, 1),
        enabledBorder: border(colors.outlineVariant, 1),
        disabledBorder: border(colors.outlineVariant, 1),
        focusedBorder: border(colors.primary, 2),
        errorBorder: border(colors.error, 1),
        focusedErrorBorder: border(colors.error, 2),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              )
            : null,
      ),
    );
  }
}
