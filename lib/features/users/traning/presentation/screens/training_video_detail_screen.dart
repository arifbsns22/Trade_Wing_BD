import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:trade_wign_bd/features/admin/traning/domain/models/training_model.dart';
import 'package:trade_wign_bd/features/admin/traning/presentation/controllers/training_controller.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

// Conditionally import HTML libraries for Web
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class TrainingVideoDetailScreen extends StatefulWidget {
  final TrainingModel training;

  const TrainingVideoDetailScreen({super.key, required this.training});

  @override
  State<TrainingVideoDetailScreen> createState() =>
      _TrainingVideoDetailScreenState();
}

class _TrainingVideoDetailScreenState extends State<TrainingVideoDetailScreen> {
  YoutubePlayerController? _mobileController;
  String? _videoId;
  String? _webRegisterKey;

  @override
  void initState() {
    super.initState();
    _videoId =
        widget.training.youtubeVideoId ??
        TrainingModel.extractYoutubeId(widget.training.videoUrl ?? '');

    if (_videoId != null && _videoId!.isNotEmpty) {
      if (kIsWeb) {
        _webRegisterKey =
            'youtube-iframe-$_videoId-${DateTime.now().millisecondsSinceEpoch}';
        ui_web.platformViewRegistry.registerViewFactory(_webRegisterKey!, (
          int viewId,
        ) {
          final iframe = web.HTMLIFrameElement()
            ..src =
                'https://www.youtube.com/embed/$_videoId?autoplay=1&rel=0&enablejsapi=1'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow =
                'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share'
            ..allowFullscreen = true;
          return iframe;
        });
      } else {
        _mobileController = YoutubePlayerController.fromVideoId(
          videoId: _videoId!,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
            strictRelatedVideos: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _mobileController?.close();
    }
    super.dispose();
  }

  Future<void> _launchExternalYouTube() async {
    final urlStr =
        widget.training.videoUrl ??
        'https://www.youtube.com/watch?v=${widget.training.youtubeVideoId}';
    final Uri uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.training;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ভিডিও ট্রেনিং',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Multiplatform Embedded In-App Player Container
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _videoId == null || _videoId!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red,
                              size: 44,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'ভিডিও আইডি পাওয়া যায়নি',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : kIsWeb
                    ? (_webRegisterKey != null
                          ? HtmlElementView(viewType: _webRegisterKey!)
                          : const Center(child: CircularProgressIndicator()))
                    : (_mobileController != null
                          ? YoutubePlayer(
                              controller: _mobileController!,
                              aspectRatio: 16 / 9,
                            )
                          : const Center(child: CircularProgressIndicator())),
              ),
            ),

            // Course Details Body Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Metadata Badges Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.video_library_rounded,
                              size: 14,
                              color: Colors.red,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'অনলাইন ভিডিও কোর্স',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          kIsWeb ? 'ওয়েব প্লেয়ার' : 'ইন-অ্যাপ প্লেয়ার',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Section Title
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ট্রেনিংয়ের বিবরণ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Description Body Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Video Completion Toggle Button
                  if (item.id != null)
                    Builder(
                      builder: (context) {
                        final TrainingController controller =
                            TrainingController.instance;
                        final AuthController authController =
                            Get.find<AuthController>();
                        final userId =
                            authController.currentUserMobile.value.isNotEmpty
                            ? authController.currentUserMobile.value
                            : 'guest_user';
                        final userName =
                            authController.currentUserName.value.isNotEmpty
                            ? authController.currentUserName.value
                            : 'সম্মানিত ইউজার';
                        final userMobile =
                            authController.currentUserMobile.value;
                        final userRole = authController.currentUserRole.value;

                        return StreamBuilder<DocumentSnapshot>(
                          stream: controller.getAttendanceStream(
                            item.id!,
                            userId,
                          ),
                          builder: (context, snapshot) {
                            final isCompleted =
                                snapshot.hasData && snapshot.data!.exists;

                            return Obx(() {
                              return SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () async {
                                          await controller
                                              .toggleVideoCompletion(
                                                trainingId: item.id!,
                                                userId: userId,
                                                userName: userName,
                                                userPhone: userMobile,
                                                userRole: userRole,
                                                currentlyCompleted: isCompleted,
                                              );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCompleted
                                        ? Colors.green.shade700
                                        : AppColors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: isCompleted ? 0 : 2,
                                  ),
                                  icon: controller.isLoading.value
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          isCompleted
                                              ? Icons.check_circle_rounded
                                              : Icons
                                                    .check_circle_outline_rounded,
                                          size: 20,
                                        ),
                                  label: Text(
                                    isCompleted
                                        ? 'ট্রেনিংটি সম্পন্ন হয়েছে (রিসেট করতে পুনরায় চাপুন)'
                                        : 'ট্রেনিং সম্পন্ন হিসেবে মার্ক করুন',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            });
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 12),

                  // External Open Fallback Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _launchExternalYouTube,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text(
                        'ইউটিউব অ্যাপে ভিডিওটি দেখুন',
                        style: TextStyle(
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
      ),
    );
  }
}
