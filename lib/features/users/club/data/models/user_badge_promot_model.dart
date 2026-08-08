import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserBadgePromotionModel {
  final String badgeName;
  final String banglaLabel;
  final int rank;
  final String iconName;
  final String description;

  // Criteria fields
  final bool requiresPackagePurchase;
  final int requiredDirectCustomers;

  // Downline counts (cumulative/at least that rank)
  final int requiredActiveCustomers;
  final int requiredBrandPromoters;
  final int requiredSalesPartners;
  final int requiredSeniorSalesPartners;
  final int requiredSubDealers;
  final int requiredDealers;
  final int requiredSeniorDealers;
  final int requiredMasterDealers;

  UserBadgePromotionModel({
    required this.badgeName,
    required this.banglaLabel,
    required this.rank,
    required this.iconName,
    required this.description,
    this.requiresPackagePurchase = false,
    this.requiredDirectCustomers = 0,
    this.requiredActiveCustomers = 0,
    this.requiredBrandPromoters = 0,
    this.requiredSalesPartners = 0,
    this.requiredSeniorSalesPartners = 0,
    this.requiredSubDealers = 0,
    this.requiredDealers = 0,
    this.requiredSeniorDealers = 0,
    this.requiredMasterDealers = 0,
  });
  
  bool isQualified({
    required bool packagePurchased,
    required int directCustomers,
    required int activeCustomers,
    required int brandPromoters,
    required int salesPartners,
    required int seniorSalesPartners,
    required int subDealers,
    required int dealers,
    required int seniorDealers,
    required int masterDealers,
  }) {
    if (requiresPackagePurchase && !packagePurchased) return false;
    if (directCustomers < requiredDirectCustomers) return false;
    if (activeCustomers < requiredActiveCustomers) return false;
    if (brandPromoters < requiredBrandPromoters) return false;
    if (salesPartners < requiredSalesPartners) return false;
    if (seniorSalesPartners < requiredSeniorSalesPartners) return false;
    if (subDealers < requiredSubDealers) return false;
    if (dealers < requiredDealers) return false;
    if (seniorDealers < requiredSeniorDealers) return false;
    if (masterDealers < requiredMasterDealers) return false;
    return true;
  }
}

class UserBadgePromoteService {
  static int getRoleRank(String roleName) {
    final normalized = roleName.toLowerCase().trim();
    switch (normalized) {
      case 'customer':
      case 'guest customer':
        return 1;
      case 'active customer':
      case 'reseller':
      case 'vendor':
        return 2;
      case 'brand promoter':
        return 3;
      case 'sales partner':
        return 4;
      case 'senior sales partner':
        return 5;
      case 'sub dealer':
        return 6;
      case 'dealer':
        return 7;
      case 'senior dealer':
        return 8;
      case 'master dealer':
        return 9;
      case 'regional distributor':
      case 'admin':
      case 'super admin':
        return 10;
      default:
        return 1;
    }
  }

  static String getNormalizedBadgeRole(String role) {
    final normalized = role.toLowerCase().trim();
    if (normalized == 'super admin' || normalized == 'admin') {
      return 'Regional Distributor';
    }
    if (normalized == 'reseller' || normalized == 'vendor') {
      return 'Active Customer';
    }
    return role;
  }

  static final List<UserBadgePromotionModel> badgesSequence = [
    UserBadgePromotionModel(
      badgeName: 'Customer',
      banglaLabel: 'কাস্টমার',
      rank: 1,
      iconName: 'person_outline',
      description: 'বিজনেস ক্লাবের প্রাথমিক সদস্য ব্যাজ।',
    ),
    UserBadgePromotionModel(
      badgeName: 'Active Customer',
      banglaLabel: 'সক্রিয় কাস্টমার',
      rank: 2,
      iconName: 'shopping_bag_outlined',
      description: 'মেম্বারশিপ প্যাকেজ ও রেফারেল কাস্টমার সমৃদ্ধ ব্যাজ।',
      requiresPackagePurchase: true,
      requiredDirectCustomers: 30,
    ),
    UserBadgePromotionModel(
      badgeName: 'Brand Promoter',
      banglaLabel: 'ব্র্যান্ড প্রমোটার',
      rank: 3,
      iconName: 'campaign_outlined',
      description: 'মার্কেটিং ও প্রমোশন নেটওয়ার্কের প্রথম ধাপ।',
      requiredActiveCustomers: 50,
    ),
    UserBadgePromotionModel(
      badgeName: 'Sales Partner',
      banglaLabel: 'সেলস পার্টনার',
      rank: 4,
      iconName: 'handshake_outlined',
      description: 'বিক্রয় ও নেটওয়ার্ক টিম পার্টনার।',
      requiredActiveCustomers: 100,
      requiredBrandPromoters: 15,
    ),
    UserBadgePromotionModel(
      badgeName: 'Senior Sales Partner',
      banglaLabel: 'সিনিয়র সেলস পার্টনার',
      rank: 5,
      iconName: 'business_center_outlined',
      description: 'টিম লিডার ও সিনিয়র বিক্রয় পার্টনার।',
      requiredActiveCustomers: 150,
      requiredBrandPromoters: 25,
      requiredSalesPartners: 10,
    ),
    UserBadgePromotionModel(
      badgeName: 'Sub Dealer',
      banglaLabel: 'সাব ডিলার',
      rank: 6,
      iconName: 'storefront_outlined',
      description: 'বিজনেস ক্লাবের মধ্যবর্তী ডিলারশিপ পর্যায়।',
      requiredActiveCustomers: 250,
      requiredBrandPromoters: 35,
      requiredSalesPartners: 25,
      requiredSeniorSalesPartners: 10,
    ),
    UserBadgePromotionModel(
      badgeName: 'Dealer',
      banglaLabel: 'ডিলার',
      rank: 7,
      iconName: 'store_outlined',
      description: 'স্বীকৃত ডিলার ও বৃহৎ নেটওয়ার্ক প্রধান।',
      requiredActiveCustomers: 400,
      requiredBrandPromoters: 50,
      requiredSalesPartners: 40,
      requiredSeniorSalesPartners: 25,
      requiredSubDealers: 5,
    ),
    UserBadgePromotionModel(
      badgeName: 'Senior Dealer',
      banglaLabel: 'সিনিয়র ডিলার',
      rank: 8,
      iconName: 'domain_outlined',
      description: 'সিনিয়র ডিলারশিপ ও উচ্চ পর্যায়ের টিম পরিচালনা।',
      requiredActiveCustomers: 500,
      requiredBrandPromoters: 75,
      requiredSalesPartners: 65,
      requiredSeniorSalesPartners: 45,
      requiredSubDealers: 15,
      requiredDealers: 5,
    ),
    UserBadgePromotionModel(
      badgeName: 'Master Dealer',
      banglaLabel: 'মাস্টার ডিলার',
      rank: 9,
      iconName: 'workspace_premium_outlined',
      description: 'মাস্টার ডিলারশিপ ও ডিস্ট্রিবিউশন লিডার।',
      requiredActiveCustomers: 709,
      requiredBrandPromoters: 89,
      requiredSalesPartners: 89,
      requiredSubDealers: 39,
      requiredDealers: 19,
      requiredSeniorDealers: 9,
    ),
    UserBadgePromotionModel(
      badgeName: 'Regional Distributor',
      banglaLabel: 'রিজিওনাল ডিস্ট্রিবিউটর',
      rank: 10,
      iconName: 'local_shipping_outlined',
      description: 'সর্বোচ্চ বিজনেস ক্লাব পদবী ও আঞ্চলিক বিতরণ প্রধান।',
      requiredActiveCustomers: 1000,
      requiredBrandPromoters: 100,
      requiredSalesPartners: 100,
      requiredSubDealers: 100,
      requiredDealers: 100,
      requiredSeniorDealers: 50,
      requiredMasterDealers: 50,
    ),
  ];

  // Helper method to fetch and check if a user is promoted
  static Future<Map<String, dynamic>> checkAndPromoteUser(String userMobile) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // 1. Fetch all users to construct downline mapping in O(N)
      final usersSnapshot = await firestore.collection('users').get();
      final Map<String, Map<String, dynamic>> allUsersByCode = {};
      final Map<String, Map<String, dynamic>> allUsersByMobile = {};

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final code = data['referralCode'] as String?;
        final mob = data['mobile'] as String? ?? doc.id;
        if (code != null && code.trim().isNotEmpty) {
          allUsersByCode[code.trim()] = data;
        }
        allUsersByMobile[mob.trim()] = data;
      }

      final currentUser = allUsersByMobile[userMobile.trim()];
      if (currentUser == null) {
        return {'success': false, 'message': 'ইউজার পাওয়া যায়নি।'};
      }

      final currentRoleStr = currentUser['role'] as String? ?? 'Customer';
      final currentReferralCode = currentUser['referralCode'] as String? ?? '';
      final packagePurchased = currentUser['packagePurchased'] as bool? ?? false;

      // 2. Build downline list and calculate metrics recursively
      int directCustomers = 0;
      int activeCustomers = 0;
      int brandPromoters = 0;
      int salesPartners = 0;
      int seniorSalesPartners = 0;
      int subDealers = 0;
      int dealers = 0;
      int seniorDealers = 0;
      int masterDealers = 0;

      // For Active Customer, they can refer anyone (even regular Customer) to get their 30 count.
      // So we count ALL direct references.
      if (currentReferralCode.isNotEmpty) {
        final directRefs = allUsersByCode.values.where((user) {
          final referredBy = user['referredBy'] as String?;
          return referredBy != null && referredBy.trim() == currentReferralCode;
        });
        directCustomers = directRefs.length;

        void traverseDownline(String parentCode) {
          final children = allUsersByCode.values.where((user) {
            final referredBy = user['referredBy'] as String?;
            return referredBy != null && referredBy.trim() == parentCode;
          }).toList();

          for (var child in children) {
            final childCode = (child['referralCode'] as String? ?? '').trim();
            final childRole = (child['role'] as String? ?? 'Customer');
            final childRank = getRoleRank(childRole);

            if (childCode.isEmpty) continue;

            // Cumulative counting based on rank
            if (childRank >= 2) activeCustomers++;
            if (childRank >= 3) brandPromoters++;
            if (childRank >= 4) salesPartners++;
            if (childRank >= 5) seniorSalesPartners++;
            if (childRank >= 6) subDealers++;
            if (childRank >= 7) dealers++;
            if (childRank >= 8) seniorDealers++;
            if (childRank >= 9) masterDealers++;

            // Recurse down
            traverseDownline(childCode);
          }
        }

        traverseDownline(currentReferralCode);
      }

      // Find current badge index in sequence
      final normalizedRole = getNormalizedBadgeRole(currentRoleStr);
      final currentBadgeIndex = badgesSequence.indexWhere(
        (b) => b.badgeName.toLowerCase().trim() == normalizedRole.toLowerCase().trim()
      );

      if (currentBadgeIndex == -1) {
        return {
          'success': false,
          'message': 'ইউজারের রোল খুঁজে পাওয়া যায়নি।',
          'currentBadge': currentRoleStr,
          'canUpgrade': false
        };
      }

      // Check if there is a next badge to promote to
      if (currentBadgeIndex >= badgesSequence.length - 1) {
        return {
          'success': false,
          'message': 'অভিনন্দন! আপনি ইতোমধ্যে সর্বোচ্চ রিজিওনাল ডিস্ট্রিবিউটর ব্যাজে আছেন।',
          'currentBadge': currentRoleStr,
          'canUpgrade': false
        };
      }

      final nextBadge = badgesSequence[currentBadgeIndex + 1];

      // Check qualification
      final qualified = nextBadge.isQualified(
        packagePurchased: packagePurchased,
        directCustomers: directCustomers,
        activeCustomers: activeCustomers,
        brandPromoters: brandPromoters,
        salesPartners: salesPartners,
        seniorSalesPartners: seniorSalesPartners,
        subDealers: subDealers,
        dealers: dealers,
        seniorDealers: seniorDealers,
        masterDealers: masterDealers,
      );

      if (qualified) {
        // Perform promotion in Firestore
        await firestore.collection('users').doc(userMobile.trim()).update({
          'role': nextBadge.badgeName,
        });

        return {
          'success': true,
          'message': 'অভিনন্দন! আপনি সফলভাবে "${nextBadge.banglaLabel}" ব্যাজে উন্নীত হয়েছেন।',
          'promotedTo': nextBadge.badgeName,
          'promotedToBangla': nextBadge.banglaLabel,
          'canUpgrade': true
        };
      }

      return {
        'success': false,
        'message': 'আপনি পরবর্তী ব্যাজের শর্তাবলী পূরণ করেননি।',
        'nextBadge': nextBadge.banglaLabel,
        'canUpgrade': false
      };
    } catch (e) {
      debugPrint('Error checking user badge promotion: $e');
      return {'success': false, 'message': 'সার্ভার ত্রুটি ঘটেছে: $e', 'canUpgrade': false};
    }
  }

  static Future<Map<String, dynamic>> fetchPromotionMetrics(String userMobile) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final usersSnapshot = await firestore.collection('users').get();
      final Map<String, Map<String, dynamic>> allUsersByCode = {};
      final Map<String, Map<String, dynamic>> allUsersByMobile = {};

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final code = data['referralCode'] as String?;
        final mob = data['mobile'] as String? ?? doc.id;
        if (code != null && code.trim().isNotEmpty) {
          allUsersByCode[code.trim()] = data;
        }
        allUsersByMobile[mob.trim()] = data;
      }

      final currentUser = allUsersByMobile[userMobile.trim()];
      if (currentUser == null) {
        return {'success': false, 'message': 'ইউজার পাওয়া যায়নি।'};
      }

      final currentRoleStr = currentUser['role'] as String? ?? 'Customer';
      final currentReferralCode = currentUser['referralCode'] as String? ?? '';
      final packagePurchased = currentUser['packagePurchased'] as bool? ?? false;

      int directCustomers = 0;
      int activeCustomers = 0;
      int brandPromoters = 0;
      int salesPartners = 0;
      int seniorSalesPartners = 0;
      int subDealers = 0;
      int dealers = 0;
      int seniorDealers = 0;
      int masterDealers = 0;

      if (currentReferralCode.isNotEmpty) {
        final directRefs = allUsersByCode.values.where((user) {
          final referredBy = user['referredBy'] as String?;
          return referredBy != null && referredBy.trim() == currentReferralCode;
        });
        directCustomers = directRefs.length;

        void traverseDownline(String parentCode) {
          final children = allUsersByCode.values.where((user) {
            final referredBy = user['referredBy'] as String?;
            return referredBy != null && referredBy.trim() == parentCode;
          }).toList();

          for (var child in children) {
            final childCode = (child['referralCode'] as String? ?? '').trim();
            final childRole = (child['role'] as String? ?? 'Customer');
            final childRank = getRoleRank(childRole);

            if (childCode.isEmpty) continue;

            if (childRank >= 2) activeCustomers++;
            if (childRank >= 3) brandPromoters++;
            if (childRank >= 4) salesPartners++;
            if (childRank >= 5) seniorSalesPartners++;
            if (childRank >= 6) subDealers++;
            if (childRank >= 7) dealers++;
            if (childRank >= 8) seniorDealers++;
            if (childRank >= 9) masterDealers++;

            traverseDownline(childCode);
          }
        }

        traverseDownline(currentReferralCode);
      }

      return {
        'success': true,
        'role': getNormalizedBadgeRole(currentRoleStr),
        'packagePurchased': packagePurchased,
        'directCustomers': directCustomers,
        'activeCustomers': activeCustomers,
        'brandPromoters': brandPromoters,
        'salesPartners': salesPartners,
        'seniorSalesPartners': seniorSalesPartners,
        'subDealers': subDealers,
        'dealers': dealers,
        'seniorDealers': seniorDealers,
        'masterDealers': masterDealers,
      };
    } catch (e) {
      debugPrint('Error fetching promotion metrics: $e');
      return {'success': false, 'message': 'ত্রুটি: $e'};
    }
  }
}
