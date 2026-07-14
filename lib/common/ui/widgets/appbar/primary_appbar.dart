import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrimaryAppBar extends StatelessWidget {
  final Color iconColor;
  final VoidCallback onIconPressed;
  final String? title;
  final Color? titleColor;

  const PrimaryAppBar({
    super.key,
    required this.iconColor,
    required this.onIconPressed,
    this.title,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/svg_icons/arrow-left.svg',
          height: 24,
          width: 32,
          color: iconColor,
        ),
        onPressed: onIconPressed,
      ),
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: titleColor ?? Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      centerTitle: false,
    );
  }
}
