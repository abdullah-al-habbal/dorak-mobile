import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client_app/src/features/booking/branch_detail.event.dart';
import 'package:client_app/src/features/booking/branch_detail.state.dart';

class BranchDetailBloc
    extends Bloc<BranchDetailEvent, BranchDetailState> {
  BranchDetailBloc(
    this._explore,
    this._branches,
    this._bookings,
  ) : super(const BranchDetailState()) {
    on<BranchDetailStarted>(_onStarted);
    on<BranchDetailChairSelected>(_onChairSelected);
    on<BranchDetailServicesChanged>(_onServicesChanged);
    on<BranchDetailTimeChanged>(_onTimeChanged);
    on<BranchDetailBookingSubmitted>(_onSubmitted);
    on<BranchDetailRetried>(_onRetried);
  }

  final ExploreRepository _explore;
  final BranchRepository _branches;
  final BookingRepository _bookings;

  Future<void> _onStarted(
    BranchDetailStarted event,
    Emitter<BranchDetailState> emit,
  ) async {
    emit(
      const BranchDetailState().copyWith(
        branchId: event.branchId,
        isLoading: true,
      ),
    );
    try {
      final detail = await _explore.getBranchDetail(event.branchId);
      if (emit.isDone) return;
      FloorPlanDto? plan;
      var planFailed = false;
      try {
        plan = await _branches.getFloorPlan(event.branchId);
      } catch (_) {
        planFailed = true;
      }
      if (emit.isDone) return;
      emit(
        state.copyWith(
          isLoading: false,
          detail: detail,
          plan: plan,
          planFailed: planFailed,
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

  void _onChairSelected(
    BranchDetailChairSelected event,
    Emitter<BranchDetailState> emit,
  ) {
    if (event.chairId == null) {
      emit(state.copyWith(clearChair: true, clearSubmitError: true));
    } else {
      emit(
        state.copyWith(
          selectedChairId: event.chairId,
          clearSubmitError: true,
        ),
      );
    }
  }

  void _onServicesChanged(
    BranchDetailServicesChanged event,
    Emitter<BranchDetailState> emit,
  ) {
    emit(
      state.copyWith(
        selectedServiceIds: List<String>.unmodifiable(event.serviceIds),
        clearSubmitError: true,
      ),
    );
  }

  void _onTimeChanged(
    BranchDetailTimeChanged event,
    Emitter<BranchDetailState> emit,
  ) {
    if (event.time == null) {
      emit(state.copyWith(clearTime: true, clearSubmitError: true));
    } else {
      emit(
        state.copyWith(
          selectedTime: event.time,
          clearSubmitError: true,
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    BranchDetailBookingSubmitted event,
    Emitter<BranchDetailState> emit,
  ) async {
    final chairId = state.selectedChairId;
    final time = state.selectedTime;
    if (chairId == null || time == null || state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));
    try {
      final barberId = _barberForChair(state.plan, chairId);
      await _bookings.createBooking(
        chairId: chairId,
        barberId: barberId,
        timeSlot: time,
        serviceIds:
            state.selectedServiceIds.isEmpty ? null : state.selectedServiceIds,
      );
      if (emit.isDone) return;
      emit(state.copyWith(isSubmitting: false, succeeded: true));
    } catch (error) {
      if (emit.isDone) return;
      emit(state.copyWith(isSubmitting: false, submitError: error));
    }
  }

  Future<void> _onRetried(
    BranchDetailRetried event,
    Emitter<BranchDetailState> emit,
  ) async {
    final branchId = state.branchId;
    if (branchId == null) return;
    await _onStarted(BranchDetailStarted(branchId), emit);
  }

  String? _barberForChair(FloorPlanDto? plan, String chairId) {
    final chairs = plan?.chairs ?? const <FloorChairDto>[];
    for (final chair in chairs) {
      if (chair.id == chairId) return chair.barber?.id;
    }
    return null;
  }
}
