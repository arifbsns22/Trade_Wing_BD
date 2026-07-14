import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/features_card.dart';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/home_slider.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/category_section.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/brand_section.dart';
import 'package:trade_wign_bd/features/users/home/presentation/widgets/home_product_sections.dart';
import 'package:trade_wign_bd/features/admin/ecommerce/presentation/controllers/ecommerce_controller.dart';
import 'package:trade_wign_bd/uitls/theme/custom_theme/custom_appbar.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ecommerceController = Get.put(EcommerceController());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(),
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => Skeletonizer(
            enabled: ecommerceController.isLoading.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 00.0, 20.0, 118.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeatureGrid(features: featureList),
                  const SizedBox(height: 20),
                  const HomeSlider(),
                  const SizedBox(height: 20),
                  const CategorySection(),
                  const SizedBox(height: 20),
                  const BrandSection(),
                  const SizedBox(height: 20),
                  const HomeProductSections(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
