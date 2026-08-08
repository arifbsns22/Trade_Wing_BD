import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';
import 'parcel_stats_card.dart';

class ParcelStatsGrid extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;

  const ParcelStatsGrid({
    super.key,
    this.from,
    this.to,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('deliveryProvider', isEqualTo: 'Steadfast')
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        // Filter by date range if provided
        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (from == null && to == null) return true;
          final ts = data['createdAt'];
          if (ts == null) return false;
          DateTime? dt;
          if (ts is Timestamp) dt = ts.toDate();
          if (dt == null) return false;
          if (from != null && dt.isBefore(from!)) return false;
          if (to != null && dt.isAfter(to!)) return false;
          return true;
        }).toList();

        // Compute stats
        int totalCount = filtered.length;
        int deliveredCount = 0;
        int pendingCount = 0;
        int partialCount = 0;
        int approvalCount = 0;
        int cancelCount = 0;

        double totalBdt = 0;
        double deliveredBdt = 0;
        double pendingBdt = 0;
        double partialBdt = 0;
        double approvalBdt = 0;
        double cancelBdt = 0;

        for (final doc in filtered) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['deliveryStatus'] ?? '').toString().toLowerCase();
          final orderStatus = (data['orderStatus'] ?? '').toString().toLowerCase();
          final cod = (data['totalAmount'] ?? 0.0);
          final amount = cod is num ? cod.toDouble() : 0.0;
          totalBdt += amount;

          if (status == 'delivered' || orderStatus == 'delivered') {
            deliveredCount++;
            deliveredBdt += amount;
          } else if (status == 'partial_delivered' || status == 'partially_delivered') {
            partialCount++;
            partialBdt += amount;
          } else if (status == 'cancelled' || status == 'cancel') {
            cancelCount++;
            cancelBdt += amount;
          } else if (status == 'in_review' || status == 'approval') {
            approvalCount++;
            approvalBdt += amount;
          } else {
            pendingCount++;
            pendingBdt += amount;
          }
        }

        final cancelPercent = totalCount > 0
            ? '$cancelCount (${(cancelCount / totalCount * 100).toStringAsFixed(0)}%)'
            : '0 (0%)';

        final List<_StatItem> items = [
          _StatItem(
            title: 'মোট পার্সেল',
            count: totalCount,
            bdt: totalBdt,
            icon: Icons.inventory_2_outlined,
            iconBg: AppColors.primaryColor.withValues(alpha: 0.1),
            iconColor: AppColors.primaryColor,
          ),
          _StatItem(
            title: 'ডেলিভারড',
            count: deliveredCount,
            bdt: deliveredBdt,
            icon: Icons.check_circle_outline,
            iconBg: Colors.green.shade50,
            iconColor: Colors.green,
          ),
          _StatItem(
            title: 'পেন্ডিং',
            count: pendingCount,
            bdt: pendingBdt,
            icon: Icons.schedule_outlined,
            iconBg: Colors.amber.shade50,
            iconColor: Colors.amber.shade700,
          ),
          _StatItem(
            title: 'আংশিক ডেলিভারড',
            count: partialCount,
            bdt: partialBdt,
            icon: Icons.splitscreen_outlined,
            iconBg: Colors.blue.shade50,
            iconColor: Colors.blue,
          ),
          _StatItem(
            title: 'অ্যাপ্রুভাল স্ট্যাটাস',
            count: approvalCount,
            bdt: approvalBdt,
            icon: Icons.pending_actions_outlined,
            iconBg: Colors.purple.shade50,
            iconColor: Colors.purple,
          ),
          _StatItem(
            title: 'বাতিল',
            count: cancelCount,
            bdt: cancelBdt,
            icon: Icons.cancel_outlined,
            iconBg: Colors.red.shade50,
            iconColor: Colors.red,
            subtitle: cancelPercent,
          ),
        ];

        if (snapshot.connectionState == ConnectionState.waiting && docs.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.55,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return ParcelStatsCard(
              title: item.title,
              count: item.count,
              totalBdt: item.bdt,
              icon: item.icon,
              iconBgColor: item.iconBg,
              iconColor: item.iconColor,
              subtitle: item.subtitle,
            );
          },
        );
      },
    );
  }
}

class _StatItem {
  final String title;
  final int count;
  final double bdt;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String? subtitle;

  const _StatItem({
    required this.title,
    required this.count,
    required this.bdt,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.subtitle,
  });
}
