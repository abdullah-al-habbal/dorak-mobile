import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/stylist/stylist_profile.bloc.dart';
import 'package:client_app/src/features/stylist/stylist_profile.event.dart';
import 'package:client_app/src/features/stylist/stylist_profile.state.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeExploreRepository explore;
  late FakeCurrencyRepository currencies;

  setUp(() {
    explore = FakeExploreRepository();
    currencies = FakeCurrencyRepository();
  });

  StylistProfileBloc bloc() => StylistProfileBloc(explore, currencies);

  group('StylistProfileStarted', () {
    blocTest<StylistProfileBloc, StylistProfileState>(
      'loads profile and currencies together',
      build: bloc,
      act: (bloc) => bloc.add(const StylistProfileStarted('barber-1')),
      verify: (bloc) {
        expect(bloc.state.profile?.name, 'Karim');
        expect(bloc.state.currencies, hasLength(1));
        expect(bloc.state.currencies.first.code, 'SAR');
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<StylistProfileBloc, StylistProfileState>(
      'detail failure records the error',
      build: bloc,
      setUp: () => explore.error = offline(),
      act: (bloc) => bloc.add(const StylistProfileStarted('barber-1')),
      verify: (bloc) {
        expect(bloc.state.profile, isNull);
        expect(bloc.state.error, isA<NetworkException>());
      },
    );

    blocTest<StylistProfileBloc, StylistProfileState>(
      'currency failure keeps the profile with a currencyFailed flag',
      build: bloc,
      setUp: () => currencies.error = offline(),
      act: (bloc) => bloc.add(const StylistProfileStarted('barber-1')),
      verify: (bloc) {
        expect(bloc.state.profile?.name, 'Karim');
        expect(bloc.state.currencies, isEmpty);
        expect(bloc.state.currencyFailed, isTrue);
      },
    );
  });

  group('StylistProfileRetried', () {
    blocTest<StylistProfileBloc, StylistProfileState>(
      'reloads using the stored barberId',
      build: bloc,
      seed: () => const StylistProfileState(barberId: 'barber-1'),
      act: (bloc) => bloc.add(const StylistProfileRetried()),
      verify: (bloc) {
        expect(bloc.state.profile?.name, 'Karim');
        expect(bloc.state.isLoading, isFalse);
      },
    );

    blocTest<StylistProfileBloc, StylistProfileState>(
      'is a no-op when barberId is null',
      build: bloc,
      act: (bloc) => bloc.add(const StylistProfileRetried()),
      expect: () => [],
    );
  });
}
