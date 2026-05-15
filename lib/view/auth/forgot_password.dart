import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/utils/snackbar_helper.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/Auth_Service.dart';
import 'package:tech_app/widgets/inputs/app_text_field.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  final _fromkey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final AuthService _authService = AuthService();
  Future<void> updatePassword() async {
    if (!_fromkey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      final result = await _authService.updatepassword(
        email: _email.text.trim(),
      );

      debugPrint("UPDATE PASSWORD RESPONSE => $result");

      setState(() => isLoading = false);

      final message = result['message']?.toString() ?? "";

      final isSuccess = !message.toLowerCase().contains("no account found");

      SnackbarHelper.show(
        context,
        backgroundColor: isSuccess ? AppColors.primary_clr : Colors.red,
        message: message.isNotEmpty
            ? message
            : AppLocalizations.of(context)!.passwordResetLinkSent,
      );

      /// ✅ ONLY POP ON SUCCESS
      if (isSuccess && context.canPop()) {
        context.pop();
      }
    } catch (e) {
      debugPrint("UPDATE PASSWORD ERROR => $e");

      setState(() => isLoading = false);

      SnackbarHelper.show(
        context,
        backgroundColor: Colors.red,
        message: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == "ar";

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Stack(
        children: [
          /// ✅ BACKGROUND IMAGE
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/back.png"),
                fit: BoxFit.cover,
                colorFilter: isDark
                    ? ColorFilter.mode(
                        Colors.black.withOpacity(0.55),
                        BlendMode.darken,
                      )
                    : null,
              ),
            ),
          ),

          /// ✅ MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                /// ⭐ FIXED HEADER (NEVER MOVES)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 16,
                    end: 16,
                    top: 16,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RouteName.login);
                          }
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.12)
                                : Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Icon(
                            isArabic ? Icons.arrow_forward : Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// ⭐ SCROLLABLE CONTENT ONLY
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenHeight * 0.85,
                      ),

                      child: Column(
                        children: [
                          Center(
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: screenWidth * 0.9,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: screenHeight * 0.55,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
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

                            child: Directionality(
                              textDirection: isArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Form(
                                key: _fromkey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 15),

                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.forgotPasswordTitle,
                                      textAlign: isArabic
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.passwordResetLinkSent,
                                      textAlign: isArabic
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    AppTextField(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.email,
                                      controller: _email,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        final l10n = AppLocalizations.of(
                                          context,
                                        )!;

                                        if (value == null || value.isEmpty) {
                                          return l10n.emailIsRequired;
                                        }

                                        if (!value.contains("@")) {
                                          return l10n.enterValidEmail;
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 50),

                                    PrimaryButton(
                                      height: 50,
                                      Width: double.infinity,
                                      isLoading: isLoading,
                                      radius: 14,
                                      color: AppColors.app_background_clr,
                                      text: AppLocalizations.of(
                                        context,
                                      )!.sendResetLink,
                                      onPressed: updatePassword,
                                    ),

                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
