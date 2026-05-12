import 'package:go_router/go_router.dart';
import 'package:tech_app/model/TechnicianProfile_Model.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/view/ChatDetailsScreen.dart';
import 'package:tech_app/view/SplashScreen.dart';
import 'package:tech_app/view/auth/forgot_password.dart';
import 'package:tech_app/view/auth/login_view.dart';
import 'package:tech_app/view/bottom_nav.dart';
import 'package:tech_app/view/bulk_request.dart';
import 'package:tech_app/view/edit_profile.dart';
import 'package:tech_app/view/material_inventory_view.dart';
import 'package:tech_app/view/material_request.dart';
import 'package:tech_app/view/spare_part_used.dart';
import 'package:tech_app/widgets/card/servicerequest_cart.dart';
import 'package:tech_app/model/ServiceList _Model.dart';
import 'package:tech_app/view/nodifications.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final Approute = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteName.splash,
  routes: [
    GoRoute(
      path: RouteName.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteName.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: RouteName.bottom_nav,
      builder: (context, state) => const BottomNav(),
    ),
    GoRoute(
      path: RouteName.forgotpassword,
      builder: (context, state) => const ForgotPassword(),
    ),
    GoRoute(
      path: RouteName.inventory_list,
      builder: (context, state) => const MaterialInventoryView(),
    ),
    GoRoute(
      path: "/chatDetails",
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        final adminId = data["id"] as String?;
        final adminName = data["name"] as String?;

        return ChatDetailsScreen(adminId: adminId, adminName: adminName);
      },
    ),

    GoRoute(
      path: RouteName.sparepart_used,
      builder: (context, state) {
        final String userServiceId = state.extra as String;
        return SparePartUsed(userServiceId: userServiceId);
      },
    ),
    GoRoute(
      path: RouteName.bulk_request,
      builder: (context, state) => const BulkRequest(),
    ),
    GoRoute(
      path: RouteName.material_request,
      builder: (context, state) => const MaterialRequest(),
    ),
    GoRoute(
      path: RouteName.nodification,
      builder: (context, state) => const Notifications(),
    ),
    GoRoute(
      path: RouteName.service_card,
      builder: (context, state) {
        final Datum item = state.extra as Datum;
        return ServicerequestCart(data: item);
      },
    ),
    GoRoute(
      path: RouteName.editprofile,
      builder: (context, state) {
        final profile = state.extra as TechnicianProfile;
        return EditProfile(profile: profile);
      },
    ),

    // GoRoute(
    //   path: RouteName.updated_status,
    //   builder: (context, state) => const UpdateRequest(),
    //   )
  ],
);
