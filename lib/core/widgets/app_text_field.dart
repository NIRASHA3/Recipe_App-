// lib/core/widgets/app_text_field.dart (Updated: Added controller/onTap, better validation hints, shadows)
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final Widget? prefixIcon;
  final Color? fillColor;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final String? Function(String?)? validator; // Added for form validation

  const AppTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
    this.prefixIcon,
    this.fillColor,
    this.controller,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( // Changed to TextFormField for validation
      controller: controller,
      obscureText: isPassword,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 16),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: fillColor ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // ignore: deprecated_member_use
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}