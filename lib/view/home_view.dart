import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/network/dio_client.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/model/StatusFilter_Model.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/connectivity_provider.dart';
import 'package:tech_app/provider/notification_Service_Provider.dart';
import 'package:tech_app/provider/service_list_provider.dart';
import 'package:tech_app/provider/service_timer_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/Timmer_Service.dart';
import 'package:tech_app/widgets/card/income_cart.dart';
import 'package:tech_app/widgets/card/shimmer_loader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tech_app/widgets/header.dart';
import 'package:tech_app/widgets/no_internet_widget.dart';
import 'package:tech_app/provider/home_tab_provider.dart';
import 'package:tech_app/model/TechnicianProfile_Model.dart';
import 'package:tech_app/services/TechnicianProfile_Service.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int selectedIndex = 0;
  final TimerService _timerService = TimerService();
  bool timerLoaded = false;
  final TechnicianprofileService _profileService = TechnicianprofileService();
  bool _isNavigating = false;
  TechnicianProfile? _profile;
  DateTime? _lastTap;
  final ScrollController _scrollController = ScrollController();
  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;

    final offset = (index * 100) - (screenWidth / 2) + 50;

    _scrollController.animateTo(
      offset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = ref.read(homeTabProvider);
      _scrollToIndex(index);
    });

    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final response = await _profileService.tech_profile();

      if (!mounted) return;

      if (response.data.image != null && response.data.image!.isNotEmpty) {
        await precacheImage(
          CachedNetworkImageProvider(
            '${ImageBaseUrl.baseUrl}/${response.data.image}',
          ),
          context,
        );
      }

      setState(() {
        _profile = response;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in-progress':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget statusIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  String normalizeStatus(String status) {
    final s = status.toLowerCase().trim();

    switch (s) {
      case 'pending-approvel': // backend typo
      case 'pending-approval':
        return 'user-approval';

      case 'rejected':
        return 'user-approval'; // 👈 GROUPED HERE
      case 'user-accepted':
        return 'user-approval';

      case 'in-progress':
      case 'inprogress':
      case 'on-hold':
        return 'in-progress';

      case 'completed':
        return 'completed';

      case 'accepted':
        return 'accepted';

      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeTabProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(next);
      });
    });

    final serviceList = ref.watch(serviceListProvider);
    final selectedIndex = ref.watch(homeTabProvider);

    String formatDate(DateTime date) {
      return DateFormat('dd/MM/yyyy hh:mm a').format(date);
    }

    final connectivity = ref.watch(connectivityProvider);
    final lang = AppLocalizations.of(context)!;
    debugPrint("SERVICE LIST STATE => $serviceList");
    final List<StatusFilter> filters = [
      StatusFilter(lang.all, 'all'),
      StatusFilter(lang.accepted, 'accepted'),
      StatusFilter(lang.userApproval, 'user-approval'),
      StatusFilter(lang.inProgress, 'in-progress'),
      StatusFilter(lang.completed, 'completed'),
    ];
    // DateTime? _lastTap;

    // return Scaffold(
    // appBar: PreferredSize(
    //   preferredSize: const Size.fromHeight(60),
    //   child: SafeArea(
    //     bottom: false,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 12),
    //       child: Header(
    //         title: AppLocalizations.of(context)!.incomeRequest,
    //         showNotificationIcon: true,
    //         profile: _profile,
    //       ),
    //     ),
    //   ),
    // ),
    debugPrint("SERVICE LIST STATE => $serviceList");
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Container(
            color: AppColors.app_background_clr,
            // padding: EdgeInsets.only(
            //   top: MediaQuery.of(context).padding.top,
            //   left: 15,
            //   right: 15,
            //   bottom: 12,
            // ),
            child: Header(
              title: AppLocalizations.of(context)!.incomeRequest,
              showNotificationIcon: true,
              profile: _profile,
            ),
          ),

          const SizedBox(height: 10),

          /// ================= FILTER =================
          SizedBox(
            height: 35,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      if (selectedIndex == index) return;
                      ref.read(homeTabProvider.notifier).state = index;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.app_background_clr
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.app_background_clr
                                      .withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.app_background_clr.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        filter.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.app_background_clr,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // const SizedBox(height: 20),

          /// ================= LIST =================
          /// debugPrint("SERVICE LIST STATE => $serviceList");
          Expanded(
            child: serviceList.when(
              data: (data) {
                if (data == null || data.data.isEmpty) {
                  return const Center(child: Text("No requests found"));
                }

                return RefreshIndicator(
                  color: AppColors.app_background_clr,
                  onRefresh: () async {
                    await refreshServiceList(ref);

                    await ref
                        .read(notificationServiceProvider.notifier)
                        .refresh();
                  },
                  child: AnimationLimiter(
                    child: Builder(
                      builder: (context) {
                        final selectedFilter = filters[selectedIndex].value;

                        final filteredData = data.data.where((item) {
                          final normalizedStatus = normalizeStatus(
                            item.assignmentStatus,
                          );

                          return selectedFilter == 'all'
                              ? true
                              : normalizedStatus == selectedFilter;
                        }).toList();
                        print("Selected Filter: $selectedFilter");
                        for (final item in data.data) {
                          print(
                            "Original: ${item.assignmentStatus} | "
                            "Normalized: ${normalizeStatus(item.assignmentStatus)}",
                          );
                        }
                        if (filteredData.isEmpty) {
                          return const Center(
                            child: Text(
                              "No service found",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredData.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final item = filteredData[index];

                            final status = item.assignmentStatus.toLowerCase();
                            print(
                              'assignmentStatus: ${item.assignmentStatus.toLowerCase()}',
                            );
                            //   item.assignmentStatus,
                            // );
                            final color = getStatusColor(status);

                            final serviceName = item.serviceId.nameEn;
                            final service = item.serviceId.name;
                            final issueName = item.issuesId.issueEn;

                            debugPrint("SERVICE: $serviceName,$service");
                            debugPrint("ISSUE: $issueName");

                            return AnimationConfiguration.staggeredList(
                              position: index, // ✅ now correct
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                verticalOffset: 30,
                                child: FadeInAnimation(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10,
                                    ),
                                    child: IncomeCard(
                                      name: item.userId.basicInfo.fullName,
                                      service:
                                          item.serviceId.nameEn ??
                                          item.serviceId.name,
                                      issue: item.issuesId.issueEn,
                                      schedule: formatDate(
                                        item.scheduleService,
                                      ),
                                      assignmentStatus: status, // ✅ normalized
                                      assignments:
                                          item
                                              .technicianUserService
                                              ?.assignments ??
                                          [],
                                      payment: item.payment,
                                      onClick: () async {
                                        final now = DateTime.now();

                                        if (_lastTap != null &&
                                            now.difference(_lastTap!) <
                                                const Duration(
                                                  milliseconds: 800,
                                                )) {
                                          return;
                                        }

                                        _lastTap = now;

                                        await context.push(
                                          RouteName.service_card,
                                          extra: item,
                                        );

                                        if (!mounted) return;

                                        await refreshServiceList(ref);

                                        await ref
                                            .read(
                                              notificationServiceProvider
                                                  .notifier,
                                            )
                                            .refresh();
                                      },
                                      // onClick: () async {
                                      //   if (_isNavigating) return;

                                      //   _isNavigating = true;

                                      //   try {
                                      //     await context.push(
                                      //       RouteName.service_card,
                                      //       extra: item,
                                      //     );

                                      //     await refreshServiceList(ref);

                                      //     await ref
                                      //         .read(
                                      //           notificationServiceProvider
                                      //               .notifier,
                                      //         )
                                      //         .refresh();
                                      //   } finally {
                                      //     _isNavigating = false;
                                      //   }
                                      // },
                                      // onClick: () async {
                                      //   print("CARD CLICKED");

                                      //   if (_isNavigating) {
                                      //     print("BLOCKED BY _isNavigating");
                                      //     return;
                                      //   }

                                      //   _isNavigating = true;

                                      //   try {
                                      //     print("REFRESH SERVICE LIST");
                                      //     await refreshServiceList(ref);

                                      //     print("REFRESH NOTIFICATION");
                                      //     await ref
                                      //         .read(
                                      //           notificationServiceProvider
                                      //               .notifier,
                                      //         )
                                      //         .refresh();

                                      //     print(
                                      //       "STATUS => ${item.serviceStatus}",
                                      //     );

                                      //     if (!context.mounted) {
                                      //       print("CONTEXT NOT MOUNTED");
                                      //       return;
                                      //     }

                                      //     print("BEFORE PUSH");

                                      //     await context.push(
                                      //       RouteName.service_card,
                                      //       extra: item,
                                      //     );

                                      //     print("AFTER PUSH");
                                      //   } catch (e, s) {
                                      //     print("ERROR => $e");
                                      //     print(s);
                                      //   } finally {
                                      //     _isNavigating = false;
                                      //     print("_isNavigating RESET");
                                      //   }
                                      // },
                                      // onClick: () async {
                                      //   final now = DateTime.now();

                                      //   // 1. debounce (300–500ms)
                                      //   if (_lastTap != null &&
                                      //       now.difference(_lastTap!) <
                                      //           const Duration(
                                      //             milliseconds: 500,
                                      //           )) {
                                      //     return;
                                      //   }

                                      //   _lastTap = now;

                                      //   if (_isNavigating) return;
                                      //   _isNavigating = true;

                                      //   try {
                                      //     await refreshServiceList(ref);
                                      //     await ref
                                      //         .read(
                                      //           notificationServiceProvider
                                      //               .notifier,
                                      //         )
                                      //         .refresh();

                                      //     if (!context.mounted) return;

                                      //     await context.push(
                                      //       RouteName.service_card,
                                      //       extra: item,
                                      //     );
                                      //   } finally {
                                      //     _isNavigating = false;
                                      //   }
                                      // },
                                      // onClick: () async {
                                      //   if (_isNavigating) return;

                                      //   _isNavigating = true;

                                      //   try {
                                      //     await refreshServiceList(ref);
                                      //     await ref
                                      //         .read(
                                      //           notificationServiceProvider
                                      //               .notifier,
                                      //         )
                                      //         .refresh();

                                      //     if (!context.mounted) return;

                                      //     await context.push(
                                      //       RouteName.service_card,
                                      //       extra: item,
                                      //     );
                                      //   } finally {
                                      //     _isNavigating = false;
                                      //   }
                                      // },
                                      // onClick: () async {
                                      //   final now = DateTime.now();

                                      //   if (_lastTap != null &&
                                      //       now.difference(_lastTap!) <
                                      //           const Duration(
                                      //             milliseconds: 800,
                                      //           )) {
                                      //     return;
                                      //   }

                                      //   _lastTap = now;

                                      //   if (_isNavigating) return;
                                      //   _isNavigating = true;

                                      //   try {
                                      //     await refreshServiceList(ref);

                                      //     if (!mounted) return;

                                      //     await context.push(
                                      //       RouteName.service_card,
                                      //       extra: item,
                                      //     );
                                      //   } finally {
                                      //     _isNavigating = false;
                                      //   }
                                      // },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text(err.toString())),
              //  error: (err, st) {
              //   debugPrint(err.toString());
              //   debugPrint(st.toString());

              //   return const Center(child: Text("No service found"));
              // },
            ),
          ),
        ],
      ),
    );
  }
}
