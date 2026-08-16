import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/onboarding/onboarding_config.event.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.state.dart';

class OnboardingConfigBloc extends Bloc<OnboardingConfigEvent, OnboardingConfigState> {
  OnboardingConfigBloc(this._repository)
      : super(const OnboardingConfigState()) {
    on<OnboardingConfigLoadRequested>(_onLoad);
  }

  final OnboardingConfigRepository _repository;

  Future<void> _onLoad(
    OnboardingConfigLoadRequested event,
    Emitter<OnboardingConfigState> emit,
  ) async {
    if (state.localeCode == event.localeCode) return;
    emit(state.copyWith(
      localeCode: event.localeCode,
      isLoading: true,
      clearError: true,
    ));
    try {
      final config = await _repository.fetchOnboardingConfig(
        locale: event.localeCode,
      );
      emit(state.copyWith(config: config, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }
}
