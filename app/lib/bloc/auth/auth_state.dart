part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loginLoading,
  registerLoading,
  authenticated,
  registered,
  unauthenticated,
  failure,
}

final class AuthState extends Equatable {
  final AuthStatus status;
  final AuthResponse? authResponse;
  final UserInfo? registeredUser;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authResponse,
    this.registeredUser,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoginLoading => status == AuthStatus.loginLoading;
  bool get isRegisterLoading => status == AuthStatus.registerLoading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isRegistered => status == AuthStatus.registered;

  UserInfo? get currentUser => authResponse?.user ?? registeredUser;
  String? get accessToken => authResponse?.token.accessToken;

  AuthState copyWith({
    AuthStatus? status,
    AuthResponse? authResponse,
    UserInfo? registeredUser,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      authResponse: authResponse ?? this.authResponse,
      registeredUser: registeredUser ?? this.registeredUser,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    authResponse,
    registeredUser,
    errorMessage,
    successMessage,
  ];
}
