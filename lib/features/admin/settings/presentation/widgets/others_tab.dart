import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import '../controllers/admin_settings_controller.dart';

class OthersTab extends StatelessWidget {
  const OthersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'অন্যান্য সেটিংস শীঘ্রই আসছে',
        style: TextStyle(color: Colors.black54, fontSize: 14),
      ),
    );
  }
}
