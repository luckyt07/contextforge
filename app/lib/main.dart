import 'package:ai_assistant_app/api_endpoints.dart';
import 'package:ai_assistant_app/app.dart';
import 'package:ai_assistant_app/core/repo/auth_repository.dart';
import 'package:ai_assistant_app/core/repo/message_repository.dart';
import 'package:ai_assistant_app/core/network/api_service.dart';
import 'package:ai_assistant_app/core/repo/project_repository.dart';
import 'package:ai_assistant_app/core/services/app_preferences.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  final apiService = ApiService(
    baseUrl: ApiEndPoints.baseURL,
    enableLogging: true,
    tokenProvider: () async => AppPreferences.getString('auth_token'),
    refreshTokenProvider: () async =>
        AppPreferences.getString('auth_refresh_token'),
    onTokensRefreshed: (accessToken, refreshToken) async {
      await AppPreferences.setString('auth_token', accessToken);
      await AppPreferences.setString('auth_refresh_token', refreshToken);
    },
    onRefreshFailure: () async {
      await AppPreferences.remove('auth_token');
      await AppPreferences.remove('auth_refresh_token');
    },
  );
  final messageRepo = MessageRepository(apiService);
  final projectRepo = ProjectRepository(apiService);
  final authRepo = AuthRepository(apiService);
  runApp(
    App(
      repository: apiService,
      messageRepo: messageRepo,
      projectRepo: projectRepo,
      authRepo: authRepo,
    ),
  );
}
