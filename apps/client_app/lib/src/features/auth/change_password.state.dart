import 'package:equatable/equatable.dart';

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.isSubmitting = false,
    this.succeeded = false,
    this.error,
  });

  final bool isSubmitting;
  final bool succeeded;
  final Object? error;

  ChangePasswordState copyWith({
    bool? isSubmitting,
    bool? succeeded,
    Object? error,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      succeeded: succeeded ?? this.succeeded,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, succeeded, error];
}
