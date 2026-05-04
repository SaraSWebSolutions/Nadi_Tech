import 'package:flutter/material.dart';
import 'package:tech_app/core/constants/app_colors.dart';

class AppDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,

      /// ✅ TEXT STYLE
      style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14),

      /// ✅ DROPDOWN MENU COLOR
      dropdownColor: theme.colorScheme.surface,

      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: theme.textTheme.bodyMedium?.color,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.app_background_clr,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF79747E)),
        ),
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
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: theme.iconTheme.color),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color, // ✅ FIXED
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
