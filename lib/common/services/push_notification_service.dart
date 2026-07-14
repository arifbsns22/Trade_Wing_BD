import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_wign_bd/features/auth/presentation/controllers/auth_controller.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint("Background message data: ${message.data}");
}

class PushNotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<PushNotificationService> init() async {
    // 1. Request permissions for notifications
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // 2. Initialize Local Notifications for foreground display
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            if (notificationResponse.payload != null) {
              try {
                final Map<String, dynamic> data = jsonDecode(
                  notificationResponse.payload!,
                );
                _handlePayload(data);
              } catch (e) {
                debugPrint("Error decoding notification payload: $e");
              }
            }
          },
    );

    // 3. Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 4. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        _localNotificationsPlugin.show(
          id: message.notification.hashCode,
          title: message.notification?.title,
          body: message.notification?.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 5. Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 6. Handle initial message if app was terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      _handlePayload(initialMessage.data);
    }

    // 7. Handle app open from background state via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handlePayload(message.data);
    });

    // 8. Print token for testing
    String? token = await _fcm.getToken();
    debugPrint("FCM Token: $token");

    // Save FCM token if already logged in and start listening
    saveTokenToUserDocument();
    startNotificationListener();

    return this;
  }

  void _handlePayload(Map<String, dynamic> data) {
    debugPrint("Routing with payload: $data");

    // Check if there is a specific 'type' of notification
    if (data.containsKey('type')) {
      String type = data['type'];

      switch (type) {
        case 'order_confirmation':
          // TODO: Replace with Get.to(() => OrderHistoryScreen()) or Get.toNamed('/order_history')
          Get.snackbar(
            "Order Confirmed! 🎉",
            "Taking you to your order history...",
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            colorText: Colors.black87,
            borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
            borderWidth: 1,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
          break;

        case 'shipping_update':
          String orderId = data['order_id'] ?? 'Unknown';
          // TODO: Replace with Get.to(() => OrderTrackingScreen(orderId: orderId))
          Get.snackbar(
            "Shipping Update 🚚",
            "Update for Order #$orderId",
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            colorText: Colors.black87,
            borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
            borderWidth: 1,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
          break;

        case 'abandoned_cart':
          // TODO: Replace with Get.to(() => CartScreen())
          Get.snackbar(
            "Forgot something? 🛒",
            "Your cart is waiting for you!",
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            colorText: Colors.black87,
            borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
            borderWidth: 1,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
          break;

        default:
          Get.snackbar(
            "Notification",
            "Payload: $data",
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            colorText: Colors.black87,
            borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
            borderWidth: 1,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
      }
    }
    // Fallback to basic string routing if 'route' is provided directly
    else if (data.containsKey('route')) {
      String route = data['route'];
      Get.toNamed(route, arguments: data);
    } else {
      Get.snackbar(
        "Notification Tapped",
        "Payload: $data",
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        colorText: Colors.black87,
        borderColor: const Color(0xFF08B3AC).withValues(alpha: 0.2),
        borderWidth: 1,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> saveTokenToUserDocument() async {
    try {
      final authController = Get.find<AuthController>();
      final mobile = authController.currentUserMobile.value;
      if (mobile.isNotEmpty) {
        String? token = await _fcm.getToken();
        if (token != null) {
          await FirebaseFirestore.instance.collection('users').doc(mobile).update({
            'fcmToken': token,
          });
          debugPrint("FCM Token saved to Firestore for user $mobile");
        }
      }
    } catch (e) {
      debugPrint("Error saving FCM Token to user document: $e");
    }
  }

  void startNotificationListener() {
    try {
      final authController = Get.find<AuthController>();
      final mobile = authController.currentUserMobile.value;
      final role = authController.currentUserRole.value;
      final bool isUserAdmin = role == 'Super Admin' || role == 'Admin';

      if (mobile.isEmpty && !isUserAdmin) return;

      Query query = FirebaseFirestore.instance.collection('notifications');
      if (isUserAdmin) {
        query = query.where('isAdmin', isEqualTo: true);
      } else {
        query = query.where('userMobile', isEqualTo: mobile);
      }

      final DateTime startTime = DateTime.now();

      query
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data() as Map<String, dynamic>?;
            if (data != null) {
              final title = data['title'] ?? 'Notification';
              final body = data['body'] ?? '';
              _showLocalNotification(title, body, data);
            }
          }
        }
      }, onError: (e) {
        debugPrint("Error in notification snapshot listener: $e");
      });
    } catch (e) {
      debugPrint("Error starting notification listener: $e");
    }
  }

  void _showLocalNotification(String title, String body, Map<String, dynamic> payload) {
    try {
      _localNotificationsPlugin.show(
        id: title.hashCode,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(payload),
      );
    } catch (e) {
      debugPrint("Error showing local notification: $e");
    }
  }
}
