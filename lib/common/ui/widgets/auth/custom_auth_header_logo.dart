import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/common/ui/widgets/dynamic_app_logo.dart';

class CustomAuthHeaderLogo extends StatelessWidget {
  const CustomAuthHeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: const DynamicAppLogo(
          isDark:
              true, // Typically dark logo is shown on light backgrounds if desired, or false.
          height: 60, // Set an appropriate height for the login header
        ),
      ),
    );
  }
}
