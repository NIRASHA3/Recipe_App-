// lib/core/widgets/primary_button.dart (Fixed: Proper disabled state handling)
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.disabledColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isLoading || !isEnabled || onTap == null;
    
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              // ignore: deprecated_member_use
              ? (disabledColor ?? AppColors.primary.withOpacity(0.6))
              : (backgroundColor ?? AppColors.primary),
          // ignore: deprecated_member_use
          foregroundColor: isDisabled ? Colors.white.withOpacity(0.9) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isDisabled ? 0 : 2,
          // This ensures text stays white even when disabled
          // ignore: deprecated_member_use
          disabledBackgroundColor: disabledColor ?? AppColors.primary.withOpacity(0.6),
          // ignore: deprecated_member_use
          disabledForegroundColor: Colors.white.withOpacity(0.9),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  // ignore: deprecated_member_use
                  color: isDisabled ? Colors.white.withOpacity(0.9) : Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDisabled 
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.9) 
                      : (textColor ?? Colors.white),
                ),
              ),
      ),
    );
  }
}