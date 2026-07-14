import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/admin/marketing/domain/models/banner_model.dart';

class HomeSlider extends StatelessWidget {
  const HomeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('marketing_banners')
          .where('status', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox(
            height: 160,
            child: Center(child: Text('Error loading banners')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Obx(() {
          final userRole = authController.currentUserRole.value;

          final banners = snapshot.data!.docs
              .map((doc) => BannerModel.fromFirestore(doc))
              .toList();

          if (banners.isEmpty) {
            return const SizedBox.shrink();
          }

          // Sort by isFeatured
          banners.sort((a, b) {
            if (a.isFeatured && !b.isFeatured) return -1;
            if (!a.isFeatured && b.isFeatured) return 1;
            return 0;
          });

          return CarouselSlider.builder(
            itemCount: banners.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
                  final banner = banners[itemIndex];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(banner.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
            options: CarouselOptions(
              aspectRatio: 3 / 1,
              autoPlay: banners.length > 1,
              enlargeFactor: 0.2,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
            ),
          );
        });
      },
    );
  }
}
