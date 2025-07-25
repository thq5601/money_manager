import 'package:flutter_bloc/flutter_bloc.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';
import 'package:money_manager/core/services/sign_up_service.dart';
import 'package:flutter/material.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpService signUpService;

  SignUpBloc({required this.signUpService}) : super(const SignUpState()) {
    on<SignUpNameChanged>((event, emit) {
      emit(state.copyWith(name: event.name));
    });
    on<SignUpEmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });
    on<SignUpPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
      _checkPasswordStrength(event.password, emit);
    });
    on<SignUpConfirmPasswordChanged>((event, emit) {
      emit(state.copyWith(confirmPassword: event.confirmPassword));
    });
    on<SignUpPasswordVisibilityChanged>((event, emit) {
      emit(state.copyWith(isPasswordVisible: event.isVisible));
    });
    on<SignUpConfirmPasswordVisibilityChanged>((event, emit) {
      emit(state.copyWith(isConfirmPasswordVisible: event.isVisible));
    });
    on<SignUpTermsChanged>((event, emit) {
      emit(state.copyWith(agreeToTerms: event.agree));
    });
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  void _checkPasswordStrength(String password, Emitter<SignUpState> emit) {
    int strength = 0;
    String message = '';
    Color color = Colors.grey;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    switch (strength) {
      case 0:
      case 1:
        message = 'Very Weak';
        color = Colors.red;
        break;
      case 2:
        message = 'Weak';
        color = Colors.orange;
        break;
      case 3:
        message = 'Medium';
        color = Colors.yellow[700]!;
        break;
      case 4:
        message = 'Strong';
        color = Colors.lightGreen;
        break;
      case 5:
        message = 'Very Strong';
        color = Colors.green;
        break;
    }
    emit(
      state.copyWith(passwordStrength: message, passwordStrengthColor: color),
    );
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (!state.agreeToTerms) {
      emit(
        state.copyWith(
          errorMessage: 'Please agree to the terms and conditions',
        ),
      );
      return;
    }
    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));
    try {
      await signUpService.signUpWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password,
        fullName: state.name.trim(),
      );
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          isSuccess: false,
        ),
      );
    }
  }
}
