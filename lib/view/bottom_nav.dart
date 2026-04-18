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

class BottomNav extends ConsumerStatefulWidget {
  const BottomNav({super.key});

  @override
  ConsumerState<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends ConsumerState<BottomNav> {
  int _selectedIndex = 0;
  DateTime? lastBackPressed;
  late final List<Widget Function()> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      () => HomeView(),
      () => MaterialInventoryView(),
      ()=> ChatsView(),
      () => MyRequestList(),
      () => ProfileView(),
    ];
  }

  void changeTab(int index) {
    setState(() => _selectedIndex = index);
  }

  /// Badge-wrapped icon for the Live Chat tab
  Widget _chatIconWithBadge(int totalUnread, {bool active = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ImageIcon(
          const AssetImage("assets/icons/chat.png"),
          size: 26,
          color: active ? AppColors.app_background_clr : Colors.grey,
        ),
        if (totalUnread > 0)
          Positioned(
            right: -8,
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
    // Total unread across all chats
    final unreadMap = ref.watch(streamUnreadCountsProvider).value ?? {};
    final totalUnread = unreadMap.values.fold(0, (sum, c) => sum + c);

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
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: Colors.grey,
            selectedItemColor: AppColors.app_background_clr,
            items: [
              BottomNavigationBarItem(
                icon: const ImageIcon(
                    AssetImage("assets/icons/home.png"), size: 26),
                activeIcon: const ImageIcon(
                    AssetImage("assets/icons/home.png"), size: 26),
                label: AppLocalizations.of(context)!.home,
              ),
              BottomNavigationBarItem(
                icon: const ImageIcon(
                    AssetImage("assets/icons/chat.png"), size: 26),
                activeIcon: const ImageIcon(
                    AssetImage("assets/icons/chat.png"), size: 26),
                label: AppLocalizations.of(context)!.inventory,
              ),
              // Live Chat tab with unread badge
              BottomNavigationBarItem(
                icon: _chatIconWithBadge(totalUnread, active: false),
                activeIcon: _chatIconWithBadge(totalUnread, active: true),
                label: 'Live Chat',
              ),
              BottomNavigationBarItem(
                icon: const ImageIcon(
                    AssetImage("assets/icons/services.png"), size: 27),
                activeIcon: const ImageIcon(
                    AssetImage("assets/icons/services.png"), size: 27),
                label: AppLocalizations.of(context)!.requestList,
              ),
              BottomNavigationBarItem(
                icon: const ImageIcon(
                    AssetImage("assets/icons/profile.png"), size: 26),
                activeIcon: const ImageIcon(
                    AssetImage("assets/icons/profile.png"), size: 26),
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
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
          lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tap again to exit"),
              duration: Duration(seconds: 2),
            ),
          );
          return false; // prevent exit
        }
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: screens[_selectedIndex](),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }
}
