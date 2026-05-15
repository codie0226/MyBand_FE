import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_providers.dart';
import '../models/band_models.dart';

class BandMemberRepository {
  final ApiClient _api;

  BandMemberRepository(this._api);

  /// `GET /bands/:bandId/members`
  Future<List<Member>> getMembers(String bandId) async {
    final res = await _api.dio.get<List<dynamic>>('/bands/$bandId/members');
    return res.data!
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `PATCH /bands/:bandId/members/:userId` — 멤버 역할/파트 수정.
  Future<Member> updateMemberRole({
    required String bandId,
    required String userId,
    required BandMemberRole role,
  }) async {
    final res = await _api.dio.patch<Map<String, dynamic>>(
      '/bands/$bandId/members/$userId',
      data: {'role': role.wireName},
    );
    return Member.fromJson(res.data!);
  }

  /// `DELETE /bands/:bandId/members/:userId` — 밴드 탈퇴/강퇴.
  Future<void> removeMember({
    required String bandId,
    required String userId,
  }) async {
    await _api.dio.delete('/bands/$bandId/members/$userId');
  }
}

final bandMemberRepositoryProvider = Provider<BandMemberRepository>((ref) {
  return BandMemberRepository(ref.watch(apiClientProvider));
});
