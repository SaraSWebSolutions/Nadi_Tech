import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/provider/InventoryList_provider.dart';
import 'package:tech_app/provider/notification_Service_Provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:app_badge_plus/app_badge_plus.dart';

class Header extends ConsumerStatefulWidget {
  final String title;
  final bool showRefreshIcon;
final bool showBackButton;
final VoidCallback? onBackPressed;
const Header({
  super.key,
  required this.title,
  this.showRefreshIcon = false,

  // ✅ ADD THIS
  this.showBackButton = false,
  this.onBackPressed,
});
  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DateTime? _lastSeenTime;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Appperfernces.getLastSeenNotificationTime().then((val) {
      if (mounted) {
        setState(() => _lastSeenTime = val);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      _controller.repeat();
      await ref.refresh(inventorylistprovider.future);
    } finally {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationAsync = ref.watch(notificationServiceProvider); // ✅ FIXED

   return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: Row(
    children: [
      /// 🔙 BACK BUTTON (NEW)
      if (widget.showBackButton)
        InkWell(
          onTap: widget.onBackPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 38,
            width: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(183, 213, 205, 1),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 22,
            ),
          ),
        )
      else
        const SizedBox(width: 38),

      const SizedBox(width: 10),

      /// 📌 TITLE (TAKES SPACE PROPERLY)
      Expanded(
        child: Text(
          widget.title,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// RIGHT SIDE (refresh OR notification)
      widget.showRefreshIcon
          ? InkWell(
              onTap: _onRefresh,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller.value * 5.3,
                    child: child,
                  );
                },
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(183, 213, 205, 1),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.refresh_outlined,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                /// 🔔 NOTIFICATION ICON (YOUR EXISTING CODE)
                InkWell(
                  onTap: () async {
                    DateTime seenTime = DateTime.now().toUtc();

                    final asyncValue = ref.read(notificationServiceProvider);
                    final currentList = asyncValue.value;

                    if (currentList != null && currentList.isNotEmpty) {
                      seenTime = currentList
                          .map((n) => n.time)
                          .reduce((a, b) => a.isAfter(b) ? a : b);
                    }

                    await Appperfernces.saveLastSeenNotificationTime(seenTime);

                    if (mounted) {
                      setState(() => _lastSeenTime = seenTime);
                    }

                    context.push(RouteName.nodification).then((_) async {
                      Appperfernces.getLastSeenNotificationTime().then((val) {
                        if (mounted) setState(() => _lastSeenTime = val);
                      });

                      await ref.refresh(notificationServiceProvider.future);
                    });
                  },
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 186, 193, 227),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.notifications_none_outlined,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                ),

                /// 🔴 BADGE (UNCHANGED)
                notificationAsync.when(
                  data: (list) {
                    int unreadCount = 0;

                    if (_lastSeenTime == null) {
                      return const SizedBox.shrink();
                    } else {
                      unreadCount = list
                          .where((n) => n.time.isAfter(_lastSeenTime!))
                          .length;
                    }

                    if (unreadCount == 0) {
                      AppBadgePlus.updateBadge(0);
                      return const SizedBox.shrink();
                    }

                    AppBadgePlus.updateBadge(unreadCount);

                    return PositionedDirectional(
                      top: 4,
                      end: 4,
                      child: Container(
                        height: 16,
                        width: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$unreadCount",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
    ],
  ),
);
  }
}
