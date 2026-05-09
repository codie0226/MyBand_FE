import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_providers.dart';
import '../models/band_models.dart';

class EventRepository {
  final ApiClient _api;

  EventRepository(this._api);

  /// `GET /bands/:bandId/events`
  /// [from], [to]: YYYY-MM-DD 형식 날짜 필터 (optional).
  Future<List<BandEvent>> getEvents(
    String bandId, {
    String? from,
    String? to,
  }) async {
    final res = await _api.dio.get<List<dynamic>>(
      '/bands/$bandId/events',
      queryParameters: {
        'from': ?from,
        'to': ?to,
      },
    );
    return res.data!
        .map((e) => BandEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `POST /bands/:bandId/events` — 일정 생성.
  Future<BandEvent> createEvent(String bandId, BandEvent event) async {
    final res = await _api.dio.post<Map<String, dynamic>>(
      '/bands/$bandId/events',
      data: event.toCreateJson(),
    );
    return BandEvent.fromJson(res.data!);
  }

  /// `PATCH /bands/:bandId/events/:eventId` — 일정 수정.
  Future<BandEvent> updateEvent(
      String bandId, String eventId, BandEvent event) async {
    final res = await _api.dio.patch<Map<String, dynamic>>(
      '/bands/$bandId/events/$eventId',
      data: event.toUpdateJson(),
    );
    return BandEvent.fromJson(res.data!);
  }

  /// `DELETE /bands/:bandId/events/:eventId` — 일정 삭제.
  Future<void> deleteEvent(String bandId, String eventId) async {
    await _api.dio.delete('/bands/$bandId/events/$eventId');
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(apiClientProvider));
});
