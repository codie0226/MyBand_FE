/// `LoginResponse.user` — `AuthUser` 스키마.
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}

/// `POST /auth/google` 응답.
class LoginResponse {
  final String accessToken;
  final AuthUser user;

  const LoginResponse({
    required this.accessToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// `GET /users/me`, `GET /auth/me` 응답.
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String? instrument;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.instrument,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      instrument: json['instrument'] as String?,
    );
  }
}
