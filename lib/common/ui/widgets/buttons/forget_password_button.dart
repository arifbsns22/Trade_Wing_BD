import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../uitls/constants/app_colors.dart';

class ForgetPasswordButton extends StatelessWidget {
  const ForgetPasswordButton({
    super.key, required this.text, required this.onTap,
  });
final String text;
final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
            text: text,
            style: TextStyle(color: AppColors.primaryColor),
            recognizer: TapGestureRecognizer()
              ..onTap = onTap ));
  }
}
