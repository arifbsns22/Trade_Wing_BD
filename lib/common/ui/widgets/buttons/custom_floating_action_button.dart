import 'package:flutter/material.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Object? heroTag;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.elevation = 4,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: backgroundColor ?? AppColors.green,
      foregroundColor: foregroundColor,
      shape: const CircleBorder(),
      elevation: elevation,
      onPressed: onPressed,
      child: Icon(icon, size: 30),
    );
  }
}
