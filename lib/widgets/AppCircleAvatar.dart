import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class AppCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final VoidCallback? onTap;
  final IconData fallbackIcon;
  final Color fallbackBgColor;

  const AppCircleAvatar({
    super.key,
    this.imageUrl,
    this.size = 44,
    this.borderWidth = 2,
    this.borderColor = const Color(0x22000000),
    this.onTap,
    this.fallbackIcon = Icons.person,
    this.fallbackBgColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: ClipOval(
          child: (imageUrl != null && imageUrl!.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  placeholder: (context, url) => _buildShimmer(),
                  errorWidget: (context, url, error) => _buildFallback(),
                )
              : _buildFallback(),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: fallbackBgColor,
      child: Icon(fallbackIcon, color: Colors.grey, size: size * 0.5),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }
}
