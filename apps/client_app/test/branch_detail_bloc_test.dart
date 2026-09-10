import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_app/src/features/booking/branch_detail.bloc.dart';
import 'package:client_app/src/features/booking/branch_detail.event.dart';
import 'package:client_app/src/features/booking/branch_detail.state.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeExploreRepository explore;
  late FakeBranchRepository branches;
  late FakeBookingRepository bookings;

  setUp(() {
    explore = FakeExploreRepository();
    branches = FakeBranchRepository();
    bookings = FakeBookingRepository();
  });

  BranchDetailBloc bloc() => BranchDetailBloc(explore, branches, bookings);

  group('BranchDetailStarted', () {
    blocTest<BranchDetailBloc, BranchDetailState>(
      'loads detail and floor plan together',
      build: bloc,
      act: (bloc) => bloc.add(const BranchDetailStarted('1')),
      verify: (bloc) {
        expect(bloc.state.detail?.name, 'Branch 1');
        expect(bloc.state.plan?.chairs, hasLength(2));
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<BranchDetailBloc, BranchDetailState>(
      'detail failure records the error',
      build: bloc,
      setUp: () => explore.error = offline(),
      act: (bloc) => bloc.add(const BranchDetailStarted('1')),
      verify: (bloc) {
        expect(bloc.state.detail, isNull);
        expect(bloc.state.error, isA<NetworkException>());
      },
    );

    blocTest<BranchDetailBloc, BranchDetailState>(
      'floor plan failure keeps the detail with a plan flag',
      build: bloc,
      setUp: () => branches.error = offline(),
      act: (bloc) => bloc.add(const BranchDetailStarted('1')),
      verify: (bloc) {
        expect(bloc.state.detail?.name, 'Branch 1');
        expect(bloc.state.plan, isNull);
        expect(bloc.state.planFailed, isTrue);
      },
    );
  });

  group('selection', () {
    BranchDetailState seeded() => BranchDetailState(
          branchId: '1',
          detail: testBranchDetail(),
          plan: testFloorPlan(),
        );

    blocTest<BranchDetailBloc, BranchDetailState>(
      'chair selection is recorded and submittable with a time',
      build: bloc,
      seed: seeded,
      act: (bloc) {
        bloc
          ..add(const BranchDetailChairSelected('chair-1'))
          ..add(
            BranchDetailTimeChanged(DateTime.utc(2026, 9, 10, 14, 30)),
          );
      },
      verify: (bloc) {
        expect(bloc.state.selectedChairId, 'chair-1');
        expect(bloc.state.canSubmit, isTrue);
      },
    );

    blocTest<BranchDetailBloc, BranchDetailState>(
      'services selection is recorded',
      build: bloc,
      seed: seeded,
      act: (bloc) =>
          bloc.add(const BranchDetailServicesChanged(['service-1'])),
      verify: (bloc) {
        expect(bloc.state.selectedServiceIds, ['service-1']);
      },
    );
  });

  group('BranchDetailBookingSubmitted', () {
    BranchDetailState ready() => BranchDetailState(
          branchId: '1',
          detail: testBranchDetail(),
          plan: testFloorPlan(),
          selectedChairId: 'chair-1',
          selectedServiceIds: const ['service-1'],
          selectedTime: DateTime.utc(2026, 9, 10, 14, 30),
        );

    blocTest<BranchDetailBloc, BranchDetailState>(
      'successful booking marks succeeded with the chair barber',
      build: bloc,
      seed: ready,
      act: (bloc) => bloc.add(const BranchDetailBookingSubmitted()),
      verify: (bloc) {
        expect(bookings.createCalls, 1);
        expect(bloc.state.succeeded, isTrue);
      },
    );

    blocTest<BranchDetailBloc, BranchDetailState>(
      'conflict records the submit error without succeeding',
      build: bloc,
      seed: ready,
      setUp: () => bookings.createError = const ApiException(
        statusCode: 409,
        code: 'CONFLICT',
        message: 'booking::messages.chair_not_available',
      ),
      act: (bloc) => bloc.add(const BranchDetailBookingSubmitted()),
      verify: (bloc) {
        expect(bloc.state.succeeded, isFalse);
        expect(
          (bloc.state.submitError as ApiException).statusCode,
          409,
        );
      },
    );

    blocTest<BranchDetailBloc, BranchDetailState>(
      'submit without a chair is a no-op',
      build: bloc,
      seed: () => BranchDetailState(
        branchId: '1',
        detail: testBranchDetail(),
        plan: testFloorPlan(),
        selectedTime: DateTime.utc(2026, 9, 10, 14, 30),
      ),
      act: (bloc) => bloc.add(const BranchDetailBookingSubmitted()),
      expect: () => [],
      verify: (_) {
        expect(bookings.createCalls, 0);
      },
    );
  });
}
