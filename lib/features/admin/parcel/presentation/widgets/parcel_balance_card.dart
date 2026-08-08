import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/common/services/steadfast_service.dart';
import 'package:trade_wign_bd/features/admin/settings/presentation/controllers/admin_settings_controller.dart';

class ParcelBalanceCard extends StatefulWidget {
  const ParcelBalanceCard({super.key});

  @override
  State<ParcelBalanceCard> createState() => _ParcelBalanceCardState();
}

class _ParcelBalanceCardState extends State<ParcelBalanceCard> {
  bool _isBalanceVisible = false;

  final List<_ProviderBalance> _providers = [
    _ProviderBalance(
      name: 'Steadfast Courier Limited',
      icon: Icons.airport_shuttle_rounded,
      gradientColors: [
        Color(0xFF08B3AC),
        Color.fromARGB(255, 1, 66, 47),
      ], // Soft vibrant teal/emerald gradient
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    final controller = Get.isRegistered<AdminSettingsController>()
        ? Get.find<AdminSettingsController>()
        : Get.put(AdminSettingsController());

    final isActive = controller.isSteadfastActive.value;
    if (!isActive) {
      if (mounted) {
        setState(() {
          _providers[0].isInactive = true;
          _providers[0].isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _providers[0].isInactive = false;
        _providers[0].isLoading = true;
      });
    }

    final balance = await SteadfastService.getBalance();
    if (mounted) {
      setState(() {
        _providers[0].balance = balance;
        _providers[0].isLoading = false;
        _providers[0].hasError = balance == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminSettingsController>()
        ? Get.find<AdminSettingsController>()
        : Get.put(AdminSettingsController());

    return Obx(() {
      final isActive = controller.isSteadfastActive.value;

      // Auto-refresh state when controller state changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isActive == _providers[0].isInactive) {
          _fetchAll();
        }
      });

      return Column(
        children: _providers
            .map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCard(p),
              ),
            )
            .toList(),
      );
    });
  }

  Widget _buildCard(_ProviderBalance p) {
    final bool showFullBalance =
        _isBalanceVisible && !p.isLoading && !p.hasError && !p.isInactive;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.isInactive
              ? [
                  const Color(0xFF94A3B8),
                  const Color(0xFF64748B),
                ] // Silver-grey luxury gradient
              : p.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (p.isInactive ? Colors.grey.shade400 : p.gradientColors[0])
                .withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Abstract geometric background accents
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Brand Info + Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(p.icon, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.isInactive
                                    ? 'নিষ্ক্রিয় কুরিয়ার'
                                    : 'সক্রিয় মার্চেন্ট অ্যাকাউন্ট',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (!p.isInactive)
                        GestureDetector(
                          onTap: _fetchAll,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 16,
                              // Action code
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Bottom Row: Balance + Card Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'মোট ব্যালেন্স',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              if (!p.isLoading &&
                                  !p.hasError &&
                                  !p.isInactive) {
                                setState(() {
                                  _isBalanceVisible = !_isBalanceVisible;
                                });
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (p.isInactive)
                                  const Text(
                                    '৳ ০.০০',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  )
                                else if (p.isLoading)
                                  const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white70,
                                      ),
                                    ),
                                  )
                                else if (p.hasError)
                                  const Text(
                                    'লোড ব্যর্থ',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  )
                                else
                                  Text(
                                    showFullBalance
                                        ? '৳ ${p.balance!.toStringAsFixed(2)}'
                                        : '৳ ••••••••',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                if (!p.isLoading &&
                                    !p.hasError &&
                                    !p.isInactive) ...[
                                  const SizedBox(width: 10),
                                  Icon(
                                    _isBalanceVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Premium wallet badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.wallet_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'ডেলিভারি প্রোভাইডার ব্যালেন্স',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderBalance {
  final String name;
  final IconData icon;
  final List<Color> gradientColors;

  double? balance;
  bool isLoading = true;
  bool hasError = false;
  bool isInactive = false;

  _ProviderBalance({
    required this.name,
    required this.icon,
    required this.gradientColors,
  });
}
