import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingModel {
  final String? id;
  final String title;
  final String description;
  final String type; // 'physical' or 'video'
  final String targetedRole; // 'all', 'customer', 'brand promoter', etc.
  final String status; // 'active' or 'inactive'
  final DateTime? createdAt;

  // Physical Training Specific Fields
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? location;

  // Video Training Specific Fields
  final String? youtubeVideoId;
  final String? videoUrl;

  TrainingModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetedRole,
    this.status = 'active',
    this.createdAt,
    this.date,
    this.startTime,
    this.endTime,
    this.location,
    this.youtubeVideoId,
    this.videoUrl,
  });

  bool get isPhysical => type == 'physical';
  bool get isVideo => type == 'video';

  factory TrainingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return TrainingModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'physical',
      targetedRole: data['targetedRole'] ?? 'all',
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      date: data['date'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      location: data['location'],
      youtubeVideoId: data['youtubeVideoId'],
      videoUrl: data['videoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'targetedRole': targetedRole,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (date != null) 'date': date,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (location != null) 'location': location,
      if (youtubeVideoId != null) 'youtubeVideoId': youtubeVideoId,
      if (videoUrl != null) 'videoUrl': videoUrl,
    };
  }

  /// Helper to extract YouTube video ID from various YouTube URL formats
  static String? extractYoutubeId(String url) {
    if (url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) {
      return trimmed;
    }
    final RegExp regExp = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([\w-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(trimmed);
    return match?.group(1);
  }
}
