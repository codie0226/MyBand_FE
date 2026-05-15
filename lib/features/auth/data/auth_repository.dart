import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/network/token_storage.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _tokenStorage;

  AuthRepository(this._api, this._tokenStorage);

  /// `POST /auth/google` — Google 토큰으로 서버 로그인 + JWT 저장.
  ///
  /// `idToken` 또는 `accessToken` 중 최소 하나는 필수.
  /// 웹은 `access_token`만 받을 수 있으므로(google_sign_in_web 한계),
  /// 모바일은 `idToken` 우선, 웹은 `accessToken`을 사용.
  Future<LoginResponse> loginWithGoogle({
    String? idToken,
    String? accessToken,
  }) async {
    assert(
      idToken != null || accessToken != null,
      'idToken 또는 accessToken 중 하나는 필수',
    );
    final data = <String, dynamic>{};
    if (idToken != null) data['idToken'] = idToken;
    if (accessToken != null) data['accessToken'] = accessToken;

    final res = await _api.dio.post<Map<String, dynamic>>(
      '/auth/google',
      data: data,
    );
    final login = LoginResponse.fromJson(res.data!);
    await _tokenStorage.writeAccessToken(login.accessToken);
    return login;
  }

  /// `POST /auth/logout` — 서버 측 무효화 + 로컬 토큰 삭제.
  /// 서버 호출 실패해도 로컬 토큰은 항상 삭제한다.
  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {
      // 로그아웃 실패해도 로컬은 정리
    }
    await _tokenStorage.clear();
  }

  /// `GET /auth/me` — 현재 로그인 사용자 프로필.
  Future<UserProfile> me() async {
    final res = await _api.dio.get<Map<String, dynamic>>('/auth/me');
    return UserProfile.fromJson(res.data!);
  }

  /// 저장된 JWT 존재 여부 확인 (앱 시작 시 자동 로그인 판단용).
  Future<bool> hasStoredToken() async {
    final token = await _tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 저장된 JWT가 실제로 서버에서 아직 유효한지 확인한다.
  ///
  /// 토큰 문자열만 보고 로그인 상태를 복원하면, 백엔드 JWT_SECRET 변경이나
  /// 만료된 토큰 때문에 첫 보호 API 호출에서 401이 반복될 수 있다.
  Future<bool> hasValidStoredToken() async {
    if (!await hasStoredToken()) return false;

    try {
      await me();
      return true;
    } on DioException catch (e) {
      if (e.error is UnauthorizedException) {
        await _tokenStorage.clear();
        return false;
      }
      return false;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final storage = ref.watch(tokenStorageProvider);
  return AuthRepository(api, storage);
});
