import 'package:equatable/equatable.dart';

abstract class OnboardingConfigEvent extends Equatable {
  const OnboardingConfigEvent();

  @override
  List<Object?> get props => const [];
}

class OnboardingConfigLoadRequested extends OnboardingConfigEvent {
  const OnboardingConfigLoadRequested({required this.localeCode});

  final String localeCode;

  @override
  List<Object?> get props => [localeCode];
}
