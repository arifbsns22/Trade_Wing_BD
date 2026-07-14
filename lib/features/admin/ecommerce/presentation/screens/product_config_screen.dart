import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ecommerce_controller.dart';
import '../widgets/config_item_manager.dart';

class ProductConfigScreen extends StatelessWidget {
  const ProductConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EcommerceController());

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'প্রোডাক্ট কনফিগ',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF08B3AC),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF08B3AC),
            tabs: [
              Tab(text: 'প্রোডাক্ট টাইপ'),
              Tab(text: 'ক্যাটাগরি'),
              Tab(text: 'ব্র্যান্ড'),
              Tab(text: 'ইউনিট'),
            ],
          ),
        ),
        body: Obx(() {
          return TabBarView(
            children: [
              // Product Types Config
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConfigItemManager(
                  title: 'প্রোডাক্ট টাইপ লিস্ট',
                  hintText: 'নতুন প্রোডাক্ট টাইপের নাম লিখুন',
                  items: controller.productTypes,
                  isLoading: controller.isLoading.value,
                  onAdd: (name, img, _, status) => controller.addProductType(name, image: img, status: status),
                  onUpdate: (id, name, img, _, status) => controller.updateProductType(id, name, image: img, status: status),
                  onDelete: (id) => controller.deleteProductType(id),
                ),
              ),

              // Categories Config
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConfigItemManager(
                  title: 'ক্যাটাগরি লিস্ট',
                  hintText: 'নতুন ক্যাটাগরির নাম লিখুন',
                  items: controller.categories,
                  productTypes: controller.productTypes,
                  isLoading: controller.isLoading.value,
                  onAdd: (name, img, pTypeId, status) {
                    if (pTypeId != null) {
                      controller.addCategory(name, image: img, productTypeId: pTypeId, status: status);
                    }
                  },
                  onUpdate: (id, name, img, pTypeId, status) {
                    if (pTypeId != null) {
                      controller.updateCategory(id, name, image: img, productTypeId: pTypeId, status: status);
                    }
                  },
                  onDelete: (id) => controller.deleteCategory(id),
                ),
              ),

              // Brands Config
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConfigItemManager(
                  title: 'ব্র্যান্ড লিস্ট',
                  hintText: 'নতুন ব্র্যান্ডের নাম লিখুন',
                  items: controller.brands,
                  productTypes: controller.productTypes,
                  isLoading: controller.isLoading.value,
                  onAdd: (name, img, pTypeId, status) {
                    if (pTypeId != null) {
                      controller.addBrand(name, image: img, productTypeId: pTypeId, status: status);
                    }
                  },
                  onUpdate: (id, name, img, pTypeId, status) {
                    if (pTypeId != null) {
                      controller.updateBrand(id, name, image: img, productTypeId: pTypeId, status: status);
                    }
                  },
                  onDelete: (id) => controller.deleteBrand(id),
                ),
              ),

              // Product Units Config
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConfigItemManager(
                  title: 'ইউনিট লিস্ট',
                  hintText: 'নতুন ইউনিটের নাম লিখুন (যেমন: Pcs, Kg)',
                  items: controller.units,
                  hideImagePicker: true,
                  isLoading: controller.isLoading.value,
                  onAdd: (name, _, __, status) => controller.addUnit(name, status: status),
                  onUpdate: (id, name, _, __, status) => controller.updateUnit(id, name, status: status),
                  onDelete: (id) => controller.deleteUnit(id),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
