import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trade_wign_bd/features/admin/traning/domain/models/training_model.dart';
import 'package:trade_wign_bd/features/admin/traning/presentation/controllers/training_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/features/users/traning/presentation/screens/training_video_detail_screen.dart';
import 'package:trade_wign_bd/features/users/traning/presentation/widgets/physical_training_detail_sheet.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class UserTraningScreen extends StatefulWidget {
  const UserTraningScreen({super.key});

  @override
  State<UserTraningScreen> createState() => _UserTraningScreenState();
}

class _UserTraningScreenState extends State<UserTraningScreen> {
  String _selectedTab = 'all'; // 'all', 'physical', 'video'

  @override
  Widget build(BuildContext context) {
    final TrainingController controller = Get.put(TrainingController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text(
          'ট্রেনিং',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final currentMobile = authController.currentUserMobile.value.trim();
        final userId = currentMobile.isNotEmpty ? currentMobile : 'guest_user';
        if (controller.isLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Skeleton Stats Header
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSkeletonCard(),
                _buildSkeletonCard(),
                _buildSkeletonCard(),
              ],
            ),
          );
        }

        final currentUserRole = authController.currentUserRole.value
            .toLowerCase()
            .trim();

        // Filter active trainings assigned to user's role
        final userTrainings = controller.trainings.where((t) {
          if (t.status != 'active') return false;

          final target = t.targetedRole.toLowerCase().trim();
          if (target == 'all') return true;
          if (target == currentUserRole) return true;

          if (currentUserRole == 'guest customer' &&
              (target == 'customer' || target == 'guest')) {
            return true;
          }

          if (currentUserRole == 'super admin' || currentUserRole == 'admin')
            return true;

          return false;
        }).toList();

        final filteredList = userTrainings.where((t) {
          if (_selectedTab != 'all' && t.type != _selectedTab) return false;
          return true;
        }).toList();

        return StreamBuilder<QuerySnapshot>(
          stream: controller.getUserCompletionsStream(userId),
          builder: (context, snapshot) {
            final Set<String> completedTrainingIds = {};

            if (snapshot.hasData && snapshot.data != null) {
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>?;
                String? tId = data?['trainingId'] as String? ?? doc.id;

                if (tId.isNotEmpty) {
                  completedTrainingIds.add(tId);
                }
              }
            }

            final totalCount = userTrainings.length;
            final completedCount = userTrainings
                .where((t) => completedTrainingIds.contains(t.id))
                .length;
            final pendingCount = (totalCount - completedCount).clamp(
              0,
              totalCount,
            );
            final double progressRatio = totalCount > 0
                ? (completedCount / totalCount)
                : 0.0;
            final int progressPercent = (progressRatio * 100).toInt();

            return Column(
              children: [
                // User Role Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium_outlined,
                          color: AppColors.green,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'আপনার বর্তমান ব্যাজ অনুযায়ী ট্রেনিং তালিকা',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            TrainingController.getRoleBangla(
                              authController.currentUserRole.value,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Real-time Progress Tracking Card Header
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildProgressStatTile(
                              title: 'মোট ট্রেনিং',
                              count: '$totalCount টি',
                              icon: Icons.school_outlined,
                              color: const Color(0xFF0066CC),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.grey.shade200,
                          ),
                          Expanded(
                            child: _buildProgressStatTile(
                              title: 'সম্পন্ন',
                              count: '$completedCount টি',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.green,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.grey.shade200,
                          ),
                          Expanded(
                            child: _buildProgressStatTile(
                              title: 'বাকি আছে',
                              count: '$pendingCount টি',
                              icon: Icons.hourglass_top_rounded,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Progress Title & Percentage Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 16,
                                color: AppColors.green,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'আপনার মোট ট্রেনিং অগ্রগতি',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$progressPercent%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Styled Linear Progress Indicator
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar Segmented Filter
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTabButton('all', 'সবগুলো')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTabButton('physical', 'ফিজিক্যাল মিটিং'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTabButton('video', 'ভিডিও ট্রেনিং'),
                      ),
                    ],
                  ),
                ),

                // Main Training Stream List
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 56,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'বর্তমানে কোনো ট্রেনিং পাওয়া যায়নি',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'নতুন ট্রেনিং যুক্ত হলে এখানে প্রদর্শিত হবে',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final isCompleted = completedTrainingIds.contains(
                              item.id,
                            );
                            return _buildUserTrainingCard(
                              context,
                              item,
                              isCompleted,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildProgressStatTile({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String tabKey, String label) {
    final isSelected = _selectedTab == tabKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.green : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTrainingCard(
    BuildContext context,
    TrainingModel item,
    bool isCompleted,
  ) {
    final isPhysical = item.isPhysical;
    final ytId = item.youtubeVideoId;
    final thumbnailUrl = ytId != null
        ? 'https://img.youtube.com/vi/$ytId/hqdefault.jpg'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail Preview (For Video Type)
          if (!isPhysical && thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    thumbnailUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(
                          Icons.video_library_rounded,
                          size: 48,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 160,
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  IconButton(
                    iconSize: 52,
                    icon: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Get.to(() => TrainingVideoDetailScreen(training: item));
                    },
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type & Completion Badges Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPhysical
                            ? const Color(0xFFEBF5FF)
                            : const Color(0xFFFFEFEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPhysical
                                ? Icons.groups_rounded
                                : Icons.video_library_rounded,
                            size: 14,
                            color: isPhysical
                                ? const Color(0xFF0066CC)
                                : const Color(0xFFD9381E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPhysical
                                ? 'ফিজিক্যাল মিটিং'
                                : 'অনলাইন ভিডিও ট্রেনিং',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPhysical
                                  ? const Color(0xFF0066CC)
                                  : const Color(0xFFD9381E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Completion Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.shade50
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green.shade300
                              : Colors.amber.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.hourglass_empty_rounded,
                            size: 13,
                            color: isCompleted
                                ? Colors.green.shade700
                                : Colors.amber.shade900,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted ? 'সম্পন্ন' : 'বাকি আছে',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.green.shade700
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Physical Details Box
                if (isPhysical) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'তারিখ: ${item.date ?? ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'সময়: ${item.startTime ?? ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (item.location != null &&
                            item.location!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'স্থান: ${item.location}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isPhysical) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              PhysicalTrainingDetailSheet(training: item),
                        );
                      } else {
                        Get.to(() => TrainingVideoDetailScreen(training: item));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPhysical
                          ? AppColors.green
                          : Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      isPhysical
                          ? Icons.info_outline_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isPhysical
                          ? 'বিস্তারিত ও সময়সূচী দেখুন'
                          : 'ভিডিও ট্রেনিং প্লে করুন',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
