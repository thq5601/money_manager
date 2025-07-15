import 'package:flutter/material.dart';
import 'package:money_manager/feature/splash/splash_screen.dart';
import 'package:money_manager/feature/account_manager/login/login_screen.dart';
import 'package:money_manager/feature/account_manager/sign_up/sign_up_screen.dart';
import 'package:money_manager/feature/home/home_screen.dart';
import 'package:money_manager/feature/profile/profile.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';

  // Route map for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
  };

  // Route generator for dynamic routes
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (context) => const SignUpScreen());
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (context) => const ProfileScreen());
      default:
        // Return splash screen for unknown routes
        return MaterialPageRoute(builder: (context) => const SplashScreen());
    }
  }
}
