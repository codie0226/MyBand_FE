import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_providers.dart';
import '../../auth/models/auth_models.dart';

class UserRepository {
  final ApiClient _api;

  UserRepository(this._api);

  /// `GET /users/me`
  Future<UserProfile> getProfile() async {
    final res = await _api.dio.get<Map<String, dynamic>>('/users/me');
    return UserProfile.fromJson(res.data!);
  }

  /// `PATCH /users/me`
  Future<UserProfile> updateProfile({
    String? name,
    String? instrument,
  }) async {
    final res = await _api.dio.patch<Map<String, dynamic>>(
      '/users/me',
      data: {
        'name': ?name,
        'instrument': ?instrument,
      },
    );
    return UserProfile.fromJson(res.data!);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});
