import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_colors.dart';

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isVisible;
  final Function(bool) onVisibilityChanged;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.isVisible,
    required this.onVisibilityChanged,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: validator,
        style: const TextStyle(color: AppColors.darkGreen),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.darkGreen.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.lock,
            color: AppColors.darkGreen.withValues(alpha: 0.7),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.darkGreen.withValues(alpha: 0.7),
            ),
            onPressed: () => onVisibilityChanged(!isVisible),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
