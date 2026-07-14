import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class TextFieldTheme {
  static InputDecorationTheme lightTheme() {
    return InputDecorationTheme(
        border: _getBorder(),
        enabledBorder: _getBorder(),
        focusedBorder: _getBorder(),
        errorBorder: _getBorder(),
        filled: true,
        fillColor: Colors.white,
        labelStyle:
        const TextStyle().copyWith(fontSize: 16, color: Colors.black),
        hintStyle: const TextStyle()
            .copyWith(fontSize: 14, color: Colors.grey.withOpacity(0.5)),
        prefixIconColor: AppColors.primaryColor,
        suffixIconColor: Colors.grey);
  }

  static InputDecorationTheme darkTheme() {
    return InputDecorationTheme(
      border: _getBorder(),
      enabledBorder: _getBorder(),
      focusedBorder: _getBorder(),
      errorBorder: _getBorder(),
      filled: true,
      fillColor: Colors.white,
    );
  }

  static OutlineInputBorder _getBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primaryColor),
    );
  }
}