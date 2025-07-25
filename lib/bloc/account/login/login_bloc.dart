import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:money_manager/core/services/sign_up_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignUpService authService;

  LoginBloc({required this.authService}) : super(const LoginState()) {
    on<LoginEmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });
    on<LoginPasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });
    on<LoginPasswordVisibilityChanged>((event, emit) {
      emit(state.copyWith(isPasswordVisible: event.isVisible));
    });
    on<LoginRememberMeChanged>((event, emit) {
      emit(state.copyWith(rememberMe: event.rememberMe));
    });
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginForgotPassword>(_onForgotPassword);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));
    try {
      await authService.signInWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password,
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

  Future<void> _onForgotPassword(
    LoginForgotPassword event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        forgotPasswordEmailSent: false,
      ),
    );
    try {
      await authService.resetPassword(event.email.trim());
      emit(state.copyWith(isLoading: false, forgotPasswordEmailSent: true));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          forgotPasswordEmailSent: false,
        ),
      );
    }
  }
}
