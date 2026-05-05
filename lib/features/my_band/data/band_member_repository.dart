import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_providers.dart';
import '../models/band_models.dart';

class BandMemberRepository {
  final ApiClient _api;

  BandMemberRepository(this._api);

  /// `GET /bands/:bandId/members`
  Future<List<Member>> getMembers(String bandId) async {
    final res =
        await _api.dio.get<List<dynamic>>('/bands/$bandId/members');
    return res.data!
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final bandMemberRepositoryProvider =
    Provider<BandMemberRepository>((ref) {
  return BandMemberRepository(ref.watch(apiClientProvider));
});
