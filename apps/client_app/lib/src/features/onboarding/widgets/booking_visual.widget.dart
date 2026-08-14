import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

class BookingVisual extends StatefulWidget {
  const BookingVisual({super.key});

  @override
  State<BookingVisual> createState() => _BookingVisualState();
}

class _BookingVisualState extends State<BookingVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _staggeredAnimations = List.generate(
      3,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0 + (index * 0.1),
          0.5 + (index * 0.1),
          curve: Curves.easeOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);

    Widget stagger(int index, Widget child) {
      return FadeTransition(
        opacity: _staggeredAnimations[index],
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(_staggeredAnimations[index]),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.primaryFixedDim.withValues(alpha: 0.45),
                  colors.primaryFixedDim.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              stagger(
                0,
                Transform.rotate(
                  angle: -0.035,
                  child: _GlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            borderRadius: DorakDimensions.radiusDefault,
                          ),
                          child: Icon(
                            Icons.content_cut,
                            color: colors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.bookingServiceLabel,
                                style: DorakTypography.labelLg.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                l10n.bookingServiceMeta,
                                style: DorakTypography.bodyMd.copyWith(
                                  color: colors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: colors.primary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              stagger(
                1,
                Transform.translate(
                  offset: const Offset(24, 0),
                  child: _GlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.surface,
                            border: Border.all(
                              color: colors.primaryFixed,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            color: colors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.bookingProfessionalLabel,
                              style: DorakTypography.labelLg.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.bookingProfessionalRating,
                                  style: DorakTypography.labelMd.copyWith(
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              stagger(
                2,
                Transform.rotate(
                  angle: 0.035,
                  child: _GlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primaryContainer,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: colors.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.bookingDateLabel,
                                style: DorakTypography.labelLg.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                l10n.bookingTimeLabel,
                                style: DorakTypography.bodyMd.copyWith(
                                  color: colors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary,
                          ),
                          child: Icon(
                            Icons.check,
                            color: colors.onPrimary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = DorakColors.of(context);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.8),
        borderRadius: DorakDimensions.radiusLg,
        border: Border.all(
          color: colors.primaryFixed.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.surfaceTint.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
