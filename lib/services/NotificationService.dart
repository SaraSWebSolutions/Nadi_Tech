import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/routes/route_name.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static GoRouter? _router;

  static void setRouter(GoRouter router) {
    _router = router;
  }

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Navigate to the correct screen when user taps a notification
  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.startsWith('chat:')) {
      // Navigate to the bottom nav (live chat tab) when chat notification is tapped
      _router?.go(RouteName.bottom_nav);
    }
  }

  static Future<void> createChannel() async {
    // General / OTP channel
    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for OTP and general notifications',
      importance: Importance.high,
    );

    // Chat messages channel
    const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      'chat_messages_channel',
      'Chat Messages',
      description: 'Used for incoming chat message notifications',
      importance: Importance.high,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(generalChannel);
    await android?.createNotificationChannel(chatChannel);
  }

  static Future<void> show({
    required String title,
    required String body,
    String? channelId,
    String? channelName,
    String? payload,
  }) async {
    final resolvedChannelId = channelId ?? 'high_importance_channel';
    final resolvedChannelName = channelName ?? 'High Importance Notifications';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          resolvedChannelId,
          resolvedChannelName,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
