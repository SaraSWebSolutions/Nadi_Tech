import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/provider/InventoryList_provider.dart';
import 'package:tech_app/provider/bottom_nav_provider.dart';
import 'package:tech_app/provider/notification_Service_Provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/model/TechnicianProfile_Model.dart';

class Header extends ConsumerStatefulWidget {
  final String title;

  final bool showBackButton;
  final VoidCallback? onBackPressed;

  final bool showRefreshIcon;
  final bool showNotificationIcon;
  final bool showProfileIcon;

  final TechnicianProfile? profile;
  final VoidCallback? onProfileTap;

  const Header({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.showRefreshIcon = false,
    this.showNotificationIcon = true,
    this.showProfileIcon = true,
    this.profile,
    this.onProfileTap,
  });

  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Appperfernces.getLastSeenNotificationTime().then((val) {
    //   if (mounted) {
    //     setState(() {
    //       _lastSeenTime = val;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color bg = AppColors.app_background_clr,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }

  Future<void> _onRefresh() async {
    try {
      _controller.repeat();

      await ref.refresh(inventoryListProvider.future);
    } finally {
      _controller.reset();
    }
  }

  Widget _buildProfileImage() {
    return InkWell(
      onTap:
          widget.onProfileTap ??
          () {
            ref.read(bottomNavProvider.notifier).state = 4;
          },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.app_background_clr.withOpacity(0.15),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: (widget.profile?.data.image?.isNotEmpty ?? false)
              ? CachedNetworkImage(
                  imageUrl:
                      '${ImageBaseUrl.baseUrl}/${widget.profile!.data.image}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade700,
                        size: 24,
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    color: Colors.grey.shade700,
                    size: 24,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return _iconButton(
      icon: Icons.arrow_back_rounded,
      onTap:
          widget.onBackPressed ??
          () {
            Navigator.pop(context);
          },
      bg: Color.fromARGB(255, 180, 189, 230),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationAsync = ref.watch(notificationServiceProvider);

    return AppBar(
      backgroundColor: AppColors.app_background_clr,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,

      toolbarHeight: 60,

      // 🔥 THIS REMOVES WHITE GAP ABOVE STATUS BAR
      forceMaterialTransparency: false,
      surfaceTintColor: Colors.transparent,

      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.app_background_clr,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),

      leadingWidth: 60,

      leading: widget.showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: _buildBackButton(context),
                ),
              ),
            )
          : widget.showProfileIcon
          ? Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _buildProfileImage(),
            )
          : null,

      title: Text(
        widget.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: [
        if (widget.showRefreshIcon)
          IconButton(
            onPressed: _onRefresh,
            icon: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) => Transform.rotate(
                angle: _controller.value * 6.28,
                child: child,
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),

        if (widget.showNotificationIcon)
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push(RouteName.nodification),
                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),

              notificationAsync.when(
                data: (list) {
                  final unread = list.where((e) => e.read == false).length;
                  if (unread == 0) return const SizedBox();

                  return Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread > 99 ? '99+' : unread.toString(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
      ],
    );
  }
}
