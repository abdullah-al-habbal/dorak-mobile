import 'package:equatable/equatable.dart';
import 'package:core/core.dart';

class OnboardingConfigState extends Equatable {
  const OnboardingConfigState({
    this.config,
    this.localeCode,
    this.isLoading = false,
    this.error,
  });

  final OnboardingConfigDto? config;
  final String? localeCode;
  final bool isLoading;
  final Object? error;

  String? get heroImageUrl => config?.heroImageUrl;

  OnboardingConfigState copyWith({
    OnboardingConfigDto? config,
    String? localeCode,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return OnboardingConfigState(
      config: config ?? this.config,
      localeCode: localeCode ?? this.localeCode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [config, localeCode, isLoading, error];
}
