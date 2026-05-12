import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/utils/Time_Date.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/provider/RequestList_Provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tech_app/provider/connectivity_provider.dart';
import 'package:tech_app/widgets/no_internet_widget.dart';

class MyRequestList extends ConsumerStatefulWidget {
  const MyRequestList({super.key});

  @override
  ConsumerState<MyRequestList> createState() => _MyRequestListState();
}

class _MyRequestListState extends ConsumerState<MyRequestList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(requestlistprovider));
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(requestlistprovider);
    final connectivity = ref.watch(connectivityProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        title:  Text(AppLocalizations.of(context)!.myRequests,style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 0,
      ),
      body: connectivity.when(
        data: (isOnline) {
          if (!isOnline) {
            return NoInternetScreen();
          }
          return requestAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ),

            data: (response) {
              final requestList = response.data;
              if (requestList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // center vertically
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // center horizontally
                    children: [
                      Image.asset(
                        "assets/images/Outofstock.png",
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                       Text(
                        AppLocalizations.of(context)!.noRequestFound,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(13, 95, 72, 1),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requestList.length,
                  itemBuilder: (context, index) {
                    final item = requestList[index];
                    final product = item.productId;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 1100),
                      child: SlideAnimation(
                        verticalOffset: 40,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(
                                          0.05,
                                        ) // light shadow on dark
                                      : Colors.black.withOpacity(
                                          0.05,
                                        ), // dark shadow on light
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              title: Text(
                                product.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 10,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: AppLocalizations.of(
                                                    context,
                                                  )!.qtyLabel,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: item.quantity,
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primary_clr,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            formatDateForUI(
                                              item.productId.updatedAt,
                                            ),
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              trailing: Chip(
                                label: Text(
                                  item.status,
                                  style: TextStyle(color: Colors.black),
                                ),
                                backgroundColor: Colors.blue.shade50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) => NoInternetScreen(),
      ),
    );
  }
}
