import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trade_wign_bd/features/users/all_services/presentation/screens/all_services_screen.dart';
import 'package:trade_wign_bd/features/users/home/presentation/screens/user_home_screen.dart';
import 'package:trade_wign_bd/features/users/e-commerce/presentation/screens/all_products_screen.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/features/common/profile/presentation/screens/profile_screen.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/screens/login_screen.dart';
import 'package:trade_wign_bd/features/users/packages/presentation/screens/user_packages_screen.dart';

class BottomNavBarMenu extends StatefulWidget {
  const BottomNavBarMenu({super.key});

  static const String name = 'bottom_nav_bar';

  @override
  State<BottomNavBarMenu> createState() => _BottomNavBarMenuState();
}

class _BottomNavBarMenuState extends State<BottomNavBarMenu> {
  final _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const UserDashboardScreen(),
    const AllServicesScreen(),
    const AllProductsScreen(),
    const UserPackagesScreen(),
    Obx(() {
      final authController = AuthController.instance;
      if (authController.currentUserRole.value == 'Guest Customer' || 
          authController.currentUserMobile.value.isEmpty) {
        return const LoginScreen();
      }
      return const UserProfileScreen();
    }),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe gestures to force tab clicks
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                    width: 1.0,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      0,
                      FontAwesomeIcons.solidHouse,
                      FontAwesomeIcons.house,
                      'হোম',
                    ),
                    _buildNavItem(
                      1,
                      FontAwesomeIcons.solidHandshake,
                      FontAwesomeIcons.handshake,
                      'সেবা নিন',
                    ),
                    _buildNavItem(
                      2,
                      FontAwesomeIcons.cartArrowDown,
                      FontAwesomeIcons.cartArrowDown,
                      'শপিং',
                    ),
                    _buildNavItem(
                      3,
                      FontAwesomeIcons.bangladeshiTakaSign,
                      FontAwesomeIcons.bangladeshiTakaSign,
                      'আয় করুন',
                    ),
                    _buildNavItem(
                      4,
                      FontAwesomeIcons.solidUser,
                      FontAwesomeIcons.user,
                      'প্রোফাইল',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    dynamic selectedIcon,
    dynamic unselectedIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.green : Colors.black;
    final icon = isSelected ? selectedIcon : unselectedIcon;

    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(icon, color: color, size: 20);
    } else {
      iconWidget = FaIcon(icon as FaIconData, color: color, size: 20);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.jumpToPage(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: iconWidget,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.3,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
