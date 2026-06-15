// import 'dart:async';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tech_app/core/constants/app_colors.dart';
// import 'package:tech_app/preferences/AppPerfernces.dart';
// import 'package:tech_app/routes/route_name.dart';
// import 'package:tech_app/services/Stream_Chat_Service.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {

//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _navigate();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//     _initNotifications();
//   });
//   }
// Future<void> _initNotifications() async {
//   try {
//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     final token = await FirebaseMessaging.instance.getToken();

//     print("🔥 FCM TOKEN: $token");

//     if (token != null) {
//       await Appperfernces.saveFcmToken(token);
//     } else {
//       print("❌ FCM token is NULL");
//     }
//   } catch (e) {
//     print("❌ FCM ERROR: $e");
//   }
// }

//   Future<void> _navigate() async {
//     try {
//       await Future.delayed(const Duration(seconds: 3));
//       final isLoggedIn = await Appperfernces.isLoggedIn();
//       if (!mounted) return;

//       if (isLoggedIn) {
//         final techId = await Appperfernces.getTechId();
//         if (techId != null) {
//           // Connect stream chat async WITHOUT blocking the screen
//           StreamChatService().connectUserIfNeeded(techId).catchError((e) {
//             print("⚠️ Stream Chat connect failed: $e");
//           });
//         }
//         context.go(RouteName.bottom_nav);
//       } else {
//         context.go(RouteName.login);
//       }
//     } catch (e) {
//       print("❌ splash routing error: $e");
//       if (mounted) context.go(RouteName.login);
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.app_background_clr,
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/splash_bg.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Image.asset(
//               "assets/logo/Techlogo.png",
//               height: 100,
//               width: 100,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/Stream_Chat_Service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    /// 🔄 ROTATION ANIMATION
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _navigate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
    });
  }

  Future<void> _initNotifications() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken();

      print("🔥 FCM TOKEN: $token");

      if (token != null) {
        await Appperfernces.saveFcmToken(token);
      }
    } catch (e) {
      print("❌ FCM ERROR: $e");
    }
  }

  Future<void> _navigate() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      final isLoggedIn = await Appperfernces.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        final techId = await Appperfernces.getTechId();

        if (techId != null) {
          StreamChatService().connectUserIfNeeded(techId).catchError((e) {
            print("⚠️ Stream Chat connect failed: $e");
          });
        }

        context.go(RouteName.bottom_nav);
      } else {
        context.go(RouteName.login);
      }
    } catch (e) {
      print("❌ splash routing error: $e");
      if (mounted) context.go(RouteName.login);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = (size.width * 0.6).clamp(180.0, 320.0);

    return Scaffold(
      backgroundColor: AppColors.app_background_clr,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔄 ROTATING LOGO
            RotationTransition(
              turns: _rotationAnimation,
              child: SizedBox(
                height: logoSize,
                width: logoSize,
                child: Image.asset("assets/logo/logo.png", fit: BoxFit.contain),
              ),
            ),

            const SizedBox(height: 40),

            /// 📊 PROGRESS BAR (your exact design)
            SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  minHeight: 5,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
