import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_providers.dart';
import '../../auth/models/auth_models.dart';

class OnboardingBandInput {
  final String name;
  final String? genre;
  final String? description;
  final String? iconUrl;

  const OnboardingBandInput({
    required this.name,
    this.genre,
    this.description,
    this.iconUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (genre?.isNotEmpty == true) 'genre': genre,
      if (description?.isNotEmpty == true) 'description': description,
      if (iconUrl?.isNotEmpty == true) 'iconUrl': iconUrl,
    };
  }
}

class UserRepository {
  final ApiClient _api;

  UserRepository(this._api);

  /// `GET /users/me`
  Future<UserProfile> getProfile() async {
    final res = await _api.dio.get<dynamic>('/users/me');
    return UserProfile.fromJson(_asJsonMap(res.data, '/users/me'));
  }

  /// `PATCH /users/me`
  Future<UserProfile> updateProfile({
    String? name,
    String? nickname,
    String? instrument,
  }) async {
    final res = await _api.dio.patch<dynamic>(
      '/users/me',
      data: {'name': ?name, 'nickname': ?nickname, 'instrument': ?instrument},
    );
    return UserProfile.fromJson(_asJsonMap(res.data, '/users/me'));
  }

  Future<UserProfile> completeOnboarding({
    required String nickname,
    required String instrument,
    String? inviteCode,
    OnboardingBandInput? band,
  }) async {
    final res = await _api.dio.post<dynamic>(
      '/users/me/onboarding',
      data: {
        'nickname': nickname,
        'instrument': instrument,
        if (inviteCode?.isNotEmpty == true) 'inviteCode': inviteCode,
        if (band != null) 'band': band.toJson(),
      },
    );
    return UserProfile.fromJson(_asJsonMap(res.data, '/users/me/onboarding'));
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

Map<String, dynamic> _asJsonMap(Object? data, String endpoint) {
  if (data is Map<String, dynamic>) return data;
  throw ApiException(message: 'Invalid response from $endpoint');
}
