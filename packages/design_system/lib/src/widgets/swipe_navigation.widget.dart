import 'package:flutter/material.dart';

class SwipeNavigation extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeLeft;
  final double velocityThreshold;

  const SwipeNavigation({
    super.key,
    required this.child,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.velocityThreshold = 300.0,
  });

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < velocityThreshold) return;
    if (velocity > 0) {
      onSwipeRight?.call();
    } else {
      onSwipeLeft?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: child,
    );
  }
}
