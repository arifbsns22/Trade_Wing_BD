import 'package:flutter/material.dart';

import '../../../uitls/constants/app_colors.dart';
import '../widgets/appbar/primary_appbar.dart';

class CommingSoon extends StatelessWidget {
  const CommingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Custom height
        child: PrimaryAppBar(
          iconColor: AppColors.primaryColor,
          onIconPressed: () {},
          title: 'ফেরত আসুন',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.1,
              child: Image.asset('assets/color_icons/lantern.png'),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'শীঘ্রই আসছে',
                  style: TextStyle(fontSize: 40, color: AppColors.primaryColor),
                ),
                SizedBox(height: 10),
                const Text(
                  'আমাদের এই ফিচারের কাজ চলমান আছে। ইনশাল্লাহ খুব দ্রুত আমরা এই ফিচারটি লাইভ করতে পারবো। নতুন এই ফিচারটি লাইভ হওয়া মাত্রই আপনি নোটিফিকেশন পেয়ে যাবেন',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
