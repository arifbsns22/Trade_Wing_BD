import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CheckBoxThemeInfo{
  static CheckboxThemeData get lightTheme {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(3),
      ),
      checkColor: WidgetStateProperty.all(Colors.white),
    );
  }
  static CheckboxThemeData get darkTheme {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(3),
      ),

    );
  }
}