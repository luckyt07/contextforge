import 'package:ai_assistant_app/bloc/auth/auth_bloc.dart';
import 'package:ai_assistant_app/bloc/project/project_bloc.dart';
import 'package:ai_assistant_app/core/repo/auth_repository.dart';
import 'package:ai_assistant_app/core/repo/message_repository.dart';
import 'package:ai_assistant_app/core/network/api_service.dart';
import 'package:ai_assistant_app/core/repo/project_repository.dart';
import 'package:ai_assistant_app/features/auth/screens/login_screen.dart';
import 'package:ai_assistant_app/features/auth/screens/signup_screen.dart';
import 'package:ai_assistant_app/features/profile/screens/profile_screen.dart';
import 'package:ai_assistant_app/features/projects/screens/projects_screen.dart';
import 'package:ai_assistant_app/common_widgets/project_creation_status_bar.dart';
import 'package:ai_assistant_app/theme/app_theme.dart';
import 'package:ai_assistant_app/theme/editorial_theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatefulWidget {
  final ApiService repository;
  final MessageRepository messageRepo;
  final ProjectRepository projectRepo;
  final AuthRepository authRepo;

  const App({
    required this.repository,
    required this.messageRepo,
    required this.projectRepo,
    required this.authRepo,
    super.key,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  late final AppThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = AppThemeController();
    _themeController.attachTicker(this);
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditorialThemeScope(
      controller: _themeController,
      child: ListenableBuilder(
        listenable: _themeController,
        builder: (context, _) {
          ThemeMode flutterThemeMode;
          switch (_themeController.mode) {
            case AppThemeMode.light:
              flutterThemeMode = ThemeMode.light;
              break;
            case AppThemeMode.dark:
              flutterThemeMode = ThemeMode.dark;
              break;
            case AppThemeMode.system:
              flutterThemeMode = ThemeMode.system;
              break;
          }

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider.value(value: widget.repository),
              RepositoryProvider.value(value: widget.messageRepo),
              RepositoryProvider.value(value: widget.projectRepo),
              RepositoryProvider.value(value: widget.authRepo),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (context) =>
                      AuthBloc(context.read<AuthRepository>())
                        ..add(const AuthCheckStatusEvent()),
                ),
                BlocProvider<ProjectBloc>(
                  create: (context) =>
                      ProjectBloc(context.read<ProjectRepository>()),
                ),
              ],
              child: MaterialApp(
                title: 'AI Assistant',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: flutterThemeMode,
                themeAnimationDuration: const Duration(milliseconds: 350),
                themeAnimationCurve: Curves.easeInOutCubic,
                builder: (context, child) => Stack(
                  fit: StackFit.expand,
                  children: [
                    ?child,
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ProjectCreationStatusBar(),
                    ),
                  ],
                ),
                initialRoute: '/login',
                routes: {
                  '/login': (_) => const LoginScreen(),
                  '/signup': (_) => const SignUpScreen(),
                  '/profile': (_) => const ProfileScreen(),
                  '/projects': (_) => const ProjectsScreen(),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
