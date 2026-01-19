// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary color palette from your images
  static const primary = Color.fromARGB(255, 255, 153, 0); // Amber/orange
  static const primaryDark = Color(0xFFF57C00);
  static const primaryLight = Color(0xFFFFCC80);
  
  // Background colors
  static const background = Color(0xFFFDFDFD);
  static const backgroundDark = Color(0xFF1C1C1C);
  static const card = Color(0xFFF4EED9);
  static const cardLight = Color(0xFFF9F5EB);
  
  // Text colors
  static const textDark = Color(0xFF1C1C1C);
  static const textMedium = Color(0xFF4A4A4A);
  static const textLight = Color(0xFF6F6F6F);
  static const textWhite = Color(0xFFFFFFFF);
  
  // Category colors
  static const category1 = Color(0xFFFFE0B2); // Breakfast
  static const category2 = Color(0xFFC8E6C9); // Lunch
  static const category3 = Color(0xFFBBDEFB); // Dinner
  static const category4 = Color(0xFFFFCDD2); // Desserts
  static const category5 = Color(0xFFE1BEE7); // Bakery
  static const category6 = Color(0xFFF0F4C3); // Snacks
  static const category7 = Color(0xFFB2EBF2); // Drinks
  
  // Accent colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);
  
  // Gradients
  static LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient cardGradient = LinearGradient(
    colors: [card, Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}