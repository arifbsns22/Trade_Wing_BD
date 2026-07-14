import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/uitls/constants/assets_path/images_path.dart';

class DynamicAppLogo extends StatelessWidget {
  final bool isDark;
  final double? height;
  final BoxFit fit;

  const DynamicAppLogo({
    super.key,
    this.isDark = false,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('app_settings').doc(isDark ? 'logo_dark' : 'logo_light').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final url = data?['url'] as String?;
          final base64String = data?['base64'] as String?;
          
          if (url != null && url.isNotEmpty) {
            return Image.network(
              url,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _buildFallback(),
            );
          } else if (base64String != null && base64String.isNotEmpty) {
            try {
              return Image.memory(
                base64Decode(base64String),
                height: height,
                fit: fit,
                errorBuilder: (context, error, stackTrace) => _buildFallback(),
              );
            } catch (e) {
              debugPrint('Error decoding base64 logo: $e');
            }
          }
        }
        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    final path = isDark ? ImagePath.darkLogoPng : ImagePath.lightLogoPng;
    
    return _buildImageWidget(path, onFail: () {
      if (isDark) {
        return _buildImageWidget(ImagePath.lightLogoPng, onFail: () => _buildTextFallback());
      }
      return _buildTextFallback();
    });
  }

  Widget _buildImageWidget(String path, {required Widget Function() onFail}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => onFail(),
      );
    }
    return Image.asset(
      path,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => onFail(),
    );
  }

  Widget _buildTextFallback() {
    return Container(
      height: height ?? 40,
      alignment: Alignment.center,
      child: Text(
        'TRADE WIGN',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.teal,
        ),
      ),
    );
  }
}
