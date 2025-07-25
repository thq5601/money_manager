import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SignUpState extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;
  final bool agreeToTerms;
  final String passwordStrength;
  final Color passwordStrengthColor;
  final String? errorMessage;
  final bool isSuccess;

  const SignUpState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.agreeToTerms = false,
    this.passwordStrength = '',
    this.passwordStrengthColor = Colors.grey,
    this.errorMessage,
    this.isSuccess = false,
  });

  SignUpState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
    bool? agreeToTerms,
    String? passwordStrength,
    Color? passwordStrengthColor,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return SignUpState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      passwordStrength: passwordStrength ?? this.passwordStrength,
      passwordStrengthColor:
          passwordStrengthColor ?? this.passwordStrengthColor,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    confirmPassword,
    isPasswordVisible,
    isConfirmPasswordVisible,
    isLoading,
    agreeToTerms,
    passwordStrength,
    passwordStrengthColor,
    errorMessage,
    isSuccess,
  ];
}
