import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class TextThemeInfo {
  static TextTheme lightTheme() {
    return TextTheme(
      headlineLarge: TextStyle(color: AppColors.primaryColor),
      headlineMedium: TextStyle(color: AppColors.primaryColor),
      bodyMedium: TextStyle(color: Colors.grey),
    );
  }

  static TextTheme darkTheme() {
    return TextTheme(
      headlineLarge: TextStyle(color: AppColors.primaryColor),
      bodyMedium: TextStyle(color: Colors.grey),
    );
  }
}