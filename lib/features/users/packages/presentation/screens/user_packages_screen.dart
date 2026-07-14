import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/packages/presentation/controllers/package_controller.dart';
import 'package:trade_wign_bd/features/users/packages/presentation/widgets/user_package_card.dart';
import 'package:trade_wign_bd/features/users/packages/presentation/widgets/package_payment_sheet.dart';

class UserPackagesScreen extends StatefulWidget {
  const UserPackagesScreen({super.key});

  @override
  State<UserPackagesScreen> createState() => _UserPackagesScreenState();
}

class _UserPackagesScreenState extends State<UserPackagesScreen> {
  final PackageController _packageController = Get.put(PackageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'আমাদের প্যাকেজ সমূহ',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (_packageController.isLoading.value &&
            _packageController.packages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final publicPackages = _packageController.packages
            .where((p) => p.status == 'public')
            .toList();

        // Sort packages so Top Choice is always first
        publicPackages.sort((a, b) {
          if (a.isTopChoice && !b.isTopChoice) return -1;
          if (!a.isTopChoice && b.isTopChoice) return 1;
          return 0;
        });

        if (publicPackages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.layers_clear, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No packages available',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 140),
          physics: const BouncingScrollPhysics(),
          itemCount: publicPackages.length,
          itemBuilder: (context, index) {
            final package = publicPackages[index];
            return UserPackageCard(
              package: package,
              onUpgrade: () {
                showPackagePaymentSheet(context, package);
              },
            );
          },
        );
      }),
    );
  }
}
