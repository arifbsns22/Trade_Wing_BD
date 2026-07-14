import 'package:flutter/material.dart';

import '../../../../../uitls/constants/app_colors.dart';
import '../curved_edges/curved_edge.dart';

class PrimaryHeaderContainer extends StatelessWidget {
  const PrimaryHeaderContainer({
    super.key,
    required this.child,
    this.height = 240,
  });
  final Widget child;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return CurvedEdgeWidget(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientTtBWithPrimary,
        ),
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              child,
            ],
          ),
        ),
      ),
    );
  }
}
