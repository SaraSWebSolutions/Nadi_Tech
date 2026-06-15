import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final double? height;
  final double? Width;
  final double radius;
  final Color color;
  final VoidCallback? onPressed;
  final String text;
  final bool? isLoading;
  final Icon? icon;
  const PrimaryButton({
    super.key,
    this.height,
    this.Width,
    required this.radius,
    required this.color,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: Width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        onPressed: onPressed,
        child: isLoading == true
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
