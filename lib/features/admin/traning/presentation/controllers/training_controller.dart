import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/common/services/notification_helper.dart';
import 'package:trade_wign_bd/features/admin/traning/domain/models/training_model.dart';
import 'package:trade_wign_bd/uitls/constants/app_colors.dart';

class TrainingController extends GetxController {
  static TrainingController get instance => Get.find<TrainingController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive States
  final RxBool isLoading = false.obs;
  final RxList<TrainingModel> trainings = <TrainingModel>[].obs;
  final RxSet<String> userCompletedTrainingIds = <String>{}.obs;
  final List<StreamSubscription> _attendanceSubscriptions = [];
  String _activeProgressUserId = '';

  // Filtering & Search states
  final RxString selectedRoleFilter = 'all'.obs;
  final RxString selectedTypeFilter = 'all'.obs; // 'all', 'physical', 'video'
  final RxString searchQuery = ''.obs;

  // Roles Definition aligned with Business Club progression sequence
  static const Map<String, String> roleMap = {
    'all': 'সকল ইউজার',
    'customer': 'কাস্টমার',
    'active customer': 'সক্রিয় কাস্টমার',
    'brand promoter': 'ব্র্যান্ড প্রমোটার',
    'sales partner': 'সেলস পার্টনার',
    'senior sales partner': 'সিনিয়র সেলস পার্টনার',
    'sub dealer': 'সাব ডিলার',
    'dealer': 'ডিলার',
    'senior dealer': 'সিনিয়র ডিলার',
    'master dealer': 'মাস্টার ডিলার',
    'regional distributor': 'রিজিওনাল ডিস্ট্রিবিউটর',
  };

  @override
  void onInit() {
    super.onInit();
    fetchTrainings();
  }

  /// Listen to real-time updates from Firestore 'trainings' collection
  void fetchTrainings() {
    isLoading.value = true;
    _firestore
        .collection('trainings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            trainings.value = snapshot.docs
                .map((doc) => TrainingModel.fromFirestore(doc))
                .toList();
            isLoading.value = false;
          },
          onError: (error) {
            debugPrint('Error fetching trainings: $error');
            isLoading.value = false;
          },
        );
  }

  /// Filtered list based on role, type, and search query
  List<TrainingModel> get filteredTrainings {
    return trainings.where((t) {
      // Role Filter
      if (selectedRoleFilter.value != 'all') {
        final target = t.targetedRole.toLowerCase().trim();
        final selected = selectedRoleFilter.value.toLowerCase().trim();
        if (target != 'all' && target != selected) {
          return false;
        }
      }

      // Type Filter
      if (selectedTypeFilter.value != 'all') {
        if (t.type != selectedTypeFilter.value) {
          return false;
        }
      }

      // Search Query
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.trim().toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchDesc = t.description.toLowerCase().contains(query);
        final matchLocation = (t.location ?? '').toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchLocation) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Add New Training
  Future<bool> addTraining(TrainingModel training) async {
    try {
      isLoading.value = true;
      await _firestore.collection('trainings').add(training.toFirestore());

      Get.snackbar(
        'সফল',
        'নতুন ট্রেনিংটি সফলভাবে যুক্ত করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.green.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('Error adding training: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'ট্রেনিং যুক্ত করা যায়নি: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.green.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update Existing Training
  Future<bool> updateTraining(String id, TrainingModel training) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection('trainings')
          .doc(id)
          .update(training.toFirestore());

      Get.snackbar(
        'সফল',
        'ট্রেনিংয়ের তথ্য আপডেট করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.green.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating training: $e');
      Get.snackbar(
        'ব্যর্থতা',
        'ট্রেনিং আপডেট করা যায়নি: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.green.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle Status (Active / Inactive)
  Future<void> toggleTrainingStatus(TrainingModel training) async {
    if (training.id == null) return;
    final newStatus = training.status == 'active' ? 'inactive' : 'active';
    try {
      await _firestore.collection('trainings').doc(training.id).update({
        'status': newStatus,
      });
      Get.snackbar(
        'স্ট্যাটাস পরিবর্তিত',
        'ট্রেনিং স্ট্যাটাস ${newStatus == 'active' ? 'সক্রিয়' : 'নিষ্ক্রিয়'} করা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.green.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  /// Delete Training
  Future<void> deleteTraining(String id) async {
    try {
      await _firestore.collection('trainings').doc(id).delete();
      Get.snackbar(
        'সফল',
        'ট্রেনিংটি মুছে ফেলা হয়েছে',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.primaryColor.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Error deleting training: $e');
      Get.snackbar(
        'ত্রুটি',
        'ট্রেনিং মোছা যায়নি: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.primaryColor.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  static String getRoleBangla(String roleKey) {
    final keyLower = roleKey.toLowerCase().trim();
    return roleMap[keyLower] ?? roleKey;
  }

  /// Mark attendance for a physical training
  Future<bool> markAttendance({
    required String trainingId,
    required String userId,
    required String userName,
    required String userPhone,
    required String userRole,
    TrainingModel? training,
  }) async {
    if (training != null && !isTrainingStarted(training)) {
      Get.snackbar(
        'মিটিং শুরু হয়নি',
        'নির্ধারিত মিটিং শুরুর সময়সূচীতে উপস্থিতি জমা দিন।',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.amber.withValues(alpha: 0.5),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    try {
      isLoading.value = true;
      final attendanceDoc = _firestore
          .collection('trainings')
          .doc(trainingId)
          .collection('attendance')
          .doc(userId);

      await attendanceDoc.set({
        'trainingId': trainingId,
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'userRole': userRole,
        'status': 'present',
        'type': 'physical',
        'markedAt': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_trainings')
          .doc(trainingId)
          .set({
        'trainingId': trainingId,
        'type': 'physical',
        'completedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'উপস্থিতি সফল',
        'ফিজিক্যাল মিটিংয়ে আপনার উপস্থিতি সফলভাবে স্থান দেয়া হয়েছে!',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: AppColors.green.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      Get.snackbar(
        'ত্রুটি',
        'উপস্থিতি জমা দেওয়া যায়নি: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Real-time stream of user attendance status for a training
  Stream<DocumentSnapshot> getAttendanceStream(
    String trainingId,
    String userId,
  ) {
    return _firestore
        .collection('trainings')
        .doc(trainingId)
        .collection('attendance')
        .doc(userId)
        .snapshots();
  }

  /// Real-time stream of all attendees for admin view
  Stream<QuerySnapshot> getAttendeesStream(String trainingId) {
    return _firestore
        .collection('trainings')
        .doc(trainingId)
        .collection('attendance')
        .orderBy('markedAt', descending: true)
        .snapshots();
  }

  /// Helper to check if training start time has arrived or passed
  bool isTrainingStarted(TrainingModel training) {
    if (training.date == null || training.date!.isEmpty) return true;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime? trainingDate;

      final dateStr = training.date!.trim();

      // 1. Try standard ISO parse
      trainingDate = DateTime.tryParse(dateStr);

      // 2. Try parsing formatted dates like "22 Jul 2026", "22 July 2026", "22-07-2026", "22/07/2026"
      if (trainingDate == null) {
        final monthMap = {
          'jan': 1, 'january': 1,
          'feb': 2, 'february': 2,
          'mar': 3, 'march': 3,
          'apr': 4, 'april': 4,
          'may': 5,
          'jun': 6, 'june': 6,
          'jul': 7, 'july': 7,
          'aug': 8, 'august': 8,
          'sep': 9, 'september': 9,
          'oct': 10, 'october': 10,
          'nov': 11, 'november': 11,
          'dec': 12, 'december': 12,
        };

        final parts = dateStr.split(RegExp(r'[\s\/\-\,]+'));
        if (parts.length >= 3) {
          int? day;
          int? month;
          int? year;

          for (var part in parts) {
            final pLower = part.toLowerCase();
            if (monthMap.containsKey(pLower)) {
              month = monthMap[pLower];
            } else if (part.length == 4 && int.tryParse(part) != null) {
              year = int.tryParse(part);
            } else if (int.tryParse(part) != null) {
              final val = int.parse(part);
              if (val > 12 && day == null) {
                day = val;
              } else if (day == null) {
                day = val;
              } else if (month == null && val <= 12) {
                month = val;
              }
            }
          }

          if (year != null && month != null && day != null) {
            trainingDate = DateTime(year, month, day);
          }
        }
      }

      if (trainingDate == null) {
        return true;
      }

      final targetDate = DateTime(trainingDate.year, trainingDate.month, trainingDate.day);

      // If training date is in the future (e.g. tomorrow)
      if (targetDate.isAfter(today)) return false;

      // If training date was in the past
      if (targetDate.isBefore(today)) return true;

      // If training date is TODAY, check start time
      if (training.startTime == null || training.startTime!.isEmpty) return true;

      final timeStr = training.startTime!.trim().toLowerCase();
      int hour = 0;
      int minute = 0;

      final isPm = timeStr.contains('pm');
      final isAm = timeStr.contains('am');
      final cleanTime = timeStr.replaceAll(RegExp(r'[^\d:]'), '');
      final timeParts = cleanTime.split(':');

      if (timeParts.isNotEmpty) {
        hour = int.tryParse(timeParts[0]) ?? 0;
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
        if (timeParts.length > 1) {
          minute = int.tryParse(timeParts[1]) ?? 0;
        }
      }

      final startTimeDateTime = DateTime(now.year, now.month, now.day, hour, minute);
      return now.isAfter(startTimeDateTime) || now.isAtSameMomentAs(startTimeDateTime);
    } catch (e) {
      debugPrint('Error parsing training date/time: $e');
      return true;
    }
  }

  /// Toggle Video Training completion status
  Future<bool> toggleVideoCompletion({
    required String trainingId,
    required String userId,
    required String userName,
    required String userPhone,
    required String userRole,
    required bool currentlyCompleted,
  }) async {
    try {
      isLoading.value = true;
      final docRef = _firestore
          .collection('trainings')
          .doc(trainingId)
          .collection('attendance')
          .doc(userId);

      if (currentlyCompleted) {
        await docRef.delete();
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('completed_trainings')
            .doc(trainingId)
            .delete();

        Get.snackbar(
          'স্ট্যাটাস হালনাগাদ',
          'ট্রেনিংটি অসম্পূর্ণ হিসেবে রিসেট করা হয়েছে',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: AppColors.green.withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await docRef.set({
          'trainingId': trainingId,
          'userId': userId,
          'userName': userName,
          'userPhone': userPhone,
          'userRole': userRole,
          'status': 'completed',
          'type': 'video',
          'markedAt': FieldValue.serverTimestamp(),
        });

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('completed_trainings')
            .doc(trainingId)
            .set({
          'trainingId': trainingId,
          'type': 'video',
          'completedAt': FieldValue.serverTimestamp(),
        });

        Get.snackbar(
          'ট্রেনিং সম্পন্ন! 🎉',
          'ভিডিও ট্রেনিংটি সফলভাবে সম্পন্ন হিসেবে চিহ্নিত করা হয়েছে!',
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          colorText: Colors.black87,
          borderColor: AppColors.green.withValues(alpha: 0.2),
          borderWidth: 1,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error toggling video completion: $e');
      Get.snackbar(
        'ত্রুটি',
        'স্ট্যাটাস পরিবর্তন করা যায়নি: $e',
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: Colors.red.withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  StreamSubscription? _userCompletionsSub;

  /// Automatically bind user's completed trainings subcollection stream
  void bindUserCompletions(String userId) {
    final cleanId = userId.trim();
    final targetId = cleanId.isNotEmpty ? cleanId : 'guest_user';

    if (_activeProgressUserId == targetId && _userCompletionsSub != null) return;
    _activeProgressUserId = targetId;

    _userCompletionsSub?.cancel();
    _userCompletionsSub = _firestore
        .collection('users')
        .doc(targetId)
        .collection('completed_trainings')
        .snapshots()
        .listen((snapshot) {
      final Set<String> ids = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        String? tId = data['trainingId'] as String? ?? doc.id;
        if (tId.isNotEmpty) {
          ids.add(tId);
        }
      }
      userCompletedTrainingIds.assignAll(ids);
    });
  }

  /// Listen directly to attendance docs for all user's trainings (Index-free real-time sync)
  void listenToUserProgress(String userId, List<TrainingModel> userTrainings) {
    bindUserCompletions(userId);
  }

  /// Realtime stream of all completions / attendances marked by a user
  Stream<QuerySnapshot> getUserCompletionsStream(String userId) {
    final cleanId = userId.trim();
    final targetId = cleanId.isNotEmpty ? cleanId : 'guest_user';
    return _firestore
        .collection('users')
        .doc(targetId)
        .collection('completed_trainings')
        .snapshots();
  }

  /// Checks if the user has completed all mandatory trainings for their role
  bool hasCompletedAllRequiredTrainings({
    required String userRole,
    required String userId,
  }) {
    return getPendingTrainingsCount(userRole: userRole, userId: userId) == 0;
  }

  /// Returns the number of pending mandatory trainings for a user's role
  int getPendingTrainingsCount({
    required String userRole,
    required String userId,
  }) {
    bindUserCompletions(userId);

    final cleanRole = userRole.toLowerCase().trim();
    if (cleanRole == 'super admin' || cleanRole == 'admin') return 0;

    final assignedTrainings = trainings.where((t) {
      if (t.status != 'active') return false;
      final target = t.targetedRole.toLowerCase().trim();
      if (target == 'all') return true;
      if (target == cleanRole) return true;
      if (cleanRole == 'guest customer' && (target == 'customer' || target == 'guest')) {
        return true;
      }
      return false;
    }).toList();

    if (assignedTrainings.isEmpty) return 0;

    final completedIds = userCompletedTrainingIds;
    final completedCount = assignedTrainings.where((t) => completedIds.contains(t.id)).length;

    return (assignedTrainings.length - completedCount).clamp(0, assignedTrainings.length);
  }

  /// Asynchronously returns the exact live number of pending mandatory trainings for a user's role
  Future<int> getPendingTrainingsCountAsync({
    required String userRole,
    required String userId,
  }) async {
    final cleanRole = userRole.toLowerCase().trim();
    if (cleanRole == 'super admin' || cleanRole == 'admin') return 0;

    final assignedTrainings = trainings.where((t) {
      if (t.status != 'active') return false;
      final target = t.targetedRole.toLowerCase().trim();
      if (target == 'all') return true;
      if (target == cleanRole) return true;
      if (cleanRole == 'guest customer' && (target == 'customer' || target == 'guest')) {
        return true;
      }
      return false;
    }).toList();

    if (assignedTrainings.isEmpty) return 0;

    final cleanId = userId.trim();
    final targetId = cleanId.isNotEmpty ? cleanId : 'guest_user';

    try {
      final snap = await _firestore
          .collection('users')
          .doc(targetId)
          .collection('completed_trainings')
          .get();

      final Set<String> completedIds = {};
      for (var doc in snap.docs) {
        final data = doc.data();
        String? tId = data['trainingId'] as String? ?? doc.id;
        if (tId.isNotEmpty) {
          completedIds.add(tId);
        }
      }
      userCompletedTrainingIds.assignAll(completedIds);

      final completedCount = assignedTrainings.where((t) => completedIds.contains(t.id)).length;
      return (assignedTrainings.length - completedCount).clamp(0, assignedTrainings.length);
    } catch (e) {
      debugPrint('Error fetching user completed trainings async: $e');
      return getPendingTrainingsCount(userRole: userRole, userId: userId);
    }
  }

  /// Sends a training mandatory notification to the user's notification box if incomplete
  Future<void> checkAndSendTrainingNotification({
    required String userId,
    required String userRole,
  }) async {
    final cleanId = userId.trim();
    if (cleanId.isEmpty || cleanId == 'guest_user') return;

    final pending = await getPendingTrainingsCountAsync(userRole: userRole, userId: cleanId);
    if (pending <= 0) return;

    try {
      final roleBangla = getRoleBangla(userRole);
      final existing = await _firestore
          .collection('notifications')
          .where('userMobile', isEqualTo: cleanId)
          .where('type', isEqualTo: 'training')
          .where('isRead', isEqualTo: false)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        await NotificationHelper.sendNotification(
          title: '🎓 ট্রেনিং সম্পন্ন করা আবশ্যক',
          body: 'আপনার রোল ($roleBangla)-এর জন্য $pending টি ট্রেনিং বাকি আছে। অ্যাপের সকল ফিচার ব্যবহার করতে অবিলম্বে ট্রেনিংগুলো সম্পন্ন করুন।',
          type: 'training',
          userMobile: cleanId,
        );
      }
    } catch (e) {
      debugPrint('Error sending training notification: $e');
    }
  }

  @override
  void onClose() {
    _userCompletionsSub?.cancel();
    for (var sub in _attendanceSubscriptions) {
      sub.cancel();
    }
    super.onClose();
  }
}
