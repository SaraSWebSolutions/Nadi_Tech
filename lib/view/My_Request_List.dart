import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/utils/Time_Date.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/provider/RequestList_Provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tech_app/provider/connectivity_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/widgets/header.dart';
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

      /// ✅ PROPER HEADER (AppBar instead of Column header)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(
          title: AppLocalizations.of(context)!.myRequests,
          showBackButton: false,
          showNotificationIcon: false,
          showRefreshIcon: false,
          showProfileIcon: false,
        ),
      ),

      body: SafeArea(
        child: connectivity.when(
          data: (isOnline) {
            if (!isOnline) return NoInternetScreen();

            return requestAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (error, stack) => Center(
                child: Text(
                  error.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

              data: (response) {
                final requestList = response.data;

                if (requestList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/Outofstock.png",
                          height: 100,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.noRequestFound,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
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
                        duration: const Duration(milliseconds: 900),
                        child: SlideAnimation(
                          verticalOffset: 40,
                          child: FadeInAnimation(
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 1
                                  : 3,
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                title: Text(
                                  product.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
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
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: AppLocalizations.of(
                                                      context,
                                                    )!.qtyLabel,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: item.quantity
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,

                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
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
                                  label: Text(item.status),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  // backgroundColor: Colors.blue.shade50,
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
      ),
    );
  }
}
