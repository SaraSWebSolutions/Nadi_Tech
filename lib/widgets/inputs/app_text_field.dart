import 'package:flutter/material.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:flutter/services.dart'; // ✅ add this

class AppTextField extends StatefulWidget {
  final String label;
  final TextInputType? keyboardType;
  final Icon? surfixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool readOnly;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters; // ✅ NEW
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
    final theme = Theme.of(context); // ✅ IMPORTANT

    return TextFormField(
      inputFormatters: widget.inputFormatters, // ✅ ADD THIS

      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.maxLines ?? 1,
      obscureText: widget.isPassword ? _obscure : false,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: widget.label,

        /// ✅ LABEL COLOR
        labelStyle: TextStyle(
          fontSize: 14,
          color: theme.textTheme.bodyMedium?.color,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.app_background_clr,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor, width: 1),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.app_background_clr,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : widget.surfixIcon,
      ),
    );
  }
}
