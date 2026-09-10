import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_dio.dart';

void main() {
  group('DioBranchRepository', () {
    test('getFloorPlan parses chairs with availability', () async {
      late RequestOptions captured;
      final fake = fakeDio(
        handler: (options) {
          captured = options;
          return jsonResponse(
            options,
            data: successEnvelope(
              data: {
                'branch_id': 'branch-1',
                'branch_name': 'Branch 1',
                'chairs': [
                  {
                    'id': 'chair-1',
                    'label': 'A',
                    'status': 'available',
                    'barber': {'id': 'barber-1', 'name': 'Karim'},
                  },
                  {'id': 'chair-2', 'label': 'B', 'status': 'occupied'},
                ],
              },
            ),
          );
        },
      );
      final repository = DioBranchRepository(clientWith(fake));

      final plan = await repository.getFloorPlan('branch-1');

      expect(captured.path, '/branches/branch-1/floor-plan');
      expect(plan.branchName, 'Branch 1');
      expect(plan.chairs, hasLength(2));
      expect(plan.chairs.first.status, 'available');
      expect(plan.chairs.first.barber?.name, 'Karim');
      expect(plan.chairs.last.status, 'occupied');
      expect(fake.callCount, 1);
    });
  });
}
