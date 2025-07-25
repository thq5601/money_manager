import 'package:equatable/equatable.dart';
class LoginPasswordVisibilityChanged extends LoginEvent {
  final bool isVisible;
  const LoginPasswordVisibilityChanged(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
}

class LoginRememberMeChanged extends LoginEvent {
  final bool rememberMe;
  const LoginRememberMeChanged(this.rememberMe);

  @override
  List<Object?> get props => [rememberMe];
}


abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  final String email;
  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends LoginEvent {}

class LoginForgotPassword extends LoginEvent {
  final String email;
  const LoginForgotPassword(this.email);

  @override
  List<Object?> get props => [email];
}
