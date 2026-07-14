import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/banner_controller.dart';
import '../widgets/add_banner.dart';
import '../widgets/list_banners.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(BannerController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text(
          'এপস মার্কেটিং - ব্যানার',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFFF4F7FE),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              // Desktop/Tablet view: Add Banner on left (1/3), List on right (2/3)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 1,
                    child: AddBannerWidget(),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    flex: 2,
                    child: ListBannersWidget(),
                  ),
                ],
              );
            } else {
              // Mobile view: Add Banner on top, List on bottom
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AddBannerWidget(),
                  SizedBox(height: 24),
                  ListBannersWidget(),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
