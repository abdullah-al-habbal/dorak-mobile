import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/stylist/stylist_profile.event.dart';
import 'package:client_app/src/features/stylist/stylist_profile.state.dart';

class StylistProfileBloc
    extends Bloc<StylistProfileEvent, StylistProfileState> {
  StylistProfileBloc(this._explore, this._currencies)
      : super(const StylistProfileState()) {
    on<StylistProfileStarted>(_onStarted);
    on<StylistProfileRetried>(_onRetried);
  }

  final ExploreRepository _explore;
  final CurrencyRepository _currencies;

  Future<void> _onStarted(
    StylistProfileStarted event,
    Emitter<StylistProfileState> emit,
  ) async {
    emit(
      const StylistProfileState().copyWith(
        barberId: event.barberId,
        isLoading: true,
      ),
    );
    try {
      final profile = await _explore.getBarberDetail(event.barberId);
      if (emit.isDone) return;
      List<CurrencyDto> currencies = const [];
      var currencyFailed = false;
      try {
        currencies = await _currencies.getCurrencies();
      } catch (_) {
        currencyFailed = true;
      }
      if (emit.isDone) return;
      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
          currencies: currencies,
          currencyFailed: currencyFailed,
        ),
      );
    } catch (error) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          isLoading: false,
          error: error,
        ),
      );
    }
  }

  Future<void> _onRetried(
    StylistProfileRetried event,
    Emitter<StylistProfileState> emit,
  ) async {
    final barberId = state.barberId;
    if (barberId == null) return;
    await _onStarted(StylistProfileStarted(barberId), emit);
  }
}
