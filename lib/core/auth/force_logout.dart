// import 'package:flutter/material.dart';
// import 'package:tech_app/core/constants/app_colors.dart';
// import 'package:tech_app/l10n/app_localizations.dart';
// import 'package:tech_app/services/MqttNotificationService.dart';
// import 'package:tech_app/preferences/AppPerfernces.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tech_app/routes/route_name.dart';

// enum ForceLogoutReason { disabled, rejected, unauthorized }

// class ForceLogout {
//   static bool _inProgress = false;

//   static Future<void> trigger(ForceLogoutReason reason) async {
//     if (_inProgress) return;
//     _inProgress = true;

//     try {
//       try {
//         MqttNotificationService.disconnect();
//       } catch (_) {}

//       await Appperfernces.clearAll();
//       await Appperfernces.setLoggedIn(false);

//       final context = appRouter.routerDelegate.navigatorKey.currentContext;
//       if (context == null) return;

//       appRouter.go(RouteNames.login);

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final ctx = appRouter.routerDelegate.navigatorKey.currentContext;
//         if (ctx != null) _showReasonDialog(ctx, reason);
//       });
//     } finally {
//       // Allow a future trigger after the user sees the dialog and taps OK.
//       Future.delayed(const Duration(seconds: 2), () => _inProgress = false);
//     }
//   }

//   static void _showReasonDialog(
//     BuildContext context,
//     ForceLogoutReason reason,
//   ) {
//     final loc = AppLocalizations.of(context)!;
//     final isDisabled = reason == ForceLogoutReason.disabled;
//     final isRejected = reason == ForceLogoutReason.rejected;

//     // final title = isDisabled
//     //     ? loc.accountDisabled
//     //     : isRejected
//     //     ? loc.accountRejected
//     //     : loc.sessionEnded;
//     // final message = isDisabled
//     //     ? loc.accountDisabledSupportMessage
//     //     : isRejected
//     //     ? loc.accountRejectedSupportMessage
//     //     : loc.sessionEndedMessage;
//     final iconData = isDisabled
//         ? Icons.block
//         : isRejected
//         ? Icons.cancel_outlined
//         : Icons.lock_outline;
//     final iconColor = isDisabled
//         ? Colors.red.shade600
//         : isRejected
//         ? Colors.orange.shade700
//         : Colors.blueGrey.shade700;
//     final iconBg = isDisabled
//         ? Colors.red.shade50
//         : isRejected
//         ? Colors.orange.shade50
//         : Colors.blueGrey.shade50;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
//               child: Icon(iconData, color: iconColor, size: 28),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 //title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           message,
//           style: const TextStyle(fontSize: 14, height: 1.5),
//         ),
//         actions: [
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.app_background_clr,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               onPressed: () => Navigator.of(ctx).pop(),
//               child: Text(loc.ok),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
