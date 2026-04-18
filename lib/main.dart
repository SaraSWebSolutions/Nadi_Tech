import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/firebase_options.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/active_chat_provider.dart';
import 'package:tech_app/provider/language_provider.dart';
import 'package:tech_app/services/MqttNotificationService.dart';
import 'package:tech_app/provider/theme_provider.dart';
import 'package:tech_app/routes/app_route.dart';
import 'package:tech_app/services/NotificationService.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:tech_app/services/Stream_Chat_Service.dart';

final container = ProviderContainer();

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Stream Chat SDK handles its own background messages — skip them
  if (message.data.containsKey('sender') ||
      message.data.containsKey('channel_id')) {
    return;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// FIREBASE INIT
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// LOCAL NOTIFICATION INIT
  await NotificationService.initialize();
  await NotificationService.createChannel();

  /// BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  /// REQUEST PERMISSION (iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  /// VERY IMPORTANT FOR IOS TOKEN
  await FirebaseMessaging.instance.setAutoInitEnabled(true); 
    // ✅ CONNECT USER BEFORE APP STARTS
  // final techId = await Appperfernces.getTechId();

  // if (techId != null) {
  //   await StreamChatService().connectUser(techId);
  // }

  /// GET FCM TOKEN
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("🔥 FCM TOKEN = $token");
  } catch (e) {
    print("⚠️ FCM not available on simulator: $e");
  }

  /// TOKEN REFRESH LISTENER
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("🔥 NEW FCM TOKEN = $newToken");
  });

  /// FOREGROUND MESSAGE
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final data = message.data;

    // Handle Stream Chat push notifications
    if (data.containsKey('sender') ||
        data.containsKey('channel_id') ||
        (data.containsKey('type') && data['type'] == 'message.new')) {

      final senderName = data['sender_name'] ??
                         data['sender'] ??
                         message.notification?.title ??
                         'New Message';

      final messageText = data['message_text'] ??
                          message.notification?.body ??
                          'You have a new message';

      final channelId = data['channel_id'] ?? data['cid'] ?? '';

      // Suppress notification if technician is actively viewing this chat
      final activeChannel = container.read(activeChatChannelProvider);
      if (activeChannel != null && channelId.contains(activeChannel)) {
        return;
      }

      NotificationService.show(
        title: senderName,
        body: messageText,
        channelId: 'chat_messages_channel',
        channelName: 'Chat Messages',
        payload: 'chat:$channelId',
      );
      return;
    }

    // General / OTP notifications
    NotificationService.show(
      title: message.notification?.title ?? 'OTP',
      body: message.notification?.body ?? 'Your OTP is ${message.data['otp']}',
    );
  });

  // Wire GoRouter to NotificationService for tap-to-navigate
  NotificationService.setRouter(Approute);

  // Init MQTT with provider container so it can suppress notifications in active chat
  MqttNotificationService.init(container);

  // Connect MQTT if already logged in
  final techId = await Appperfernces.getTechId();
  if (techId != null) {
    MqttNotificationService.connect(techId);
  }

  runApp(UncontrolledProviderScope(container: container, child: MyApp()));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  final StreamChatClient client = StreamChatService().client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    return MaterialApp.router(
      title: 'Nadi Staff',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ref.watch(themeProvider),
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "Poppins",
        scaffoldBackgroundColor: AppColors.background_clr,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary_clr,
          secondary: AppColors.new_clr,
          surface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      routerConfig: Approute,

      // ✅ THIS IS THE FIX
      builder: (context, child) {
        return StreamChat(
          client: client,
          child: child!,
        );
      },
    );
  }
}
