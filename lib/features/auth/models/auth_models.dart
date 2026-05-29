/// `LoginResponse.user` — `AuthUser` 스키마.
class AuthUser {
  final String id;
  final String name;
  final String? nickname;
  final String email;
  final String? profileImageUrl;
  final bool onboardingCompleted;

  const AuthUser({
    required this.id,
    required this.name,
    this.nickname,
    required this.email,
    this.profileImageUrl,
    this.onboardingCompleted = false,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final id = _readString(json, const ['id', 'userId', '_id']);
    final email = _readString(json, const ['email']);
    final name =
        _readString(json, const ['name', 'displayName', 'username']) ??
        email?.split('@').first ??
        'User';

    return AuthUser(
      id: id ?? email ?? '',
      name: name,
      nickname: _readString(json, const ['nickname']),
      email: email ?? '',
      profileImageUrl: _readString(json, const [
        'profileImageUrl',
        'profile_image_url',
        'picture',
        'photoUrl',
      ]),
      onboardingCompleted: (json['onboardingCompleted'] as bool?) ?? false,
    );
  }
}

/// `POST /auth/google` 응답.
class LoginResponse {
  final String accessToken;
  final AuthUser user;

  const LoginResponse({required this.accessToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final body = _unwrapData(json);
    final accessToken = _readString(body, const [
      'accessToken',
      'access_token',
      'token',
      'jwt',
    ]);
    final userJson = body['user'] ?? body['member'] ?? body['profile'];

    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('Missing access token in login response.');
    }
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Missing user in login response.');
    }

    return LoginResponse(
      accessToken: accessToken,
      user: AuthUser.fromJson(userJson),
    );
  }
}

/// `GET /users/me`, `GET /auth/me` 응답.
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? nickname;
  final String? profileImageUrl;
  final String? instrument;
  final bool onboardingCompleted;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.nickname,
    this.profileImageUrl,
    this.instrument,
    this.onboardingCompleted = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final body = _unwrapData(json);
    final email = _readString(body, const ['email']);
    final name =
        _readString(body, const ['name', 'displayName', 'username']) ??
        email?.split('@').first ??
        'User';

    return UserProfile(
      id: _readString(body, const ['id', 'userId', '_id']) ?? email ?? '',
      email: email ?? '',
      name: name,
      nickname: _readString(body, const ['nickname']),
      profileImageUrl: _readString(body, const [
        'profileImageUrl',
        'profile_image_url',
        'picture',
        'photoUrl',
      ]),
      instrument: _readString(body, const ['instrument']),
      onboardingCompleted: (body['onboardingCompleted'] as bool?) ?? false,
    );
  }
}

Map<String, dynamic> _unwrapData(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map<String, dynamic>) return data;
  return json;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
