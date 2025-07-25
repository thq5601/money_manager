import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_colors.dart';

class SignUpPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isVisible;
  final Function(bool) onVisibilityChanged;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const SignUpPasswordField({
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
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.darkGreen),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.darkGreen.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF388E3C)),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.darkGreen.withOpacity(0.7),
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
