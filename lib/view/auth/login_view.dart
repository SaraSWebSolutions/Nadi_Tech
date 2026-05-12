import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/controllers/Auth_Controllers.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/utils/snackbar_helper.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/provider/notification_Service_Provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/widgets/inputs/app_text_field.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/services/MqttNotificationService.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isChecked = false;
  bool isLoading = false;
  final _fromkey = GlobalKey<FormState>();
  final _authcontroller = AuthControllers();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/back.png"),
            colorFilter: isDark
                ? ColorFilter.mode(
                    Colors.black.withOpacity(0.55),
                    BlendMode.darken,
                  )
                : null,

            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: screenWidth * 0.9,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: screenHeight * 0.55),
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,

                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.25)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _fromkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.welcome,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 15),

                          AppTextField(
                            label: AppLocalizations.of(context)!.enterEmail,
                            keyboardType: TextInputType.emailAddress,
                            controller: _authcontroller.email,
                            validator: (v) => _authcontroller.validateEmail(
                              v,
                              AppLocalizations.of(context)!,
                            ),
                          ),

                          const SizedBox(height: 15),

                          AppTextField(
                            label: AppLocalizations.of(context)!.enterPassword,
                            keyboardType: TextInputType.visiblePassword,

                            isPassword: true,
                            controller: _authcontroller.pasword,
                            validator: (v) => _authcontroller.validatePassword(
                              v,
                              AppLocalizations.of(context)!,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      onChanged: (v) {
                                        setState(() => isChecked = v!);
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.rememberMe,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go(RouteName.forgotpassword);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.forgotPassword,
                                  style: TextStyle(
                                    color: AppColors.app_background_clr,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          PrimaryButton(
                            height: 48,
                            Width: double.infinity,
                            isLoading: isLoading,
                            radius: 12,
                            color: AppColors.app_background_clr,
                            text: AppLocalizations.of(context)!.login,
                            onPressed: () async {
                              if (_fromkey.currentState!.validate()) {
                                setState(() => isLoading = true);

                                final errorMessage = await _authcontroller
                                    .login();

                                setState(() => isLoading = false);

                                if (errorMessage == null) {
                                  await Appperfernces.setLoggedIn(true);
                                  // Connect MQTT for chat notifications
                                  final techId =
                                      await Appperfernces.getTechId();
                                  if (techId != null) {
                                    MqttNotificationService.connect(techId);
                                  }
                                  // ✅ RESET NOTIFICATION STATE (VERY IMPORTANT)
                                  if (mounted) {
                                    final container = ProviderScope.containerOf(
                                      context,
                                    );
                                    container.invalidate(
                                      notificationServiceProvider,
                                    );
                                  }

                                  // ✅ OPTIONAL: RESET lastSeenTime for new login
                                  if (techId != null) {
                                    await Appperfernces.clearLastSeenNotificationTime(
                                      techId,
                                    );
                                  }
                                  SnackbarHelper.show(
                                    context,
                                    message: AppLocalizations.of(
                                      context,
                                    )!.loginSuccessful,
                                    backgroundColor:
                                        AppColors.app_background_clr,
                                  );
                                  context.go(RouteName.bottom_nav);
                                } else {
                                  SnackbarHelper.show(
                                    context,
                                    message: errorMessage,
                                    backgroundColor: Colors.red,
                                  );
                                }
                              }
                            },
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
