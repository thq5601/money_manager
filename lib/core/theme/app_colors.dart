import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color green = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color mintGreen = Color(0xFF66BB6A);
  static const Color paleGreen = Color(0xFF81C784);

  // Secondary Colors
  static const Color orange = Color(0xFFFF9800);
  static const Color red = Color(0xFFE53935);
  static const Color blue = Color(0xFF2196F3);
  static const Color purple = Color(0xFF9C27B0);
  static const Color teal = Color(0xFF009688);

  // Neutral Colors
  static const Color darkGrey = Color(0xFF424242);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFBDBDBD);
  static const Color paleGrey = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceBackground = Color(0xFFF8F9FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF6A1B9A), Color(0xFF7B1FA2), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'salary': Color(0xFF4CAF50),
    'freelance': Color(0xFF2196F3),
    'investment': Color(0xFF9C27B0),
    'business': Color(0xFFFF9800),
    'otherIncome': Color(0xFF009688),
    'food': Color(0xFFFF5722),
    'transportation': Color(0xFF3F51B5),
    'shopping': Color(0xFFE91E63),
    'entertainment': Color(0xFF9C27B0),
    'healthcare': Color(0xFFF44336),
    'education': Color(0xFF2196F3),
    'housing': Color(0xFF795548),
    'utilities': Color(0xFF607D8B),
    'insurance': Color(0xFF009688),
    'otherExpense': Color(0xFF757575),
  };
}
