import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/common/bottom_navbar_menu.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class CustomAuthHeaderText extends StatelessWidget {
  const CustomAuthHeaderText({
    super.key,
    required this.title,
    required this.subTitle,
  });
  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 10),
              Text(subTitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: () => Get.offAll(() => const BottomNavBarMenu()),
            icon: FaIcon(FontAwesomeIcons.house, color: AppColors.green),
          ),
        ),
      ],
    );
  }
}
