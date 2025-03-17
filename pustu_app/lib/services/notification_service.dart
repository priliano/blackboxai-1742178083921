import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Request permission for iOS
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle FCM messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    _initialized = true;
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen based on payload
      // This will be handled by the app's navigation service
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await showNotification(
      title: message.notification?.title ?? 'Notifikasi',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    // Handle notification tap when app was in background
    // This will be handled by the app's navigation service
  }

  // This needs to be a top-level function
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background messages
    // Minimal processing as this runs in a separate isolate
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationImportance importance = NotificationImportance.high,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pustu_queue_channel',
      'Queue Notifications',
      channelDescription: 'Notifications for queue updates',
      importance: NotificationImportance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  Future<void> clearNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Helper methods for specific notification types
  Future<void> showQueueCalledNotification(int queueNumber) async {
    await showNotification(
      title: 'Antrian Anda Dipanggil',
      body: 'Nomor antrian $queueNumber silakan menuju ke loket pelayanan',
      payload: 'queue_called:$queueNumber',
    );
  }

  Future<void> showQueueReminderNotification(int queueNumber, int estimatedMinutes) async {
    await showNotification(
      title: 'Persiapan Antrian',
      body: 'Nomor antrian $queueNumber akan dipanggil dalam waktu sekitar $estimatedMinutes menit',
      payload: 'queue_reminder:$queueNumber',
    );
  }

  Future<void> showQueueSkippedNotification(int queueNumber) async {
    await showNotification(
      title: 'Antrian Dilewati',
      body: 'Nomor antrian $queueNumber telah dilewati, silakan konfirmasi ke petugas',
      payload: 'queue_skipped:$queueNumber',
    );
  }

  Future<void> showFeedbackRequestNotification(int queueNumber) async {
    await showNotification(
      title: 'Berikan Penilaian',
      body: 'Bagaimana pelayanan kami hari ini? Tap untuk memberikan penilaian.',
      payload: 'feedback_request:$queueNumber',
    );
  }
}
