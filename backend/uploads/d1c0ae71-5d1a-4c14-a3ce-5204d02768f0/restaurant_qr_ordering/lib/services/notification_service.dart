import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

/// Handles FCM token registration and local display of foreground
/// notifications. Actual push delivery (order placed -> chef, status
/// changed -> customer) is triggered server-side by a Cloud Function
/// that listens to Firestore writes (see /functions in repo root).
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(initSettings);

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'orders_channel',
      'Order Updates',
      channelDescription: 'Notifications for order status changes',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _local.show(
      message.hashCode,
      message.notification?.title ?? 'Restaurant Update',
      message.notification?.body ?? '',
      details,
    );
  }

  /// Persists the device FCM token against the user doc (chef/admin) or
  /// against the active order (customer) so a Cloud Function can target it.
  Future<void> registerTokenForUser(String userId) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<void> registerTokenForOrder(String orderId) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .set({'customerFcmToken': token}, SetOptions(merge: true));
  }
}
