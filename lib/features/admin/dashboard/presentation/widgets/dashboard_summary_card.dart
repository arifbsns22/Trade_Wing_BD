import 'package:flutter/material.dart';

class DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color themeColor;
  final String? percentage;
  final bool isPositive;

  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.themeColor,
    this.percentage,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.9 + (animValue * 0.1),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Title & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeColor.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: themeColor,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Middle: Large Value
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeColor,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),

            // Bottom: Subtitle & trend badge
            Row(
              children: [
                if (percentage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          percentage!,
                          style: TextStyle(
                            fontSize: 10,
                            color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: themeColor.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
