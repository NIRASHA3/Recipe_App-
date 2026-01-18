// lib/core/widgets/primary_button.dart (Updated: White text for primary, loading support, 52px height)
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap; // Made nullable for disabled
  final bool isLoading;
  final bool isEnabled; // For conditional disable

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading || !isEnabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary : Colors.grey,
          foregroundColor: Colors.white, // Fixed to white for primary
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Reduced from 28 for subtlety
          ),
          elevation: isEnabled ? 2 : 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // Fixed
                ),
              ),
      ),
    );
  }
}