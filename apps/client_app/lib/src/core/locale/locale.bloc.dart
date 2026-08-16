import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/core/locale/locale.event.dart';

class LocaleBloc extends Bloc<LocaleEvent, Locale> {
  LocaleBloc() : super(const Locale('en')) {
    on<LocaleToggled>(_onLocaleToggled);
    on<LocaleSet>(_onLocaleSet);
  }

  void _onLocaleToggled(LocaleToggled event, Emitter<Locale> emit) {
    emit(state.languageCode == 'en' ? const Locale('ar') : const Locale('en'));
  }

  void _onLocaleSet(LocaleSet event, Emitter<Locale> emit) {
    if (event.locale == state) return;
    emit(event.locale);
  }
}
