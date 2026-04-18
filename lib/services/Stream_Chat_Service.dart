import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:tech_app/core/network/dio_client.dart';

class StreamChatService {
  static final StreamChatService _instance = StreamChatService._internal();

  factory StreamChatService() => _instance;

  StreamChatService._internal();

  final _dio = DioClient.dio;

  late final StreamChatClient _client = StreamChatClient(
    '3e97f3da7ndg',
    logLevel: Level.INFO,
  );

  StreamChatClient get client => _client;

  bool _isConnected = false;

  Future<String> _getToken(String userId) async {
    final response = await _dio.post(
      'stream-chat/token',
      data: {'userId': userId, 'role': 'admin'},
    );
    return response.data['token'];
  }

  /// Connect only if not already connected as this user
  Future<void> connectUserIfNeeded(String userId) async {
    if (_isConnected && _client.state.currentUser?.id == userId) {
      return;
    }

    if (_client.state.currentUser != null) {
      await _client.disconnectUser();
    }

    final token = await _getToken(userId);

    await _client.connectUser(
      User(id: userId),
      token,
    );

    _isConnected = true;
    print("Technician connected to Stream ✅");

    // Register FCM token so Stream Chat can deliver push notifications
    await registerFCMToken();
  }

  /// Register FCM device token with Stream Chat for push notifications
  Future<void> registerFCMToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && _client.state.currentUser != null) {
        await _client.addDevice(
          fcmToken,
          PushProvider.firebase,
          pushProviderName: 'firebase-tech',
        );
        print("✅ FCM token registered with Stream Chat (firebase-tech)");
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        if (_client.state.currentUser != null) {
          await _client.addDevice(
            newToken,
            PushProvider.firebase,
            pushProviderName: 'firebase-tech',
          );
          print("✅ Refreshed FCM token registered with Stream Chat (firebase-tech)");
        }
      });
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  Future<void> disconnect() async {
    if (_client.state.currentUser != null) {
      await _client.disconnectUser();
      _isConnected = false;
    }
  }
}
