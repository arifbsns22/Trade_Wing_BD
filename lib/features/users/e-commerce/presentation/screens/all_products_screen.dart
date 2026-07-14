import 'package:flutter/material.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/product_archive_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/controllers/product_archive_controller.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/widgets/user_home_products.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductArchiveScreen(
      args: ProductArchiveArguments(
        archiveTitle: 'সকল পণ্য',
        filterType: ProductTypeFilter.recent,
      ),
    );
  }
}
