import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/provider/InventoryList_provider.dart';
import 'package:tech_app/provider/bottom_nav_provider.dart';
import 'package:tech_app/provider/connectivity_provider.dart';
import 'package:tech_app/provider/home_tab_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/widgets/card/material_cart.dart';
import 'package:tech_app/widgets/card/shimmer_loader.dart';
import 'package:tech_app/widgets/header.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';
import 'package:tech_app/widgets/no_internet_widget.dart';
import 'package:flutter/services.dart';

class MaterialInventoryView extends ConsumerStatefulWidget {
  const MaterialInventoryView({super.key});

  @override
  ConsumerState<MaterialInventoryView> createState() =>
      _MaterialInventoryViewState();
}

class _MaterialInventoryViewState extends ConsumerState<MaterialInventoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(inventoryListProvider));
  }

  DateTime? _lastBackPressTime;
  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryListProvider);
    final connectivity = ref.watch(connectivityProvider);
    // return Scaffold(
    //   backgroundColor: const Color(0xffF5F7FB),

    //   body: Column(
    //     children: [
    //       /// HEADER
    //       Container(
    //         // padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
    //         decoration: const BoxDecoration(
    //           color: AppColors.app_background_clr,
    //           borderRadius: BorderRadius.only(
    //             bottomLeft: Radius.circular(30),
    //             bottomRight: Radius.circular(30),
    //           ),
    //         ),
    //         child: Header(
    //           title: AppLocalizations.of(context)!.materialInventory,
    //           showRefreshIcon: true,
    //           showBackButton: true,
    //           showNotificationIcon: false,
    //           showProfileIcon: false,
    //           onBackPressed: () {
    //             ref.read(bottomNavProvider.notifier).state = 0;
    //           },
    //         ),
    //       ),

    //       Expanded(
    //         child: inventoryAsync.when(
    //           loading: () => ListView.builder(
    //             padding: const EdgeInsets.all(10),
    //             itemCount: 6,
    //             itemBuilder: (_, __) =>
    //                 const ShimmerLoader(height: 100, width: double.infinity),
    //           ),

    //           error: (err, _) => Center(
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Image.asset("assets/images/inven.png", height: 120),
    //                 const SizedBox(height: 15),
    //                 Text(
    //                   AppLocalizations.of(context)!.noMaterialFound,
    //                   style: const TextStyle(
    //                     fontSize: 16,
    //                     fontWeight: FontWeight.w600,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),

    //           data: (inventoryMaterial) {
    //             if (inventoryMaterial.data.isEmpty) {
    //               return Center(
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Image.asset("assets/images/inven.png", height: 120),
    //                     const SizedBox(height: 15),
    //                     Text(
    //                       AppLocalizations.of(context)!.noInventoryFound,
    //                       style: const TextStyle(
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.w600,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               );
    //             }

    //             final totalProducts = inventoryMaterial.data.length;

    //             final totalStock = inventoryMaterial.data.fold<int>(
    //               0,
    //               (sum, item) =>
    //                   sum + (int.tryParse(item.count.toString()) ?? 0),
    //             );

    //             return Column(
    //               children: [
    //                 /// SUMMARY CARD
    //                 Container(
    //                   margin: const EdgeInsets.all(16),
    //                   padding: const EdgeInsets.symmetric(
    //                     horizontal: 20,
    //                     vertical: 18,
    //                   ),
    //                   decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(20),
    //                     boxShadow: const [
    //                       BoxShadow(
    //                         color: Colors.black12,
    //                         blurRadius: 10,
    //                         offset: Offset(0, 4),
    //                       ),
    //                     ],
    //                   ),
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           children: [
    //                             Text(
    //                               "$totalProducts",
    //                               style: const TextStyle(
    //                                 fontSize: 22,
    //                                 fontWeight: FontWeight.bold,
    //                               ),
    //                             ),
    //                             const SizedBox(height: 4),
    //                             const Text(
    //                               "Materials",
    //                               style: TextStyle(color: Colors.grey),
    //                             ),
    //                           ],
    //                         ),
    //                       ),

    //                       Container(
    //                         width: 1,
    //                         height: 40,
    //                         color: Colors.grey.shade300,
    //                       ),

    //                       Expanded(
    //                         child: Column(
    //                           children: [
    //                             Text(
    //                               "$totalStock",
    //                               style: const TextStyle(
    //                                 fontSize: 22,
    //                                 fontWeight: FontWeight.bold,
    //                                 color: AppColors.primary_clr,
    //                               ),
    //                             ),
    //                             const SizedBox(height: 4),
    //                             const Text(
    //                               "Total Stock",
    //                               style: TextStyle(color: Colors.grey),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),

    //                 /// INVENTORY LIST
    //                 Expanded(
    //                   child: AnimationLimiter(
    //                     child: ListView.builder(
    //                       padding: const EdgeInsets.only(
    //                         left: 16,
    //                         right: 16,
    //                         bottom: 20,
    //                       ),
    //                       itemCount: inventoryMaterial.data.length,
    //                       itemBuilder: (context, index) {
    //                         final item = inventoryMaterial.data[index];

    //                         final productName = item.productId.productName;

    //                         final price = item.productId.price;

    //                         final stock =
    //                             int.tryParse(item.count.toString()) ?? 0;

    //                         final stockColor = stock <= 2
    //                             ? Colors.red
    //                             : AppColors.primary_clr;

    //                         return AnimationConfiguration.staggeredList(
    //                           position: index,
    //                           duration: const Duration(milliseconds: 700),
    //                           child: SlideAnimation(
    //                             verticalOffset: 40,
    //                             child: FadeInAnimation(
    //                               child: Container(
    //                                 margin: const EdgeInsets.only(bottom: 14),
    //                                 padding: const EdgeInsets.all(16),
    //                                 decoration: BoxDecoration(
    //                                   color: Colors.white,
    //                                   borderRadius: BorderRadius.circular(20),
    //                                   boxShadow: const [
    //                                     BoxShadow(
    //                                       color: Colors.black12,
    //                                       blurRadius: 8,
    //                                       offset: Offset(0, 4),
    //                                     ),
    //                                   ],
    //                                 ),
    //                                 child: Row(
    //                                   children: [
    //                                     Container(
    //                                       height: 60,
    //                                       width: 60,
    //                                       decoration: BoxDecoration(
    //                                         color: AppColors.scoundry_clr
    //                                             .withOpacity(.15),
    //                                         shape: BoxShape.circle,
    //                                       ),
    //                                       child: const Icon(
    //                                         Icons.inventory_2_outlined,
    //                                         size: 28,
    //                                         color: AppColors.scoundry_clr,
    //                                       ),
    //                                     ),

    //                                     const SizedBox(width: 15),

    //                                     Expanded(
    //                                       child: Column(
    //                                         crossAxisAlignment:
    //                                             CrossAxisAlignment.start,
    //                                         children: [
    //                                           Text(
    //                                             productName,
    //                                             style: const TextStyle(
    //                                               fontSize: 18,
    //                                               fontWeight: FontWeight.w600,
    //                                             ),
    //                                           ),

    //                                           const SizedBox(height: 8),

    //                                           Container(
    //                                             padding:
    //                                                 const EdgeInsets.symmetric(
    //                                                   horizontal: 10,
    //                                                   vertical: 4,
    //                                                 ),
    //                                             decoration: BoxDecoration(
    //                                               color: stockColor.withOpacity(
    //                                                 .1,
    //                                               ),
    //                                               borderRadius:
    //                                                   BorderRadius.circular(20),
    //                                             ),
    //                                             child: Text(
    //                                               "$stock In Stock",
    //                                               style: TextStyle(
    //                                                 color: stockColor,
    //                                                 fontWeight: FontWeight.bold,
    //                                               ),
    //                                             ),
    //                                           ),

    //                                           const SizedBox(height: 8),

    //                                           Text(
    //                                             "BHD $price",
    //                                             style: const TextStyle(
    //                                               fontSize: 16,
    //                                               fontWeight: FontWeight.bold,
    //                                               color: AppColors.primary_clr,
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         );
    //                       },
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             );
    //           },
    //         ),
    //       ),

    //       /// BUTTON
    //       SafeArea(
    //         top: false,
    //         child: Container(
    //           padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    //           // decoration: const BoxDecoration(
    //           //   color: Colors.white,
    //           //   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
    //           // ),
    //           child: PrimaryButton(
    //             radius: 15,
    //             color: AppColors.scoundry_clr,
    //             isLoading: inventoryAsync.isLoading,
    //             onPressed: () {
    //               context.push(RouteName.material_request);
    //             },
    //             Width: double.infinity,
    //             height: 55,
    //             text: AppLocalizations.of(context)!.requestMaterial,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        final now = DateTime.now();

        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press back again to exit"),
              duration: Duration(seconds: 2),
            ),
          );

          return;
        }

        // Exit app on second press
        await SystemNavigator.pop();
      },
      child: Scaffold(
        body: connectivity.when(
          data: (isOnline) {
            if (!isOnline) {
              return NoInternetScreen();
            }
            return Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.app_background_clr,
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(20),
                    //   bottomRight: Radius.circular(20),
                    // ),
                  ),
                  // padding: EdgeInsets.only(
                  //   top: MediaQuery.of(context).padding.top + 8,
                  //   left: 12,
                  //   right: 12,
                  //   bottom: 12,
                  // ),
                  child: Header(
                    title: AppLocalizations.of(context)!.materialInventory,
                    showRefreshIcon: true,
                    showBackButton: true,
                    showNotificationIcon: false,
                    showProfileIcon: false,
                    onBackPressed: () {
                      ref.read(bottomNavProvider.notifier).state = 0;
                    },
                  ),
                ),

                // const SizedBox(height: 15),
                Expanded(
                  child: inventoryAsync.when(
                    loading: () => ListView.builder(
                      itemCount: 6,
                      itemBuilder: (context, index) => const ShimmerLoader(
                        height: 87,
                        width: double.infinity,
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/inven.png",
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.noMaterialFound,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(13, 95, 72, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: (inventoryMaterial) {
                      if (inventoryMaterial.data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/inven.png",
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.noInventoryFound,
                                style: const TextStyle(
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
                          itemCount: inventoryMaterial.data.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final item = inventoryMaterial.data[index];
                            final productName = item.productId.productName;
                            final price = item.productId.price;
                            final count = item.count;

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 1000),
                              child: SlideAnimation(
                                verticalOffset: 40,
                                curve: Curves.easeOutCubic,
                                child: MaterialCart(
                                  productName: productName,
                                  count: count,
                                  price: price,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PrimaryButton(
                    radius: 10,
                    color: AppColors.scoundry_clr,
                    isLoading: inventoryAsync.isLoading,
                    onPressed: () {
                      context.push(RouteName.material_request);
                    },
                    Width: double.infinity,
                    height: 50,
                    text: AppLocalizations.of(context)!.requestMaterial,
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
