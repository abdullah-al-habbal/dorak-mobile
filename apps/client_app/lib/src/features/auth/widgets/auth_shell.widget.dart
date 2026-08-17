import 'package:flutter/material.dart';

class AuthShell extends StatelessWidget {
  final Widget? header;
  final double? headerSpacing;
  final Widget child;

  const AuthShell({
    super.key,
    this.header,
    this.headerSpacing,
    required this.child,
  });

  static const double horizontalMargin = 20;
  static const double verticalMargin = 24;
  static const double maxContentWidth = 480;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalMargin,
              vertical: verticalMargin,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ?header,
                      if (headerSpacing != null) SizedBox(height: headerSpacing!),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}