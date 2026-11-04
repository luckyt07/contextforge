class UserInfo {
  final String username;
  final String email;
  final bool isActive;
  final String role;
  final String firstName;
  final String lastName;
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserInfo({
    required this.username,
    required this.email,
    required this.isActive,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      username: json['username'] as String,
      email: json['email'] as String,
      isActive: json['is_active'] as bool,
      firstName: json['firstname'] as String? ?? "",
      lastName: json['lastname'] as String? ?? "",
      role: json['role'] as String,
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'is_active': isActive,
      'role': role,
      'firstname': firstName,
      'lastname': lastName,
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}

class AuthResponse {
  final UserInfo user;
  final TokenResponse token;

  const AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      token: TokenResponse.fromJson(json['token'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token.toJson()};
  }
}
