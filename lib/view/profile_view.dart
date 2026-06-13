import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/model/TechnicianProfile_Model.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/language_provider.dart';
import 'package:tech_app/provider/theme_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/NotificationService.dart';
import 'package:tech_app/services/TechnicianProfile_Service.dart';
import 'package:tech_app/services/account_delete.dart';
import 'package:tech_app/services/lockout_service.dart';
import 'package:tech_app/services/MqttNotificationService.dart';
import 'package:tech_app/services/notification_toggle_service.dart';
import 'package:tech_app/widgets/header.dart';
import 'package:tech_app/widgets/inputs/app_text_field.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final TechnicianprofileService _service = TechnicianprofileService();

  TechnicianProfile? _profile;
  final NotificationToggleService _notificationToggleService =
      NotificationToggleService();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  final LockoutService _lockoutService = LockoutService();
  bool pushNotification = false;
  bool darkMode = false;
  bool privacyControl = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    mobileController = TextEditingController();
    profiledata();
    loadNotificationStatus();
  }

  Future<void> profiledata() async {
    final response = await _service.tech_profile();
    if (!mounted) return;

    setState(() {
      _profile = response;
      firstNameController.text = _profile?.data.firstName ?? "";
      lastNameController.text = _profile?.data.lastName ?? "";
      emailController.text = _profile?.data.email ?? "";
      mobileController.text = _profile?.data.mobile?.toString() ?? "";
    });
  }

  Future<void> loadNotificationStatus() async {
    try {
      final status = await _notificationToggleService.fetchCheckStatus();
      if (!mounted) return;
      setState(() {
        pushNotification = status;
      });
    } catch (e) {
      debugPrint("Error loading notification status: $e");
    }
  }

  Future<void> toggleNotification(bool value) async {
    setState(() {
      pushNotification = value;
    });

    try {
      await _notificationToggleService.updateNotificationStatus(value);
    } catch (e) {
      // revert if API fails
      setState(() {
        pushNotification = !value;
      });
    }

    if (!mounted) return;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // ✅ SAVE REMEMBER DATA BEFORE CLEAR
      final rememberedEmail = await Appperfernces.getRememberedEmail();

      final rememberMe = await Appperfernces.getRememberMe();

      // Backend logout
      await _lockoutService.fetchlogout();

      MqttNotificationService.disconnect();

      // Clear app session
      await Appperfernces.clearAll();

      // ✅ RESTORE REMEMBER DATA
      if (rememberMe && rememberedEmail != null) {
        await Appperfernces.setRememberMe(true);

        await Appperfernces.saveRememberedEmail(rememberedEmail);
      }

      await Appperfernces.setLoggedIn(false);

      context.go(RouteName.splash);
    } catch (e) {
      debugPrint('❌ Logout failed: $e');

      final rememberedEmail = await Appperfernces.getRememberedEmail();

      final rememberMe = await Appperfernces.getRememberMe();

      await Appperfernces.clearAll();

      // ✅ RESTORE AGAIN
      if (rememberMe && rememberedEmail != null) {
        await Appperfernces.setRememberMe(true);

        await Appperfernces.saveRememberedEmail(rememberedEmail);
      }

      await Appperfernces.setLoggedIn(false);

      context.go(RouteName.splash);
    }
  }

  final AccountDelete _accountDelete = AccountDelete();

  List<dynamic> deleteReasons = [];
  String? selectedReasonId;
  bool isLoadingReasons = false;

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    setState(() {
      isLoadingReasons = true;
    });

    try {
      final response = await _accountDelete.fetchdeletereson();

      deleteReasons = response["data"] ?? [];
      // print("deleteReasons: $deleteReasons");
    } catch (e) {
      debugPrint("Error loading reasons: $e");
    }

    setState(() {
      isLoadingReasons = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.deleteAccount),
              content: SizedBox(
                width: double.maxFinite,
                child: isLoadingReasons
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.selectReasonDelete,
                          ),

                          const SizedBox(height: 15),

                          /// ✅ RADIO LIST FROM API
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: deleteReasons.length,
                              itemBuilder: (context, index) {
                                final item = deleteReasons[index];

                                return RadioListTile<String>(
                                  value: item["_id"],
                                  groupValue: selectedReasonId,
                                  title: Text(item["reason"]),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedReasonId = value;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    debugPrint("selectedReasonId $selectedReasonId");
                    if (selectedReasonId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.pleaseSelectReason,
                          ),
                        ),
                      );
                      return;
                    }
                    await _accountDelete.fetchdeleteaccount(
                      reasonId: selectedReasonId!,
                    );
                    await Appperfernces.clearAll();
                    await Appperfernces.setLoggedIn(false);
                    context.go(RouteName.splash);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logOut),
          content: Text(AppLocalizations.of(context)!.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                //Navigator.pop(context); // close dialog
                await _logout(context); // call logout
              },
              child: Text(
                AppLocalizations.of(context)!.logOut,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// ✅ HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(
          title: AppLocalizations.of(context)!.profileManagement,
          showBackButton: false,
          showNotificationIcon: false,
          showRefreshIcon: false,
          showProfileIcon: false,
        ),
      ),

      /// ✅ BODY (NO Expanded HERE)
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _profileHeader(),
                const SizedBox(height: 20),
                _personalDetailsContainer(),
                const SizedBox(height: 20),
                _applicationSettingsContainer(),
                const SizedBox(height: 30),

                _dangerActionTile(
                  icon: Icons.logout_rounded,
                  title: AppLocalizations.of(context)!.logOut,
                  subtitle: AppLocalizations.of(context)!.logoutConfirmMessage,
                  color: AppColors.app_background_clr,
                  onTap: () => _showLogoutConfirmDialog(context),
                ),

                const SizedBox(height: 18),

                _dangerActionTile(
                  icon: Icons.delete_forever_rounded,
                  title: AppLocalizations.of(context)!.accountDelete,
                  subtitle: AppLocalizations.of(context)!.selectReasonDelete,
                  color: Colors.redAccent,
                  onTap: () => _showDeleteAccountDialog(context),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dangerActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.08) : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: color.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- PROFILE HEADER ----------------
  Widget _profileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    (_profile?.data.image != null &&
                        _profile!.data.image!.isNotEmpty)
                    ? CachedNetworkImageProvider(
                        '${ImageBaseUrl.baseUrl}/${_profile?.data.image}',
                      )
                    : null,
                child: _profile?.data.image == null
                    ? const Icon(Icons.person, size: 34)
                    : null,
              ),

              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: InkWell(
                  onTap: () async {
                    if (_profile == null || _profile!.data == null) {
                      return;
                    }

                    final updated = await context.push(
                      RouteName.editprofile,
                      extra: _profile,
                    );

                    if (updated == true) profiledata();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.app_background_clr,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).cardColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            "${_profile?.data.firstName ?? ''} ${_profile?.data.lastName ?? ''}",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.app_background_clr.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _profile?.data.role?.skill ?? "",
              style: TextStyle(
                color: AppColors.app_background_clr,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalDetailsContainer() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.app_background_clr,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Personal Details",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 20),

          AppTextField(
            label: AppLocalizations.of(context)!.firstName,
            controller: firstNameController,
            readOnly: true,
          ),

          const SizedBox(height: 14),

          AppTextField(
            label: AppLocalizations.of(context)!.lastName,
            controller: lastNameController,
            readOnly: true,
          ),

          const SizedBox(height: 14),

          AppTextField(
            label: AppLocalizations.of(context)!.email,
            controller: emailController,
            readOnly: true,
          ),

          const SizedBox(height: 14),

          AppTextField(
            label: AppLocalizations.of(context)!.mobileNumber,
            controller: mobileController,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _applicationSettingsContainer() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: AppColors.app_background_clr,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Application Settings",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _switchTile(
            icon: Icons.notifications_none_rounded,
            title: AppLocalizations.of(context)!.enablePushNotifications,
            subtitle: AppLocalizations.of(context)!.receiveAlerts,
            value: pushNotification,
            onChanged: toggleNotification,
          ),

          const SizedBox(height: 14),

          _switchTile(
            icon: Icons.dark_mode_outlined,
            title: AppLocalizations.of(context)!.darkMode,
            subtitle: AppLocalizations.of(context)!.reduceEyeStrain,
            value: ref.watch(themeProvider) == ThemeMode.dark,
            onChanged: (v) {
              ref.read(themeProvider.notifier).setTheme(v);
            },
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language_outlined,
                      color: AppColors.app_background_clr,
                      size: 20,
                    ),
                    const SizedBox(width: 10),

                    Text(
                      AppLocalizations.of(context)!.chooseLanguage,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    _languageOption(
                      AppLocalizations.of(context)!.languageEnglishShort,
                      'en',
                    ),
                    _languageOption(
                      AppLocalizations.of(context)!.languageArabicShort,
                      'ar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageOption(String label, String languageCode) {
    final locale = ref.watch(languageProvider);
    final isActive = locale.languageCode == languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isActive
        ? Colors.white
        : (isDark ? Colors.white70 : Colors.black87);

    final borderColor = isActive
        ? AppColors.app_background_clr
        : (isDark ? Colors.white24 : Colors.grey.shade400);

    return GestureDetector(
      onTap: () {
        ref.read(languageProvider.notifier).changeLanguage(languageCode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        margin: const EdgeInsetsDirectional.only(end: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.app_background_clr : Colors.transparent,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.app_background_clr.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.app_background_clr),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              activeColor: AppColors.app_background_clr,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
