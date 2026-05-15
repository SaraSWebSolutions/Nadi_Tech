import 'package:flutter/material.dart';
import 'package:tech_app/core/constants/app_colors.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  // ✅ flexible actions
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background_clr,
      centerTitle: true,
      elevation: 0,
      automaticallyImplyLeading: false,

      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,

      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.app_background_clr,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ✅ FULL CONTROL HERE
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
