import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_providers.dart';
import '../models/band_models.dart';

class BandRepository {
  final ApiClient _api;

  BandRepository(this._api);

  /// `GET /bands` — 내 소속 밴드 목록.
  Future<List<Band>> getBands() async {
    final res = await _api.dio.get<List<dynamic>>('/bands');
    return res.data!
        .map((e) => Band.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /bands/:bandId` — 밴드 상세 (members/events 미포함).
  Future<Band> getBand(String bandId) async {
    final res =
        await _api.dio.get<Map<String, dynamic>>('/bands/$bandId');
    return Band.fromJson(res.data!);
  }
}

final bandRepositoryProvider = Provider<BandRepository>((ref) {
  return BandRepository(ref.watch(apiClientProvider));
});
