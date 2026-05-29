// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// JWT access token storage for Flutter web.
///
/// S3 static website endpoints are served over plain HTTP, where WebCrypto is
/// unavailable. `flutter_secure_storage_web` relies on that API, so web uses
/// localStorage instead.
class TokenStorage {
  static const _accessTokenKey = 'auth.accessToken';

  TokenStorage();

  Future<String?> readAccessToken() async {
    return html.window.localStorage[_accessTokenKey];
  }

  Future<void> writeAccessToken(String token) async {
    html.window.localStorage[_accessTokenKey] = token;
  }

  Future<void> clear() async {
    html.window.localStorage.remove(_accessTokenKey);
  }
}
