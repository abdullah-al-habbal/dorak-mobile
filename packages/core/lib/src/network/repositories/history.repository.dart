import 'package:core/core.dart';

abstract class HistoryRepository {
  Future<PaginatedData<ServiceHistoryDto>> getHistory({
    int page = 1,
    int perPage = 15,
  });

  Future<BookingDto> rebookFromHistory(String historyId, DateTime timeSlot);
}

class DioHistoryRepository implements HistoryRepository {
  const DioHistoryRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedData<ServiceHistoryDto>> getHistory({
    int page = 1,
    int perPage = 15,
  }) {
    return _apiClient.getPaginated<ServiceHistoryDto>(
      HistoryEndpoints.history,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      itemParser: (json) => ServiceHistoryDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<BookingDto> rebookFromHistory(String historyId, DateTime timeSlot) {
    final slot = timeSlot.toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    final formatted =
        '${slot.year}-${two(slot.month)}-${two(slot.day)} ${two(slot.hour)}:${two(slot.minute)}:${two(slot.second)}';
    return _apiClient.post<BookingDto>(
      HistoryEndpoints.rebookFromHistory.replaceFirst('{history}', historyId),
      data: {'time_slot': formatted},
      parser: (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }
}