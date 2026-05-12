import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tech_app/core/constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final TextInputType? keyboardType;
  final Widget? surfixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool readOnly;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.label,
    this.keyboardType,
    this.surfixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.maxLines,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines ?? 1,
      obscureText: widget.isPassword ? _obscure : false,

      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      ),

      cursorColor: AppColors.app_background_clr,

      decoration: InputDecoration(
        labelText: widget.label,

        /// CONTENT PADDING
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        /// FILLED
        filled: true,

        fillColor: widget.readOnly
            ? (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100)
            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),

        /// LABEL STYLE
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
        ),

        floatingLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.app_background_clr,
        ),

        /// ENABLED BORDER
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),

        /// FOCUSED BORDER
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.app_background_clr,
            width: 1.6,
          ),
        ),

        /// ERROR BORDER
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),

        /// DISABLED BORDER
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade200,
          ),
        ),

        /// PASSWORD / SUFFIX ICON
        suffixIcon: widget.isPassword
            ? IconButton(
                splashRadius: 22,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : widget.surfixIcon,

        /// ERROR STYLE
        errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
