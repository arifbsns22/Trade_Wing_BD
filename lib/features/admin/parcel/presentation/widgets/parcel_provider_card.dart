import 'package:flutter/material.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'package:trade_wign_bd/common/services/steadfast_service.dart';

class ParcelProviderCard extends StatefulWidget {
  final String providerName;
  final String description;
  final bool isActive;
  final bool isPlaceholder;
  final IconData icon;

  const ParcelProviderCard({
    super.key,
    required this.providerName,
    required this.description,
    required this.isActive,
    this.isPlaceholder = false,
    required this.icon,
  });

  @override
  State<ParcelProviderCard> createState() => _ParcelProviderCardState();
}

class _ParcelProviderCardState extends State<ParcelProviderCard> {
  double? _balance;
  bool _loadingBalance = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive && !widget.isPlaceholder) {
      _fetchBalance();
    }
  }

  Future<void> _fetchBalance() async {
    setState(() => _loadingBalance = true);
    final balance = await SteadfastService.getBalance();
    if (mounted) {
      setState(() {
        _balance = balance;
        _loadingBalance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardBg =
        widget.isPlaceholder ? const Color(0xFFF8F8F8) : Colors.white;
    final Color iconBg = widget.isPlaceholder
        ? Colors.grey.shade200
        : AppColors.primaryColor.withValues(alpha: 0.1);
    final Color iconColor =
        widget.isPlaceholder ? Colors.grey.shade400 : AppColors.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isPlaceholder
              ? Colors.grey.shade200
              : AppColors.primaryColor.withValues(alpha: 0.15),
        ),
        boxShadow: widget.isPlaceholder
            ? []
            : [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.providerName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.isPlaceholder
                        ? Colors.grey.shade500
                        : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (!widget.isPlaceholder) ...[
                  const SizedBox(height: 6),
                  if (_loadingBalance)
                    Text(
                      'ব্যালেন্স লোড হচ্ছে...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else if (_balance != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'মার্চেন্ট ব্যালেন্স: ৳${_balance!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _fetchBalance,
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: _fetchBalance,
                      child: Text(
                        'ব্যালেন্স দেখুন',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (!widget.isPlaceholder) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.isActive ? 'সক্রিয়' : 'নিষ্ক্রিয়',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.isActive
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'শীঘ্রই',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
