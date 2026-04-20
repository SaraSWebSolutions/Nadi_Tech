import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/core/utils/Time_Date.dart';
import 'package:tech_app/core/utils/snackbar_helper.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/service_list_provider.dart';
import 'package:tech_app/provider/service_timer_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/AcceptRequest_Service.dart';
import 'package:tech_app/services/StartWork_Service.dart';
import 'package:tech_app/view/update_request_view.dart';
import 'package:tech_app/widgets/card/request_cart.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';
import 'package:tech_app/model/ServiceList _Model.dart';
import 'package:tech_app/provider/home_tab_provider.dart';
class ServicerequestCart extends ConsumerStatefulWidget {
  final Datum data;

  const ServicerequestCart({super.key, required this.data});

  @override
  ConsumerState<ServicerequestCart> createState() => _ServicerequestCartState();
}

class _ServicerequestCartState extends ConsumerState<ServicerequestCart> {
  final AcceptrequestService _acceptrequestService = AcceptrequestService();
  final StartworkService _startwork = StartworkService();

  // 🔹 AUDIO PLAYER
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  // 🔹 Play / Pause voice
  Future<void> _toggleVoice(String url) async {
    if (_audioPlayer == null) _audioPlayer = AudioPlayer();

    if (_isPlaying) {
      await _audioPlayer!.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer!.play(UrlSource(url));
      setState(() => _isPlaying = true);

      _audioPlayer!.onPlayerComplete.listen((event) {
        setState(() => _isPlaying = false);
      });
    }
  }

  Future<void> acceptrequest({required String status, String? reason}) async {
    try {
      final assignmentId = widget.data.id;
      final result = await _acceptrequestService.acceptrequest(
        assignmentId,
        status,
        reason,
      );
debugPrint("RESULT: $result");
      SnackbarHelper.show(
        context,
        backgroundColor: AppColors.app_background_clr,
        message: status == "accept" ? AppLocalizations.of(context)!.serviceAccepted :  AppLocalizations.of(context)!.serviceRejected,
      );
      //   REFRESH SERVICE LIST API
      ref.invalidate(serviceListProvider);
    // 🔥 SET TAB BASED ON ACTION
    if (status == "accept") {
      ref.read(homeTabProvider.notifier).state = 2; // Accepted tab
    } else {
      ref.read(homeTabProvider.notifier).state = 3; // Rejected tab
    }

    context.go(RouteName.bottom_nav);    } catch (e) {
      SnackbarHelper.show(
        context,
        backgroundColor: Colors.red,
        message: e.toString(),
      );
    }
  }

  // Start Work
  Future<void> startwork() async {
    try {
      await Appperfernces.saveuserServiceId(widget.data.id);
      await _startwork.fetchstartwork(widget.data.id);

     // ✅ START GLOBAL TIMER
    // ref.read(serviceTimerProvider.notifier).start();

      SnackbarHelper.show(
        context,
        backgroundColor: AppColors.app_background_clr,
        message: AppLocalizations.of(context)?.startWork,
      );

      //  REFRESH SERVICE LIST
       // ✅ Refresh list
    ref.invalidate(serviceListProvider);

    // ✅ SWITCH TAB → In Progress
    ref.read(homeTabProvider.notifier).state = 4; // index of In Progress tab

    // ✅ GO TO MAIN SCREEN
    context.go(RouteName.bottom_nav);
    } catch (e) {
      SnackbarHelper.show(
        context,
        backgroundColor: Colors.red,
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // CUSTOMER & SERVICE DETAILS
              if (widget.data.assignmentStatus != "in-progress" &&
                  widget.data.assignmentStatus != "completed" &&
                   widget.data.assignmentStatus != "on-hold") ...[
                _buildCustomerDetails(),
                const SizedBox(height: 20),
                _buildServiceDetails(),
              ],

              const SizedBox(height: 10),

              // ACTION BUTTONS
              if (widget.data.assignmentStatus == "pending") ...[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: PrimaryButton(
                    radius: 13,
                    height: 50,
                    Width: double.infinity,
                    color: AppColors.scoundry_clr,
                    onPressed: () {
                      acceptrequest(status: "accept");
                    },
                    text: AppLocalizations.of(context)!.accept,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: PrimaryButton(
                    radius: 13,
                    height: 50,
                    Width: double.infinity,
                    color: Colors.red,
                    onPressed: () {
                      _showRejectReasonSheet(context);
                    },
                    text: AppLocalizations.of(context)!.reject,
                  ),
                ),
              ],
              if (widget.data.assignmentStatus == "accepted") ...[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: PrimaryButton(
                    radius: 13,
                    height: 50,
                    Width: double.infinity,
                    color: AppColors.scoundry_clr,
                    onPressed: startwork,
                    text:   AppLocalizations.of(context)!.startWork  ,
                  ),
                ),
              ],

              // COMPLETED SERVICE
              if (widget.data.assignmentStatus == "completed") ...[
                RequestCart(
                  userServiceId: widget.data.id,
                  clientname: widget.data.userId.basicInfo.fullName,
                  serviceRequestID: widget.data.serviceRequestId,
                  servicetype: widget.data.serviceId.name,
                  assignmentStatus: widget.data.assignmentStatus,
                  scheduleService: widget.data.scheduleService,
                  status: widget.data.serviceStatus,
                  createdAt: widget.data.createdAt,
                  feedback: widget.data.feedback ?? '',
                  payment: widget.data.payment,
                  media: widget.data.media,
                  assignments:
                      widget.data.technicianUserService?.assignments ?? [],
                ),
              ],

              // IN-PROGRESS OR ON-HOLD
              if (widget.data.assignmentStatus == "in-progress" ) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: UpdateRequestView(
                    serviceRequestId: widget.data.assignmentStatus,
                    userServiceId: widget.data.id,
                  ),
                ),
              ],

                if (
                  widget.data.assignmentStatus == "on-hold") ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: UpdateRequestView(
                    serviceRequestId: widget.data.assignmentStatus,
                    userServiceId: widget.data.id,
                  ),
                ),
              ],

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateOnly(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  Widget _buildCustomerDetails() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow:  [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.35):Colors.black.withOpacity(0.15),
            blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.scoundry_clr,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(Icons.person, color: AppColors.scoundry_clr),
                ),
                const SizedBox(width: 12),
                 Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.customerDetails,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(AppLocalizations.of(context)!.name, widget.data.userId.basicInfo.fullName),
                const Divider(),
                _infoRow(AppLocalizations.of(context)!.email, widget.data.userId.basicInfo.email),
                const Divider(),
                _infoRow(
                  AppLocalizations.of(context)!.address,
                  "building ${widget.data.address.building}, floor ${widget.data.address.floor}, aptNo ${widget.data.address.aptNo}",
                ),
                // const Divider(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const Text(
                //       "Location",
                //       style: TextStyle(fontSize: 12, color: Colors.grey),
                //     ),
                //     Container(
                //       height: 90,
                //       width: 200,
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10),
                //         color: const Color.fromARGB(196, 189, 185, 185),
                //       ),
                //     ),
                //   ],
                // ),
                const Divider(),
                _infoRow(AppLocalizations.of(context)!.distance, "7km"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow:  [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.35):Colors.black.withOpacity(0.15),
             blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.scoundry_clr,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(Icons.person, color: AppColors.scoundry_clr),
                ),
                const SizedBox(width: 12),
                 Expanded(
                  child: Text(
                   AppLocalizations.of(context)!.serviceDetails,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(AppLocalizations.of(context)!.serviceType, widget.data.serviceId.name),
                const Divider(),
                _infoRow(AppLocalizations.of(context)!.description, widget.data.feedback ?? ""),
                const Divider(),
                _infoRow(
                  AppLocalizations.of(context)!.status,
                  widget.data.assignmentStatus,
                  isStatus: true,
                ),
                if (widget.data.media != null &&
                    widget.data.media.isNotEmpty) ...[
                  const Divider(),
                  _infoRow(
                   AppLocalizations.of(context)!.viewMedia,
                   AppLocalizations.of(context)!.tapToView,
                    media: widget.data.media,
                  ),
                ],
                if (widget.data.voice != null &&
                    widget.data.voice!.isNotEmpty) ...[
                  const Divider(),
                  InkWell(
                    onTap: () async {
                      final url =
                          "${ImageBaseUrl.baseUrl}/${widget.data.voice!.trim()}";

                      if (_audioPlayer == null) _audioPlayer = AudioPlayer();

                      if (_isPlaying) {
                        await _audioPlayer!.pause();
                        setState(() => _isPlaying = false);
                      } else {
                        await _audioPlayer!.play(UrlSource(url)); // network URL
                        setState(() => _isPlaying = true);

                        _audioPlayer!.onPlayerComplete.listen((event) {
                          setState(() => _isPlaying = false);
                        });
                      }
                    },
                    child: 
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //      Text(
                    //       AppLocalizations.of(context)!.voiceNote,
                    //       style: TextStyle(fontSize: 12, color: Colors.grey),
                    //     ),
                    //     Row(
                    //       children: [
                    //         Text(
                    //           _isPlaying ? AppLocalizations.of(context)!.playing: AppLocalizations.of(context)!.tapToPlay,
                    //           style: const TextStyle(
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.w500,
                    //             color: Colors.blue,
                    //             decoration: TextDecoration.underline,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 8),
                    //         Icon(
                    //           _isPlaying
                    //               ? Icons.pause_circle
                    //               : Icons.play_circle,
                    //           color: Colors.blue,
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    Row(
  children: [
    Expanded(
      child: Text(
        AppLocalizations.of(context)!.voiceNote,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ),
    Row(
      children: [
        Text(
          _isPlaying
              ? AppLocalizations.of(context)!.playing
              : AppLocalizations.of(context)!.tapToPlay,
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          _isPlaying ? Icons.pause_circle : Icons.play_circle,
          color: Colors.blue,
        ),
      ],
    ),
  ],
)
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.green.shade100;
      case "pending":
        return Colors.orange.shade100;
      case "rejected":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "rejected":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // Widget _infoRow(
  //   String label,
  //   String value, {
  //   List<String>? media,
  //   bool isStatus = false,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12),
  //         ),
  //         Expanded(
  //           child: Align(
  //             alignment: Alignment.centerRight,
  //             child: media != null && media.isNotEmpty
  //                 ? InkWell(
  //                     onTap: () {
  //                       _showMediaDialog(context, media);
  //                     },
  //                     child: Text(
  //                       value,
  //                       style: const TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w500,
  //                         color: Colors.blue,
  //                         decoration: TextDecoration.underline,
  //                       ),
  //                     ),
  //                   )
  //                 : isStatus
  //                 ? Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 10,
  //                       vertical: 4,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: _statusBgColor(value),
  //                       borderRadius: BorderRadius.circular(20),
  //                     ),
  //                     child: Text(
  //                       value.toUpperCase(),
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.w600,
  //                         color: _statusTextColor(value),
  //                       ),
  //                     ),
  //                   )
  //                 : Text(
  //                     value,
  //                     textAlign: TextAlign.right,
  //                     maxLines: 5,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _infoRow(
  String label,
  String value, {
  List<String>? media,
  bool isStatus = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        Expanded(
          flex: 4,
          child: Text(
            label,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12,
            ),
          ),
        ),

        /// VALUE
        Expanded(
          flex: 6,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: media != null && media.isNotEmpty
                ? InkWell(
                    onTap: () {
                      _showMediaDialog(context, media);
                    },
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : isStatus
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBgColor(value),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          value.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusTextColor(value),
                          ),
                        ),
                      )
                    : Text(
                        value,
                        textAlign: TextAlign.end,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
          ),
        ),
      ],
    ),
  );
}

  // Media Dialog
  void _showMediaDialog(BuildContext context, List<String> mediaList) {
    final images = mediaList
        .where(
          (media) =>
              media.endsWith(".jpg") ||
              media.endsWith(".png") ||
              media.endsWith(".jpeg") ||
              media.endsWith(".webp"),
        )
        .toList();

    final otherMedia = mediaList
        .where(
          (media) =>
              !media.endsWith(".jpg") &&
              !media.endsWith(".png") &&
              !media.endsWith(".jpeg") &&
              !media.endsWith(".webp"),
        )
        .toList();

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
                            return GestureDetector(
                              onTap: () => _openFullScreenImage(
                                context,
                                images,
                                index,
                              ),
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

  // Reject Reason Bottom Sheet
  void _showRejectReasonSheet(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                AppLocalizations.of(context)!.rejectReason,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.rejectReasonHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PrimaryButton(
                    radius: 15,
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text:  AppLocalizations.of(context)!.cancel,
                    Width: 133,
                  ),
                  PrimaryButton(
                    radius: 15,
                    color: Colors.red,
                    onPressed: () {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        SnackbarHelper.show(
                          context,
                          backgroundColor: Colors.red,
                          message: AppLocalizations.of(context)!.pleaseEnterReason,
                        );
                        return;
                      }
                      debugPrint("reason $reason");
                      acceptrequest(
                        status: "reject",
                        reason: reason,
                      ); // pass reason only for reject
                      Navigator.pop(context);
                    },
                    text: AppLocalizations.of(context)!.save,
                    Width: 133,
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final url =
                    "${ImageBaseUrl.baseUrl}/${images[index].trim()}";
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
