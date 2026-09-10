import 'package:equatable/equatable.dart';
import 'package:core/core.dart';

class BranchDetailState extends Equatable {
  const BranchDetailState({
    this.branchId,
    this.isLoading = false,
    this.detail,
    this.plan,
    this.error,
    this.planFailed = false,
    this.selectedChairId,
    this.selectedServiceIds = const [],
    this.selectedTime,
    this.isSubmitting = false,
    this.submitError,
    this.succeeded = false,
  });

  final String? branchId;
  final bool isLoading;
  final BranchDetailDto? detail;
  final FloorPlanDto? plan;
  final Object? error;
  final bool planFailed;
  final String? selectedChairId;
  final List<String> selectedServiceIds;
  final DateTime? selectedTime;
  final bool isSubmitting;
  final Object? submitError;
  final bool succeeded;

  bool get canSubmit =>
      selectedChairId != null && selectedTime != null && !isSubmitting;

  BranchDetailState copyWith({
    String? branchId,
    bool? isLoading,
    BranchDetailDto? detail,
    FloorPlanDto? plan,
    Object? error,
    bool clearError = false,
    bool? planFailed,
    String? selectedChairId,
    bool clearChair = false,
    List<String>? selectedServiceIds,
    DateTime? selectedTime,
    bool clearTime = false,
    bool? isSubmitting,
    Object? submitError,
    bool clearSubmitError = false,
    bool? succeeded,
  }) {
    return BranchDetailState(
      branchId: branchId ?? this.branchId,
      isLoading: isLoading ?? this.isLoading,
      detail: detail ?? this.detail,
      plan: plan ?? this.plan,
      error: clearError ? null : error ?? this.error,
      planFailed: planFailed ?? this.planFailed,
      selectedChairId:
          clearChair ? null : selectedChairId ?? this.selectedChairId,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      selectedTime: clearTime ? null : selectedTime ?? this.selectedTime,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError:
          clearSubmitError ? null : submitError ?? this.submitError,
      succeeded: succeeded ?? this.succeeded,
    );
  }

  @override
  List<Object?> get props => [
        branchId,
        isLoading,
        detail,
        plan,
        error,
        planFailed,
        selectedChairId,
        selectedServiceIds,
        selectedTime,
        isSubmitting,
        submitError,
        succeeded,
      ];
}
