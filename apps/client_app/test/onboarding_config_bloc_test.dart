import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/onboarding/onboarding_config.bloc.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.event.dart';
import 'package:client_app/src/features/onboarding/onboarding_config.state.dart';

class _FlakyConfigRepository implements OnboardingConfigRepository {
  Object? error;
  int calls = 0;
  final List<String?> requestedLocales = [];

  @override
  Future<OnboardingConfigDto> fetchOnboardingConfig({String? locale}) async {
    calls++;
    requestedLocales.add(locale);
    final failure = error;
    if (failure != null) throw failure;
    return OnboardingConfigDto(
      heroImageUrl: 'https://cdn.example.com/$locale.jpg',
      season: null,
      locale: locale ?? 'en',
    );
  }
}

void main() {
  late _FlakyConfigRepository repository;

  setUp(() => repository = _FlakyConfigRepository());

  OnboardingConfigBloc bloc() => OnboardingConfigBloc(repository);

  blocTest<OnboardingConfigBloc, OnboardingConfigState>(
    'loads the config for a locale',
    build: bloc,
    act: (bloc) => bloc.add(const OnboardingConfigLoadRequested(localeCode: 'en')),
    verify: (bloc) {
      expect(repository.calls, 1);
      expect(bloc.state.heroImageUrl, 'https://cdn.example.com/en.jpg');
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNull);
    },
  );

  blocTest<OnboardingConfigBloc, OnboardingConfigState>(
    'a failed load is retryable for the same locale',
    build: bloc,
    act: (bloc) async {
      repository.error = Exception('offline');
      bloc.add(const OnboardingConfigLoadRequested(localeCode: 'en'));
      await pumpEventQueue();

      repository.error = null;
      bloc.add(const OnboardingConfigLoadRequested(localeCode: 'en'));
      await pumpEventQueue();
    },
    verify: (bloc) {
      expect(
        repository.calls,
        2,
        reason: 'the guard assigned localeCode before fetching and then '
            'compared against it, so a failed load could never be retried',
      );
      expect(bloc.state.error, isNull);
      expect(bloc.state.heroImageUrl, 'https://cdn.example.com/en.jpg');
    },
  );

  blocTest<OnboardingConfigBloc, OnboardingConfigState>(
    'a successful load is not refetched for the same locale',
    build: bloc,
    act: (bloc) async {
      bloc.add(const OnboardingConfigLoadRequested(localeCode: 'en'));
      await pumpEventQueue();
      bloc.add(const OnboardingConfigLoadRequested(localeCode: 'en'));
      await pumpEventQueue();
    },
    verify: (bloc) => expect(repository.calls, 1),
  );

  blocTest<OnboardingConfigBloc, OnboardingConfigState>(
    'a locale change refetches',
    build: bloc,
    act: (bloc) async {
      bloc.add(const OnboardingConfigLoadRequested(localeCode: 'en'));
      await pumpEventQueue();
      bloc.add(const OnboardingConfigLoadRequested(localeCode: 'ar'));
      await pumpEventQueue();
    },
    verify: (bloc) {
      expect(repository.requestedLocales, ['en', 'ar']);
      expect(bloc.state.heroImageUrl, 'https://cdn.example.com/ar.jpg');
    },
  );
}
