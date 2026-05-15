import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/provider/stream_unread_provider.dart';
import 'package:tech_app/view/My_Request_List.dart';
import 'package:tech_app/view/home_view.dart';
import 'package:tech_app/view/material_inventory_view.dart';
import 'package:tech_app/view/profile_view.dart';
import 'package:tech_app/view/livechat_view.dart';
import 'package:tech_app/provider/bottom_nav_provider.dart';

class BottomNav extends ConsumerStatefulWidget {
  const BottomNav({super.key});

  @override
  ConsumerState<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends ConsumerState<BottomNav> {
  DateTime? lastBackPressed;

  late final List<Widget Function()> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      () => HomeView(),
      () => MaterialInventoryView(),
      () => ChatsView(),
      () => MyRequestList(),
      () => const ProfileView(),
    ];
  }

  /// Chat badge icon
  Widget _chatIconWithBadge(int totalUnread, {bool active = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          active ? Icons.chat_bubble : Icons.chat_bubble_outline,
          size: 28,
          color: active ? AppColors.app_background_clr : Colors.grey,
        ),

        if (totalUnread > 0)
          PositionedDirectional(
            end: -8,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  totalUnread > 99 ? '99+' : '$totalUnread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final unreadMap = ref.watch(streamUnreadCountsProvider).value ?? {};
    final totalUnread = unreadMap.values.fold(0, (sum, c) => sum + c);

    /// ✅ CURRENT TAB FROM PROVIDER
    final currentIndex = ref.watch(bottomNavProvider);

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,

            /// ✅ UPDATE PROVIDER
            onTap: (index) {
              ref.read(bottomNavProvider.notifier).state = index;
            },

            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.grey,
            selectedItemColor: AppColors.app_background_clr,

            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined, size: 30),
                activeIcon: const Icon(Icons.home, size: 30),
                label: AppLocalizations.of(context)!.home,
              ),

              BottomNavigationBarItem(
                icon: const Icon(Icons.inventory_2_outlined, size: 26),
                activeIcon: const Icon(Icons.inventory, size: 26),
                label: AppLocalizations.of(context)!.inventory,
              ),

              BottomNavigationBarItem(
                icon: _chatIconWithBadge(totalUnread, active: false),
                activeIcon: _chatIconWithBadge(totalUnread, active: true),
                label: AppLocalizations.of(context)!.liveChat,
              ),

              BottomNavigationBarItem(
                icon: const Icon(Icons.build_outlined, size: 30),
                activeIcon: const Icon(Icons.build, size: 30),
                label: AppLocalizations.of(context)!.requestList,
              ),

              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline, size: 30),
                activeIcon: const Icon(Icons.person, size: 30),
                label: AppLocalizations.of(context)!.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ WATCH PROVIDER
    final currentIndex = ref.watch(bottomNavProvider);

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();

        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
          lastBackPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.tapAgainToExit),
              duration: const Duration(seconds: 2),
            ),
          );

          return false;
        }

        SystemNavigator.pop();
        return true;
      },

      child: Scaffold(
        /// ✅ SCREEN FROM PROVIDER
        body: screens[currentIndex](),

        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }
}
