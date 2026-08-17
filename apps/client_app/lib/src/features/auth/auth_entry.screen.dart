import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:localization/localization.dart';

import 'package:client_app/src/features/auth/widgets/auth_entry_background.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_entry_content.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_entry_header.widget.dart';
import 'package:client_app/src/features/auth/widgets/auth_shell.widget.dart';

class AuthEntryScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onGuest;
  final VoidCallback? onLocaleToggle;

  const AuthEntryScreen({
    super.key,
    required this.onLogin,
    required this.onSignup,
    required this.onGuest,
    this.onLocaleToggle,
  });

  @override
  State<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends State<AuthEntryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _staggeredAnimations = [
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    ];

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = DorakColors.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthEntryBackground()),
          AuthShell(
            header: FadeTransition(
              opacity: _staggeredAnimations[0],
              child: AuthEntryHeader(
                brandLabel: l10n.splashTitle,
                title: l10n.authWelcomeTitle,
                subtitle: l10n.authSubtitle,
              ),
            ),
            headerSpacing: 48,
            child: AuthEntryContent(
              staggeredAnimations: _staggeredAnimations,
              onLogin: widget.onLogin,
              onSignup: widget.onSignup,
              onGuest: widget.onGuest,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: LocaleSwitcher(
                  label: isArabic ? l10n.localeEnglish : l10n.localeArabic,
                  onPressed: widget.onLocaleToggle ?? () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
