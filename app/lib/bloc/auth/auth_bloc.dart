import 'package:ai_assistant_app/core/models/response/user.dart';
import 'package:ai_assistant_app/core/repo/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(const AuthState()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthUpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Attempt to restore a previously saved session from SharedPreferences
    await repository.tryRestoreSession();

    if (repository.isAuthenticated && repository.currentAuth != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          authResponse: repository.currentAuth,
        ),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loginLoading, clearError: true));

    try {
      final authResponse = await repository.loginUser(
        username: event.username,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          authResponse: authResponse,
          successMessage: 'Welcome back!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.registerLoading, clearError: true));

    try {
      final userInfo = await repository.registerUser(
        username: event.username,
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(
        state.copyWith(
          status: AuthStatus.registered,
          registeredUser: userInfo,
          successMessage: 'Account created! Please sign in.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await repository.logout();
    } catch (_) {
      // Local credentials are cleared by the repository even when the server
      // cannot be reached, so the user can always leave this device.
    }
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    await repository.updateCurrentUser(event.updatedUser);
    if (state.authResponse != null) {
      final updatedAuth = AuthResponse(
        user: event.updatedUser,
        token: state.authResponse!.token,
      );
      emit(
        state.copyWith(
          authResponse: updatedAuth,
          registeredUser: event.updatedUser,
        ),
      );
    } else {
      emit(state.copyWith(registeredUser: event.updatedUser));
    }
  }
}
