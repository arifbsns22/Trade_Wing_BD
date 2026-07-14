import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class UserProfileCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String name = user['name'] ?? 'User';
    final String mobile = user['mobile'] ?? '';
    final String email = user['email'] ?? '';
    final String role = user['role'] ?? 'Customer';
    final String password = user['password'] ?? 'N/A';
    final String address = user['address'] ?? 'Not provided';
    final String businessCode = user['businessCode'] ?? '';
    final String profilePicture = user['profilePicture'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner and Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient Banner
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Avatar
              Positioned(
                bottom: -40,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _getProfileImage(profilePicture),
                    child: profilePicture.isEmpty
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildInfoRow(Icons.phone_outlined, mobile),
                if (email.isNotEmpty) _buildInfoRow(Icons.email_outlined, email),
                _buildInfoRow(Icons.lock_outline, password, isCopyable: true),
                
                if (businessCode.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Business Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          businessCode,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: businessCode));
                            Get.snackbar('Copied', 'Business code copied');
                          },
                          child: const Icon(Icons.copy, size: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          if (isCopyable)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                Get.snackbar('Copied', 'Copied to clipboard', snackPosition: SnackPosition.BOTTOM);
              },
              child: const Icon(Icons.copy, size: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage(String url) {
    if (url.isEmpty) return null;
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      try {
        return MemoryImage(base64Decode(url.split(',').last));
      } catch (e) {
        return null;
      }
    }
  }
}
