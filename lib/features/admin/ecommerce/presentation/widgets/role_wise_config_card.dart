import 'package:flutter/material.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class RoleWiseConfigCard extends StatefulWidget {
  final Map<String, double> initialPrices;
  final Map<String, int> initialRewards;
  final Function(Map<String, double> prices, Map<String, int> rewards) onChange;

  const RoleWiseConfigCard({
    super.key,
    required this.initialPrices,
    required this.initialRewards,
    required this.onChange,
  });

  @override
  State<RoleWiseConfigCard> createState() => _RoleWiseConfigCardState();
}

class _RoleWiseConfigCardState extends State<RoleWiseConfigCard> {
  // List of user roles matching UserRole enum display values
  final List<Map<String, String>> rolesList = [
    {'key': 'Vendor', 'name': 'ভেন্ডর (Vendor)'},
    {'key': 'Customer', 'name': 'গ্রাহক (Customer)'},
    {'key': 'Brand Promoter', 'name': 'ব্র্যান্ড প্রমোটর (Brand Promoter)'},
    {'key': 'Sales Partner', 'name': 'সেলস পার্টনার (Sales Partner)'},
    {'key': 'Senior Sales Partner', 'name': 'সিনিয়র সেলস পার্টনার (Senior Partner)'},
    {'key': 'Sub Dealer', 'name': 'সাব ডিলার (Sub Dealer)'},
    {'key': 'Dealer', 'name': 'ডিলার (Dealer)'},
    {'key': 'Senior Dealer', 'name': 'সিনিয়র ডিলার (Senior Dealer)'},
    {'key': 'Master Dealer', 'name': 'মাস্টার ডিলার (Master Dealer)'},
    {'key': 'Super Admin', 'name': 'সুপার এডমিন (Super Admin)'},
  ];

  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _rewardControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    for (var role in rolesList) {
      final key = role['key']!;
      _priceControllers[key] = TextEditingController(
        text: widget.initialPrices[key]?.toStringAsFixed(0) ?? '',
      );
      _rewardControllers[key] = TextEditingController(
        text: widget.initialRewards[key]?.toString() ?? '',
      );
      
      // Setup listeners to notify parent of changes
      _priceControllers[key]!.addListener(_onDataChanged);
      _rewardControllers[key]!.addListener(_onDataChanged);
    }
  }

  @override
  void dispose() {
    _priceControllers.forEach((_, c) => c.dispose());
    _rewardControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _onDataChanged() {
    final Map<String, double> prices = {};
    final Map<String, int> rewards = {};

    for (var role in rolesList) {
      final key = role['key']!;
      final priceVal = double.tryParse(_priceControllers[key]!.text) ?? 0.0;
      final rewardVal = int.tryParse(_rewardControllers[key]!.text) ?? 0;
      
      prices[key] = priceVal;
      rewards[key] = rewardVal;
    }

    widget.onChange(prices, rewards);
  }

  // Auto-fill logic helper
  void _performAutoFill() {
    // We base everything on the Customer price entered
    final double customerPrice = double.tryParse(_priceControllers['Customer']!.text) ?? 0.0;
    if (customerPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অটো-ফিল করতে প্রথমে গ্রাহক (Customer) মূল্য প্রবেশ করুন')),
      );
      return;
    }

    // Role pricing rates: B2B discounts
    final Map<String, double> priceFactors = {
      'Vendor': 0.85,               // Vendor rate (15% discount)
      'Customer': 1.0,
      'Brand Promoter': 0.95,       // 5% discount
      'Sales Partner': 0.90,        // 10% discount
      'Senior Sales Partner': 0.85, // 15% discount
      'Sub Dealer': 0.80,           // 20% discount
      'Dealer': 0.75,               // 25% discount
      'Senior Dealer': 0.70,         // 30% discount
      'Master Dealer': 0.65,         // 35% discount
      'Super Admin': 0.60,          // 40% discount
    };

    // Auto rewards logic: 1 reward point per 10 BDT of price
    setState(() {
      priceFactors.forEach((key, factor) {
        if (_priceControllers.containsKey(key)) {
          final double calculatedPrice = customerPrice * factor;
          _priceControllers[key]!.text = calculatedPrice.toStringAsFixed(0);
          
          final int calculatedPoints = (calculatedPrice / 10).round();
          _rewardControllers[key]!.text = calculatedPoints.toString();
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('রোলেভিত্তিক মূল্য ও রিওয়ার্ড পয়েন্ট অটো-ফিল সম্পন্ন হয়েছে')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(Icons.shield_outlined, color: AppColors.primaryColor),
        title: const Text(
          'রোলভিত্তিক মূল্য ও রিওয়ার্ড পয়েন্ট সেটিংস',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'ভিন্ন ভিন্ন কাস্টমার রোলের জন্য ভিন্ন রেট সেট করুন',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Autofill Helper Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'টিপস: গ্রাহক মূল্য দিয়ে নিচে অটো-ফিল বাটনে ক্লিক করলে সকল রোলের জন্য স্বয়ংক্রিয় ডিসকাউন্ট যুক্ত হয়ে যাবে।',
                        style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                        foregroundColor: AppColors.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 14),
                      label: const Text('অটো-ফিল', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: _performAutoFill,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grid/List of roles inputs
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rolesList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final role = rolesList[index];
                    final key = role['key']!;
                    final isVendor = key == 'Vendor';

                    final itemContent = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (isVendor) ...[
                                  const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFFD97706)),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  role['name']!,
                                  style: TextStyle(
                                    fontSize: isVendor ? 13 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: isVendor ? const Color(0xFF92400E) : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (isVendor)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '★ Vendor Exclusive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Price Input
                            Expanded(
                              child: TextFormField(
                                controller: _priceControllers[key],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'মূল্য (৳)',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: Icon(
                                    Icons.monetization_on_outlined,
                                    size: 16,
                                    color: isVendor ? const Color(0xFFD97706) : null,
                                  ),
                                  filled: isVendor,
                                  fillColor: isVendor ? Colors.white : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Rewards Input
                            Expanded(
                              child: TextFormField(
                                controller: _rewardControllers[key],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'রিওয়ার্ড পয়েন্ট',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: Icon(
                                    Icons.star_outline_rounded,
                                    size: 16,
                                    color: isVendor ? const Color(0xFFD97706) : null,
                                  ),
                                  filled: isVendor,
                                  fillColor: isVendor ? Colors.white : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    if (isVendor) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFEF3C7),
                              const Color(0xFFFFFBEB),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: itemContent,
                      );
                    }

                    return itemContent;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
