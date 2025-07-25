import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/bloc/account/login/login_bloc.dart';
import 'package:money_manager/bloc/account/login/login_event.dart';
import 'package:money_manager/bloc/account/login/login_state.dart';
import 'package:money_manager/core/services/sign_up_service.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:money_manager/features/account_manager/login/widgets/login_text_field.dart';
import 'package:money_manager/features/account_manager/login/widgets/login_password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authService: SignUpService()),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: AppColors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.forgotPasswordEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset email sent! Check your inbox.'),
                backgroundColor: AppColors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.greenGradient,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 40),

                              // App Logo/Title
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Money Manager',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Welcome back!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Email Field
                              LoginTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email address';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context.read<LoginBloc>().add(
                                    LoginEmailChanged(value),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // Password Field
                              LoginPasswordField(
                                controller: _passwordController,
                                label: 'Password',
                                isVisible: state.isPasswordVisible,
                                onVisibilityChanged: (value) {
                                  context.read<LoginBloc>().add(
                                    LoginPasswordVisibilityChanged(value),
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  context.read<LoginBloc>().add(
                                    LoginPasswordChanged(value),
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // Remember Me and Forgot Password
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Container()),
                                      GestureDetector(
                                        onTap: () {
                                          if (_emailController.text
                                              .trim()
                                              .isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please enter your email address first',
                                                ),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          } else {
                                            context.read<LoginBloc>().add(
                                              LoginForgotPassword(
                                                _emailController.text.trim(),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          checkboxTheme: CheckboxThemeData(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: const BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: Checkbox(
                                          value: state.rememberMe,
                                          onChanged: (value) {
                                            context.read<LoginBloc>().add(
                                              LoginRememberMeChanged(
                                                value ?? false,
                                              ),
                                            );
                                          },
                                          activeColor: Colors.white,
                                          checkColor: AppColors.darkGreen,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.padded,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Remember me',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.3),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // Login Button
                              ElevatedButton(
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<LoginBloc>().add(
                                            LoginSubmitted(),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.darkGreen,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 6,
                                ),
                                child: state.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.darkGreen,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t have an account? ',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/signup');
                                    },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
