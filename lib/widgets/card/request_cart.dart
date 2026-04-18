import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/model/ServiceList%20_Model.dart';

class RequestCart extends StatelessWidget {
  final String clientname;
  final String servicetype;
  final String assignmentStatus;
  final DateTime scheduleService;
  final DateTime createdAt;
  final String feedback;
  final String serviceRequestID;
  final int payment;
  final String userServiceId;
  final List<Assignment> assignments;
  final List<String> media;
  final String status;
  const RequestCart({
    super.key,
    required this.clientname,
    required this.servicetype,
    required this.assignmentStatus,
    required this.scheduleService,
    required this.createdAt,
    required this.feedback,
    required this.serviceRequestID,
    required this.assignments,
    required this.payment,
    required this.media,
    required this.userServiceId,
    required this.status,
  });

  String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  Widget _sectionHeader(String title, {IconData? icon}) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.app_background_clr,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          if (icon != null)
            Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(icon, size: 18, color: AppColors.app_background_clr),
            ),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style:  TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardContainer({required Widget child ,  required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow:  [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.35):Colors.black.withOpacity(0.25),
             blurRadius: 6, 
             offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    List<String>? media,
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // VALUE
          // Expanded(
          //   flex: 5,
          //   child: Align(
          //     alignment: Alignment.centerRight,
          //     child: _buildValueWidget(context, value, media, isStatus),
          //   ),
          // ),
          Expanded(
  flex: 5,
  child: Align(
    alignment: AlignmentDirectional.centerEnd,
    child: _buildValueWidget(context, value, media, isStatus),
  ),
),
        ],
      ),
    );
  }

  Widget _buildValueWidget(
    BuildContext context,
    String value,
    List<String>? media,
    bool isStatus,
  ) {
    // MEDIA LINK
    if (media != null && media.isNotEmpty) {
      return InkWell(
        onTap: () => _showissuseMediaDialog(context, media),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    if (isStatus) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 184, 190, 218),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.app_background_clr,
            letterSpacing: 0.6,
          ),
        ),
      );
    }

    // DEFAULT TEXT
    return Text(
      value,
      // textAlign: TextAlign.right,
        textAlign: TextAlign.end,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color:Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }

  Widget _sparePartRow(String label, String qty, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child:
      //  Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Text(label),
      //         Row(
      //           children: [Text("Qty:"), const SizedBox(width: 5), Text(qty)],
      //         ),
      //       ],
      //     ),
      //     Text(amount),
      //   ],
      // ),
      Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, textAlign: TextAlign.start),
          Row(
            children: [
              Text("Qty:"),
              const SizedBox(width: 5),
              Text(qty),
            ],
          ),
        ],
      ),
    ),
    Text(amount, textAlign: TextAlign.end),
  ],
),
    );
  }

  void _showMediaDialog(BuildContext context, List<String> mediaList) {
    final images = mediaList
        .where(
          (m) =>
              m.endsWith(".jpg") ||
              m.endsWith(".png") ||
              m.endsWith(".jpeg") ||
              m.endsWith(".webp"),
        )
        .toList();

    final otherMedia = mediaList
        .where(
          (m) =>
              !m.endsWith(".jpg") &&
              !m.endsWith(".png") &&
              !m.endsWith(".jpeg") &&
              !m.endsWith(".webp"),
        )
        .toList();

    final PageController _pageController = PageController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Media Files",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (images.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 240,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final imgUrl =
                              "${ImageBaseUrl.baseUrl}/${images[index].trim()}";
                          final urls = images
                              .map((m) =>
                                  "${ImageBaseUrl.baseUrl}/${m.trim()}")
                              .toList();
                          return GestureDetector(
                            onTap: () =>
                                _openFullScreenImage(context, urls, index),
                            child: InteractiveViewer(
                              minScale: 1,
                              maxScale: 4,
                              child: CachedNetworkImage(
                                imageUrl: imgUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: images.length,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 6,
                        dotColor: Colors.grey,
                        activeDotColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              if (otherMedia.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: otherMedia.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.play_circle_fill),
                      title: Text(otherMedia[index].split('/').last),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showissuseMediaDialog(BuildContext context, List<String> mediaList) {
    // Separate images and other media
    final images = mediaList
        .where(
          (media) =>
              media.endsWith(".jpg") ||
              media.endsWith(".png") ||
              media.endsWith(".jpeg") ||
              media.endsWith(".webp"),
        )
        .toList();

    // final otherMedia = mediaList
    //     .where(
    //       (media) =>
    //           !media.endsWith(".jpg") &&
    //           !media.endsWith(".png") &&
    //           !media.endsWith(".jpeg") &&
    //           !media.endsWith(".webp"),
    //     )
    //     .toList();

    final PageController _pageController = PageController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
               AppLocalizations.of(context)!.mediaFiles,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // Images carousel
                if (images.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final imgUrl =
                                "${ImageBaseUrl.baseUrl}/${images[index].trim()}";
                            final urls = images
                                .map((m) =>
                                    "${ImageBaseUrl.baseUrl}/${m.trim()}")
                                .toList();
                            return GestureDetector(
                              onTap: () =>
                                  _openFullScreenImage(context, urls, index),
                              child: InteractiveViewer(
                                minScale: 1,
                                maxScale: 4,
                                child: CachedNetworkImage(
                                  imageUrl: imgUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: images.length,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 6,
                          dotColor: Colors.grey,
                          activeDotColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

              
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullScreenImage(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    final controller = PageController(initialPage: initialIndex);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.92),
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(
          images: images,
          controller: controller,
        ),
      ),
    );
  }

  String formatWorkDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "ASSIGNMENTS JSON ********************8:\n${const JsonEncoder.withIndent('  ').convert(assignments.map((e) => e.toJson()).toList())}",
    );
    return Column(
      children: [
        // 1. Request Information
        _cardContainer(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(AppLocalizations.of(context)!.requestInformation, icon: Icons.receipt_long,),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(context, AppLocalizations.of(context)!.requestId, serviceRequestID),
                    const Divider(),
                    _infoRow(context,AppLocalizations.of(context)!.serviceType, servicetype),
                    // const Divider(),
                    // _infoRow(context, "Status", assignmentStatus),
                    const Divider(),
                    _infoRow(context, AppLocalizations.of(context)!.clientName, clientname),
                    // const Divider(),
                    // _infoRow(
                    //   context,
                    //   "View Media",
                    //   "Tap to view",
                    //   media: media,
                    // ),
                    if (media != null && media.isNotEmpty) ...[
                      const Divider(),
                      _infoRow(
                        context,
                        AppLocalizations.of(context)!.viewMedia,
                        AppLocalizations.of(context)!.tapToView,
                        media: media,
                      ),
                    ],
                    const Divider(),
                    Align(
                      // alignment: Alignment.centerLeft,
                       alignment: AlignmentDirectional.centerStart,
                      child: Text(
                       AppLocalizations.of(context)!.description,
                        style: TextStyle(
                          color: AppColors.lightgray_clr,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        feedback,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Spare Parts Used
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            return _cardContainer(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(AppLocalizations.of(context)!.sparePartsUsed, icon: Icons.build),
                  assignment.usedParts.isEmpty
                      ?  Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.noSparePartUsed,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: assignment.usedParts
                                .map(
                                  (part) => _sparePartRow(
                                    part.productName,
                                    part.count.toString(),
                                    "BHD: ${part.price}",
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ],
              ),
            );
          },
        ),

        // 3. Completed Service
        // Completed Service Card
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            final assignmentMedia = assignment.media;

            return _cardContainer(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(AppLocalizations.of(context)!.completedService, icon: Icons.check_circle),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _infoRow(
                          context,
                         AppLocalizations.of(context)!.timeDuration,
                          '${formatWorkDuration(assignment.workDuration)}',
                        ),

                        const Divider(),
                        _infoRow(
                          context,
                          AppLocalizations.of(context)!.description,
                          '${(assignment.notes) ?? "_"}',
                        ),
                        const Divider(),
                        _infoRow(
                          context,
                          AppLocalizations.of(context)!.status,
                          '${(assignment.status)}',
                          isStatus: true,
                        ),
                        const Divider(),
                        // View Fixed Media Row
                        if (assignmentMedia.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                             AppLocalizations.of(context)!.fixedMedia,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    _showMediaDialog(context, assignmentMedia),
                                child:  Text(
                                AppLocalizations.of(context)!.tapToView,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 4. Total Service Cost
        _cardContainer(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(AppLocalizations.of(context)!.totalServiceCost),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(AppLocalizations.of(context)!.totalAmount),
                      Text(
                        "BHD: ${payment.toString()}",
                        style: TextStyle(
                          color: AppColors.scoundry_clr,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final List<String> images;
  final PageController controller;
  const _FullScreenImageViewer({
    required this.images,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: images.length,
            itemBuilder: (context, index) => Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, color: Colors.white, size: 60),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
