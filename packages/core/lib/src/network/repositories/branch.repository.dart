import 'package:core/core.dart';

abstract class BranchRepository {
  Future<FloorPlanDto> getFloorPlan(String branchId);
}

class DioBranchRepository implements BranchRepository {
  const DioBranchRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<FloorPlanDto> getFloorPlan(String branchId) {
    return _apiClient.get<FloorPlanDto>(
      BranchEndpoints.floorPlan.replaceFirst('{branch}', branchId),
      parser: (json) => FloorPlanDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
