import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

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

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (notificationResponse.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(notificationResponse.payload!);
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
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
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
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
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
            snackPosition: SnackPosition.TOP,
          );
          break;
          
        case 'shipping_update':
          String orderId = data['order_id'] ?? 'Unknown';
          // TODO: Replace with Get.to(() => OrderTrackingScreen(orderId: orderId))
          Get.snackbar(
            "Shipping Update 🚚", 
            "Update for Order #$orderId",
            snackPosition: SnackPosition.TOP,
          );
          break;
          
        case 'abandoned_cart':
          // TODO: Replace with Get.to(() => CartScreen())
          Get.snackbar(
            "Forgot something? 🛒", 
            "Your cart is waiting for you!",
            snackPosition: SnackPosition.TOP,
          );
          break;
          
        default:
          Get.snackbar("Notification", "Payload: $data", snackPosition: SnackPosition.TOP);
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
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
