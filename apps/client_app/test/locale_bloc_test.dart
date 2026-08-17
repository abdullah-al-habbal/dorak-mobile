import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/core/locale/locale.bloc.dart';
import 'package:client_app/src/core/locale/locale.event.dart';

void main() {
  blocTest<LocaleBloc, Locale>(
    'starts on English',
    build: LocaleBloc.new,
    verify: (bloc) => expect(bloc.state, const Locale('en')),
  );

  blocTest<LocaleBloc, Locale>(
    'toggles English -> Arabic -> English',
    build: LocaleBloc.new,
    act: (bloc) {
      bloc.add(LocaleToggled());
      bloc.add(LocaleToggled());
    },
    expect: () => const [Locale('ar'), Locale('en')],
  );

  blocTest<LocaleBloc, Locale>(
    'sets an explicit locale',
    build: LocaleBloc.new,
    act: (bloc) => bloc.add(const LocaleSet(Locale('ar'))),
    expect: () => const [Locale('ar')],
  );

  blocTest<LocaleBloc, Locale>(
    'setting the locale already in effect emits nothing',
    build: LocaleBloc.new,
    act: (bloc) => bloc.add(const LocaleSet(Locale('en'))),
    expect: () => const <Locale>[],
    verify: (bloc) => expect(
      bloc.state,
      const Locale('en'),
      reason: 'Locale is value-equal, which is what lets it serve as the bloc '
          'state directly without a LocaleState wrapper',
    ),
  );
}
