import 'package:equatable/equatable.dart';
import 'package:core/core.dart';

class StylistProfileState extends Equatable {
  const StylistProfileState({
    this.barberId,
    this.isLoading = false,
    this.profile,
    this.currencies = const [],
    this.currencyFailed = false,
    this.error,
  });

  final String? barberId;
  final bool isLoading;
  final BarberProfileDto? profile;
  final List<CurrencyDto> currencies;
  final bool currencyFailed;
  final Object? error;

  StylistProfileState copyWith({
    String? barberId,
    bool? isLoading,
    BarberProfileDto? profile,
    bool clearProfile = false,
    List<CurrencyDto>? currencies,
    bool? currencyFailed,
    Object? error,
    bool clearError = false,
  }) {
    return StylistProfileState(
      barberId: barberId ?? this.barberId,
      isLoading: isLoading ?? this.isLoading,
      profile: clearProfile ? null : profile ?? this.profile,
      currencies: currencies ?? this.currencies,
      currencyFailed: currencyFailed ?? this.currencyFailed,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        barberId,
        isLoading,
        profile,
        currencies,
        currencyFailed,
        error,
      ];
}
