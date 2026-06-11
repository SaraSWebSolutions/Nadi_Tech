import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tech_app/core/constants/app_colors.dart';
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

  TechnicianProfile? _profile;
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

      setState(() {
        _profile = response;
      });
    } catch (e) {
      debugPrint("Profile load error: $e");
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

    final List<StatusFilter> filters = [
      StatusFilter(lang.all, 'all'),
      StatusFilter(lang.accepted, 'accepted'),
      StatusFilter("Pending Approval", 'pending-approval'),
      StatusFilter(lang.inProgress, 'in-progress'),
      StatusFilter(lang.completed, 'completed'),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      body: SafeArea(
        child: connectivity.when(
          data: (isOnline) {
            if (!isOnline) return NoInternetScreen();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Header(
                    title: AppLocalizations.of(context)!.incomeRequest,
                    showNotificationIcon: true,
                    profile: _profile,
                  ),
                ),

                // const Divider(),
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
                                    : AppColors.app_background_clr.withOpacity(
                                        0.4,
                                      ),
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

                const SizedBox(height: 20),

                /// ================= LIST =================
                Expanded(
                  child: serviceList.when(
                    data: (data) {
                      if (data == null || data.data.isEmpty) {
                        return const Center(child: Text("No requests found"));
                      }

                      return RefreshIndicator(
                        color: AppColors.app_background_clr,
                        onRefresh: () async {
                          // Refresh service list
                          ref.invalidate(serviceListProvider);

                          // Refresh notifications
                          await ref
                              .read(notificationServiceProvider.notifier)
                              .refresh();
                        },
                        child: AnimationLimiter(
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: data.data.length,
                            itemBuilder: (context, index) {
                              final item = data.data[index];
                              debugPrint("ID: ${item.id}");

                              debugPrint(item.toString());
                              final status = item.assignmentStatus
                                  .toLowerCase();
                              final color = getStatusColor(status);
                              final serviceName = item.serviceId.nameEn;
                              final service = item.serviceId.name;

                              final issueName = item.issuesId.issueEn;

                              debugPrint("SERVICE: $serviceName,$service");
                              debugPrint("ISSUE: $issueName");
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  verticalOffset: 30,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// ================= STATUS =================
                                          // Row(
                                          //   children: [
                                          //     statusIcon(Icons.circle, color),
                                          //     const SizedBox(width: 8),
                                          //     Text(
                                          //       item.assignmentStatus,
                                          //       style: TextStyle(
                                          //         fontWeight: FontWeight.w600,
                                          //         color: color,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          const SizedBox(height: 10),

                                          /// ================= CARD =================
                                          IncomeCard(
                                            name:
                                                item.userId.basicInfo.fullName,
                                            service:
                                                item.serviceId.nameEn ??
                                                item.serviceId.name,
                                            issue: item.issuesId.issueEn,
                                            schedule: formatDate(
                                              item.scheduleService,
                                            ),
                                            assignmentStatus:
                                                item.assignmentStatus,
                                            assignments:
                                                item
                                                    .technicianUserService
                                                    ?.assignments ??
                                                [],
                                            payment: item.payment,
                                            onClick: () async {
                                              // 1. Refresh / update latest data first
                                              ref.invalidate(
                                                serviceListProvider,
                                              );
                                              await ref.read(
                                                serviceListProvider.future,
                                              );

                                              await ref
                                                  .read(
                                                    notificationServiceProvider
                                                        .notifier,
                                                  )
                                                  .refresh();

                                              // 2. Then navigate
                                              context.push(
                                                RouteName.service_card,
                                                extra: item,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, st) => Center(child: Text(err.toString())),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => NoInternetScreen(),
        ),
      ),
    );
  }
}
