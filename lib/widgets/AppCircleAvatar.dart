import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class AppCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final VoidCallback? onTap;

  const AppCircleAvatar({
    super.key,
    this.imageUrl,
    this.size = 44,
    this.borderWidth = 2,
    this.borderColor = const Color(0x22000000),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? CachedNetworkImageProvider(imageUrl!)
              : null,
          child: imageUrl == null || imageUrl!.isEmpty
              ? Icon(Icons.person, size: size * 0.5, color: Colors.grey)
              : null,
        ),
      ),
    );
  }
}

// class AppCircleAvatar extends StatelessWidget {
//   final String? imageUrl;
//   final double size;
//   final VoidCallback? onTap;
//   final Color borderColor;

//   const AppCircleAvatar({
//     super.key,
//     this.imageUrl,
//     required this.size,
//     this.onTap,
//     required this.borderColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(size),
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: borderColor,
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: imageUrl != null && imageUrl!.isNotEmpty
//             ? CachedNetworkImage(
//                 imageUrl: imageUrl!,
//                 fit: BoxFit.cover,
//                 width: size,
//                 height: size,
//                 useOldImageOnUrlChange: true,
//                 fadeInDuration: Duration.zero,
//                 fadeOutDuration: Duration.zero,
//                 errorWidget: (_, __, ___) => _fallback(),
//               )
//             : _fallback(),
//       ),
//     );
//   }

//   Widget _fallback() {
//     return Container(
//       color: Colors.grey.shade300,
//       alignment: Alignment.center,
//       child: const Icon(
//         Icons.person,
//         color: Colors.grey,
//       ),
//     );
//   }
// }
