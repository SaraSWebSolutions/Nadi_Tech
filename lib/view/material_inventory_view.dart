import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/provider/InventoryList_provider.dart';
import 'package:tech_app/provider/connectivity_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/widgets/card/material_cart.dart';
import 'package:tech_app/widgets/card/shimmer_loader.dart';
import 'package:tech_app/widgets/header.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';
import 'package:tech_app/widgets/no_internet_widget.dart';

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
    Future.microtask(() => ref.refresh(inventorylistprovider));
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventorylistprovider);
    final connectivity = ref.watch(connectivityProvider);

    return Scaffold(
      body: SafeArea(
        child: connectivity.when(
          data: (isOnline) {
            if (!isOnline) {
              return NoInternetScreen();
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Header(
                    title: AppLocalizations.of(context)!.materialInventory,
                    showRefreshIcon: true,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),

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
                              const Text(
                                "No inventory found",
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
                          itemCount: inventoryMaterial.data.length,
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
