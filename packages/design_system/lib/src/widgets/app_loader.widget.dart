import 'package:flutter/material.dart';

import 'package:design_system/src/tokens/tokens.barrel.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final bool expand;

  const AppLoader._({this.size = 32, this.expand = true});

  const AppLoader.page() : this._(size: 32, expand: true);

  const AppLoader.inline({double size = 20})
      : this._(size: size, expand: false);

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);
    final indicator = SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: colors.primary,
      ),
    );

    if (!expand) return indicator;

    return Center(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(child: indicator),
      ),
    );
  }
}