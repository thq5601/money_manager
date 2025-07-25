import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();
  @override
  List<Object?> get props => [];
}

class SignUpNameChanged extends SignUpEvent {
  final String name;
  const SignUpNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class SignUpEmailChanged extends SignUpEvent {
  final String email;
  const SignUpEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class SignUpPasswordChanged extends SignUpEvent {
  final String password;
  const SignUpPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class SignUpConfirmPasswordChanged extends SignUpEvent {
  final String confirmPassword;
  const SignUpConfirmPasswordChanged(this.confirmPassword);
  @override
  List<Object?> get props => [confirmPassword];
}

class SignUpPasswordVisibilityChanged extends SignUpEvent {
  final bool isVisible;
  const SignUpPasswordVisibilityChanged(this.isVisible);
  @override
  List<Object?> get props => [isVisible];
}

class SignUpConfirmPasswordVisibilityChanged extends SignUpEvent {
  final bool isVisible;
  const SignUpConfirmPasswordVisibilityChanged(this.isVisible);
  @override
  List<Object?> get props => [isVisible];
}

class SignUpTermsChanged extends SignUpEvent {
  final bool agree;
  const SignUpTermsChanged(this.agree);
  @override
  List<Object?> get props => [agree];
}

class SignUpSubmitted extends SignUpEvent {}
