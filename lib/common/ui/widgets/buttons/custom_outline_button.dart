import 'package:flutter/material.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class CustomOutlineButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const CustomOutlineButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor, width: 1),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
