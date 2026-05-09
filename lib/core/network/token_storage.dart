import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 액세스 토큰 안전 저장소.
class TokenStorage {
  static const _accessTokenKey = 'auth.accessToken';

  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}
