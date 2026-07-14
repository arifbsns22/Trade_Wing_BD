import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_theme/check_box_theme_data.dart';
import 'custom_theme/outline_buttton_theme_info.dart';
import 'custom_theme/text_field_theme.dart';
import 'custom_theme/text_theme.dart';

class AppTheme {
  static ThemeData get lightThemeData {
    return ThemeData(
        fontFamily: 'Sirajee Sanjer',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: AppColors.primaryColor,
        ),
        inputDecorationTheme: TextFieldTheme.lightTheme(),
        checkboxTheme: CheckBoxThemeInfo.lightTheme,
        textTheme: TextThemeInfo.lightTheme(),
        outlinedButtonTheme: OutlineButtonThemeInfo.lightTheme()

    );
  }

  static ThemeData get darkThemeData {
    return ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Sirajee Sanjer',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: AppColors.primaryColor,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: TextFieldTheme.darkTheme(),
        checkboxTheme: CheckBoxThemeInfo.darkTheme,
        textTheme: TextThemeInfo.darkTheme(),
        outlinedButtonTheme: OutlineButtonThemeInfo.darkTheme()
    );
  }
}