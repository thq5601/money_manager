import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool rememberMe;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final bool forgotPasswordEmailSent;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.rememberMe = false,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.forgotPasswordEmailSent = false,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? rememberMe,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool? forgotPasswordEmailSent,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      forgotPasswordEmailSent:
          forgotPasswordEmailSent ?? this.forgotPasswordEmailSent,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    isPasswordVisible,
    rememberMe,
    isLoading,
    errorMessage,
    isSuccess,
    forgotPasswordEmailSent,
  ];
}
