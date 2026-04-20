import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/provider/InventoryList_provider.dart';
import 'package:tech_app/provider/notification_Service_Provider.dart';
import 'package:tech_app/routes/route_name.dart';

class Header extends ConsumerStatefulWidget {
  final String title;
  final bool showRefreshIcon;

  const Header({super.key, required this.title, this.showRefreshIcon = false});

  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation controller for spinning refresh icon
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      // Start spinning
      _controller.repeat();
      // Refresh inventory provider
      await ref.refresh(inventorylistprovider.future);
    } finally {
      // Stop spinning
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
final notificationCount  = ref.watch(notificationServiceProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          // InkWell(
          //   onTap: () => Navigator.of(context).pop(),
          //   child: Container(
          //     height: 38,
          //     width: 38,
          //     decoration: const BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Color.fromRGBO(183, 213, 205, 1),
          //     ),
          //     alignment: Alignment.center,
          //     child: const Icon(
          //       Icons.arrow_back_rounded,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),

          // Title
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Right icon
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
      InkWell(
onTap: () {
  context.push(RouteName.nodification).then((_) {
    ref.invalidate(notificationServiceProvider);
  });
},        child: Container(
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

  notificationCount.when(
  data: (list) {
    final count = list.length;
    print("DEBUG: Notification count = $count"); // <-- debug log

    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        height: 16,
        width: 16,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        alignment: Alignment.center,
        child: Text(
          "$count", 
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
  error: (err, _) {
 
    return const SizedBox.shrink();
  },
),

    ],
  ),

        ],
      ),
    );
  }
}
