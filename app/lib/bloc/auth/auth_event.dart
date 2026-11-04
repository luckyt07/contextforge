part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

final class AuthLoginEvent extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginEvent({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

final class AuthRegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  const AuthRegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [username, email, password, firstName, lastName];
}

final class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

final class AuthUpdateProfileEvent extends AuthEvent {
  final UserInfo updatedUser;

  const AuthUpdateProfileEvent(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}
