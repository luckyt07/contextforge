import 'package:ai_assistant_app/api_endpoints.dart';
import 'package:ai_assistant_app/core/models/response/user.dart';
import 'package:ai_assistant_app/core/network/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthRepository {
  final ApiService apiService;

  AuthResponse? _currentAuth;

  AuthRepository(this.apiService);

  // SharedPreferences keys
  static const _keyToken = 'auth_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyTokenType = 'auth_token_type';
  static const _keyUserId = 'auth_user_id';
  static const _keyUsername = 'auth_username';
  static const _keyFirstname = 'auth_firstname';
  static const _keyLastname = 'auth_lastname';
  static const _keyEmail = 'auth_email';
  static const _keyIsActive = 'auth_is_active';
  static const _keyRole = 'auth_role';
  static const _keyCreatedAt = 'auth_created_at';
  static const _keyUpdatedAt = 'auth_updated_at';

  AuthResponse? get currentAuth => _currentAuth;

  UserInfo? get currentUser => _currentAuth?.user;

  String? get currentToken => _currentAuth?.token.accessToken;

  bool get isAuthenticated => _currentAuth != null;

  Future<UserInfo> registerUser({
    String? username,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
  }) async {
    final Map<String, dynamic> data = {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      // These names match the FastAPI UserCreate schema.
      if (firstName != null) 'firstname': firstName,
      if (lastName != null) 'lastname': lastName,
    };

    final response = data.isNotEmpty
        ? await apiService.post(ApiEndPoints.register, data: data)
        : await apiService.get(ApiEndPoints.register);

    final userInfo = UserInfo.fromJson(response.data);
    return userInfo;
  }

  Future<AuthResponse> loginUser({String? username, String? password}) async {
    final Map<String, dynamic> data = {
      if (username != null) 'username': username,
      if (password != null) 'password': password,
    };

    final response = data.isNotEmpty
        ? await apiService.post(ApiEndPoints.login, data: data)
        : await apiService.get(ApiEndPoints.login);

    _currentAuth = AuthResponse.fromJson(response.data);
    await _saveToPrefs(_currentAuth!);
    return _currentAuth!;
  }

  Future<UserInfo> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final response = await apiService.patch<Map<String, dynamic>>(
      ApiEndPoints.profile,
      data: {'firstname': firstName, 'lastname': lastName},
    );
    final user = UserInfo.fromJson(response.data!);
    await updateCurrentUser(user);
    return user;
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await apiService.post(
      ApiEndPoints.changePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_confirm_password': confirmPassword,
      },
    );
  }

  Future<void> logout() async {
    final refreshToken = _currentAuth?.token.refreshToken;
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await apiService.post(
          ApiEndPoints.logout,
          data: jsonEncode(refreshToken),
        );
      }
    } finally {
      _currentAuth = null;
      await _clearPrefs();
    }
  }

  Future<void> updateCurrentUser(UserInfo updatedUser) async {
    if (_currentAuth != null) {
      _currentAuth = AuthResponse(
        user: updatedUser,
        token: _currentAuth!.token,
      );
      await _saveToPrefs(_currentAuth!);
    }
  }

  // ─── SharedPreferences helpers ───────────────────────────────────────────

  Future<void> _saveToPrefs(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, auth.token.accessToken);
    await prefs.setString(_keyRefreshToken, auth.token.refreshToken);
    await prefs.setString(_keyTokenType, auth.token.tokenType);
    await prefs.setInt(_keyUserId, auth.user.id);
    await prefs.setString(_keyUsername, auth.user.username);
    await prefs.setString(_keyFirstname, auth.user.firstName);
    await prefs.setString(_keyLastname, auth.user.lastName);
    await prefs.setString(_keyEmail, auth.user.email);
    await prefs.setBool(_keyIsActive, auth.user.isActive);
    await prefs.setString(_keyRole, auth.user.role);
    await prefs.setString(_keyCreatedAt, auth.user.createdAt.toIso8601String());
    await prefs.setString(_keyUpdatedAt, auth.user.updatedAt.toIso8601String());
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyTokenType);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyFirstname);
    await prefs.remove(_keyLastname);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyIsActive);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyCreatedAt);
    await prefs.remove(_keyUpdatedAt);
  }

  /// Reads persisted credentials and restores [_currentAuth].
  /// Returns `true` if a valid session was restored.
  Future<bool> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final refreshToken = prefs.getString(_keyRefreshToken);
    final tokenType = prefs.getString(_keyTokenType);
    final userId = prefs.getInt(_keyUserId);
    final username = prefs.getString(_keyUsername);
    final email = prefs.getString(_keyEmail);

    // All required fields must be present to restore the session
    if (token == null ||
        refreshToken == null ||
        tokenType == null ||
        userId == null ||
        username == null ||
        email == null) {
      return false;
    }

    _currentAuth = AuthResponse(
      token: TokenResponse(
        accessToken: token,
        refreshToken: refreshToken,
        tokenType: tokenType,
      ),
      user: UserInfo(
        id: userId,
        username: username,
        email: email,
        firstName: prefs.getString(_keyFirstname) ?? "",
        lastName: prefs.getString(_keyLastname) ?? "",
        isActive: prefs.getBool(_keyIsActive) ?? true,
        role: prefs.getString(_keyRole) ?? '',
        createdAt:
            DateTime.tryParse(prefs.getString(_keyCreatedAt) ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(prefs.getString(_keyUpdatedAt) ?? '') ??
            DateTime.now(),
      ),
    );
    return true;
  }
}
