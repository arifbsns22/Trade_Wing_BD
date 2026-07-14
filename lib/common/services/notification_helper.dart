import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sends a real notification by adding a document to the `notifications` collection.
  static Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    String? userMobile,
    bool isAdmin = false,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'title': title,
        'body': body,
        'type': type,
        'userMobile': userMobile ?? '',
        'isAdmin': isAdmin,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("Notification added to Firestore: $title");
    } catch (e) {
      debugPrint("Error sending notification to Firestore: $e");
    }
  }
}
