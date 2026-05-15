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
    final res = await _api.dio.get<Map<String, dynamic>>('/bands/$bandId');
    return Band.fromJson(res.data!);
  }

  /// `POST /bands` — 새 밴드 생성.
  Future<Band> createBand({
    required String name,
    String? genre,
    String? description,
    String? iconUrl,
  }) async {
    final res = await _api.dio.post<Map<String, dynamic>>(
      '/bands',
      data: {
        'name': name,
        if (genre?.isNotEmpty == true) 'genre': genre,
        if (description?.isNotEmpty == true) 'description': description,
        if (iconUrl?.isNotEmpty == true) 'iconUrl': iconUrl,
      },
    );
    return Band.fromJson(res.data!);
  }

  /// `PATCH /bands/:bandId` — 밴드 정보 수정.
  Future<Band> updateBand({
    required String bandId,
    required String name,
    String? genre,
    String? description,
    String? iconUrl,
  }) async {
    final res = await _api.dio.patch<Map<String, dynamic>>(
      '/bands/$bandId',
      data: {
        'name': name,
        'genre': genre,
        'description': description,
        'iconUrl': iconUrl,
      },
    );
    return Band.fromJson(res.data!);
  }

  /// `POST /bands/join` — 초대 코드로 밴드 가입.
  Future<Band> joinByInviteCode(String inviteCode) async {
    final res = await _api.dio.post<Map<String, dynamic>>(
      '/bands/join',
      data: {'inviteCode': inviteCode},
    );
    return Band.fromJson(res.data!);
  }
}

final bandRepositoryProvider = Provider<BandRepository>((ref) {
  return BandRepository(ref.watch(apiClientProvider));
});
