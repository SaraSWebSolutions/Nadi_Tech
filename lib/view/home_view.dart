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
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int selectedIndex = 0;
  final TimerService _timerService = TimerService();
  bool timerLoaded = false;
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
    // ghange data format
    String formatDate(DateTime date) {
      return DateFormat('MMMM d, y \'at\' h:mm a').format(date);
    }

    final connectivity = ref.watch(connectivityProvider);
    final lang = AppLocalizations.of(context)!;
    //  FILTER TITLES
    final List<StatusFilter> filters = [
      // StatusFilter('All', 'all'),
      // StatusFilter('Accepted', 'accepted'),
      // StatusFilter('In-progress', 'in-progress'),
      // StatusFilter('Pending', 'pending'),
      // StatusFilter('Completed', 'completed'),
      // StatusFilter('Rejected', 'rejected'),
      StatusFilter(lang.all, 'all'),
      StatusFilter(lang.pending, 'pending'),

      StatusFilter(lang.accepted, 'accepted'),
      StatusFilter(lang.rejected, 'rejected'),

      StatusFilter(lang.inProgress, 'in-progress'),
      StatusFilter(lang.completed, 'completed'),
    ];
    final timerState = ref.watch(timerProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: connectivity.when(
          data: (isOnline) {
            if (!isOnline) {
              return NoInternetScreen();
            }
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),

                  child: Header(
                    title: AppLocalizations.of(context)!.incomeRequest,
                  ),
                ),

                const Divider(),
                const SizedBox(height: 10),

                //  FILTER LIST
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                     controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      final isSelected = selectedIndex == index;

                      return InkWell(
                      onTap: () {
  if (selectedIndex == index) return;

  ref.read(homeTabProvider.notifier).state = index;
},
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.app_background_clr
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColors.app_background_clr),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                filter.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.app_background_clr,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Container(
                              //   height: 20,
                              //   width: 20,
                              //   alignment: Alignment.center,
                              //   decoration: BoxDecoration(
                              //     shape: BoxShape.circle,
                              //     color: isSelected
                              //         ? Colors.white
                              //         : AppColors.primary_clr,
                              //   ),
                              //   child: Text(
                              //     serviceList.asData?.value?.data.length
                              //             .toString() ??
                              //         '0',
                              //     style: TextStyle(
                              //       fontSize: 12,
                              //       fontWeight: FontWeight.w600,
                              //       color: isSelected
                              //           ? AppColors.scoundry_clr
                              //           : Colors.white,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: serviceList.when(
                    data: (data) {
                      if (data == null || data.data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                "assets/images/no_request_found.svg",
                                width: 120, // reduce size
                                height: 120,
                                colorFilter: const ColorFilter.mode(
                                  Color.fromRGBO(13, 95, 72, 1), // green color
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.noRequestFound,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(13, 95, 72, 1),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.app_background_clr,
                       onRefresh: () async {
  ref.invalidate(serviceListProvider);
  ref.invalidate(notificationServiceProvider);
},
                        child: AnimationLimiter(
                          child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: data.data.length,
                          itemBuilder: (context, index) {
                            final item = data.data[index];

                            // Choose widget based on serviceStatus
                            if (item.assignmentStatus.toLowerCase() ==
                                'completed') {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 1000),
                                child: SlideAnimation(
                                  verticalOffset: 40,
                                  curve: Curves.easeOutCubic,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: IncomeCard(
                                        name: item.userId.basicInfo.fullName,
                                        service: item.serviceId.name,
                                        issue: item.issuesId.issue,
                                        assignments:
                                            item
                                                .technicianUserService
                                                ?.assignments ??
                                            [],
                                        // status: item.serviceStatus,
                                        payment: item.payment,

                                        assignmentStatus: item.assignmentStatus,
                                        onClick: () {
                                          context.push(
                                            RouteName.service_card,
                                            extra:
                                                item, // send the full item to next page
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else if (item.assignmentStatus.toLowerCase() ==
                                'in-progress') {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: IncomeCard(
                                  name: item.userId.basicInfo.fullName,
                                  service: item.serviceId.name,
                                  issue: item.issuesId.issue,
                                  schedule: formatDate(item.scheduleService),
                                  // status: item.serviceStatus,
                                  assignmentStatus: item.assignmentStatus,
                                  assignments:
                                      item.technicianUserService?.assignments ??
                                      [],
                                  onClick: () {
                                    context.push(
                                      RouteName.service_card,
                                      extra:
                                          item, // send the full item to next page
                                    );
                                  },
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: IncomeCard(
                                  name: item.userId.basicInfo.fullName,
                                  service: item.serviceId.name,
                                  issue: item.issuesId.issue,
                                  schedule: formatDate(item.scheduleService),
                                  // status: item.serviceStatus,
                                  assignmentStatus: item.assignmentStatus,
                                  assignments:
                                      item.technicianUserService?.assignments ??
                                      [],
                                  onClick: () {
                                    context.push(
                                      RouteName.service_card,
                                      extra:
                                          item, // send the full item to next page
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                        ),
                      );
                    },
                    loading: () => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const ShimmerLoader(
                          height: 140,
                          width: double.infinity,
                        );
                      },
                    ),
                    error: (err, st) => Center(child: Text("Error: $err")),
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
