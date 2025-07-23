import 'package:flutter/material.dart';
import 'package:money_manager/features/account_manager/login/login_screen.dart';
import 'package:money_manager/features/account_manager/sign_up/sign_up_screen.dart';
import 'package:money_manager/features/home/home_screen.dart';
import 'package:money_manager/features/profile/profile.dart';
import 'package:money_manager/features/splash/splash_screen.dart';
import 'package:money_manager/features/analytics/budget_planning_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String transactions = '/transactions';
  static const String budgetPlanning = '/budget-planning';

  // Route map for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    budgetPlanning: (context) => const BudgetPlanningScreen(),
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
      case transactions:
        // If you want to support deep linking to the transactions tab, handle it in HomeScreen
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case budgetPlanning:
        return MaterialPageRoute(
          builder: (context) => const BudgetPlanningScreen(),
        );
      default:
        // Return splash screen for unknown routes
        return MaterialPageRoute(builder: (context) => const SplashScreen());
    }
  }
}
