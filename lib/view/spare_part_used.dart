import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/model/OurSpareParts_Model.dart';
import 'package:tech_app/model/UpdatePayment_Model.dart';
import 'package:tech_app/provider/Ourspareparts_Provider.dart';
import 'package:tech_app/provider/UpdatedPayment_Provider.dart';
import 'package:tech_app/provider/service_list_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';
import 'package:tech_app/provider/home_tab_provider.dart';

class SparePartUsed extends ConsumerStatefulWidget {
  final String userServiceId;
  const SparePartUsed({super.key, required this.userServiceId});

  @override
  ConsumerState<SparePartUsed> createState() => _SparePartUsedState();
}

class _SparePartUsedState extends ConsumerState<SparePartUsed> {
  bool sparePartsUsed = false;

  final List<Datum> selectedParts = [];
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.refresh(oursparepartsprovider));
  }

  double get totalAmount {
    double total = 0;
    for (final part in selectedParts) {
      total += part.productId.price * int.parse(part.count);
    }
    return total;
  }

  Map<String, int> partCounts = {};
  @override
  Widget build(BuildContext context) {
    final sparePartsAsync = ref.watch(oursparepartsprovider);
    Future<void> _proceedToPayment() async {
      // store checkbox value
      final bool spareUsedValue = sparePartsUsed;

      // logs (optional)
      for (var part in selectedParts) {
        int count = partCounts[part.productId.id] ?? 1;
        debugPrint(
          "Product: ${part.productId.productName}, "
          "ID: ${part.productId.id}, "
          "Count: $count, "
          "sparePartsUsed: $spareUsedValue",
        );
      }

      // build selected spare parts list
      final List<SelectedSparePart> sparePartList = selectedParts.map((part) {
        return SelectedSparePart(
          productId: part.productId.id,
          count: partCounts[part.productId.id] ?? 1,
        );
      }).toList();

      // create request model
      final UpdatePayment updatePayment = UpdatePayment(
        userServiceId: widget.userServiceId,
        sparePartsUsed: spareUsedValue,
        selectedSpareParts: sparePartList,
      );

      try {
        // call API
        await ref
            .read(updatePaymentServiceProvider)
            .passupdatepayment(updatePayment);

        // 🔥 REFRESH SERVICE LIST API
        ref.invalidate(serviceListProvider);
 ref.read(homeTabProvider.notifier).state = 5;

        context.go(RouteName.bottom_nav);
        // reset after success
        setState(() {
          partCounts.clear();
          selectedParts.clear();
          sparePartsUsed = false;
        });
      } catch (e) {
        debugPrint("Update payment failed: $e");

        // OPTIONAL: show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }

    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// MAIN CHECKBOX
                        Row(
                          children: [
                            Checkbox(
                              value: sparePartsUsed,
                              activeColor: AppColors.app_background_clr,
                              onChanged: (value) {
                                setState(() {
                                  sparePartsUsed = value!;
                                  if (!sparePartsUsed) {
                                    selectedParts.clear();
                                  }
                                });
                              },
                            ),

                            // Wrap the text with a Consumer / sparePartsAsync
                            sparePartsAsync.when(
                              loading: () =>  Text(
                               AppLocalizations.of(context)!.sparePartsUsed,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              error: (_, __) => const Text(
                                "Spare Parts Used",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              data: (response) => Text(
                                "Spare Parts Used (${response.data.length})",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// AVAILABLE PARTS (API)
                        sparePartsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text("Error: $e")),
                          data: (response) {
                            if (response.data.isEmpty) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/Outofstock.png",
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppLocalizations.of(context)!.noSparePartUsed,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(13, 95, 72, 1),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return _availablePartsCard(response.data);
                          },
                        ),

                        const SizedBox(height: 20),

                         Text(
                          AppLocalizations.of(context)!.selectedParts,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        /// SELECTED PARTS LIST (same style logic)
                        ...selectedParts.map((item) {
                          int currentCount = partCounts[item.productId.id] ?? 1;
                          return Container(
                            height: 70,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(Icons.build_outlined),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productId.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,

                                      children: [
                                        Text(
                                          "BHD ${item.productId.price}",
                                          style: const TextStyle(
                                            color: AppColors.scoundry_clr,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                        Container(
                                          height: 27,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary_clr,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // Minus button
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  setState(() {
                                                    if (currentCount > 1) {
                                                      partCounts[item
                                                              .productId
                                                              .id] =
                                                          currentCount - 1;
                                                    }
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.remove,
                                                  color: Colors.white,
                                                  size: 17,
                                                ),
                                              ),

                                              // Count display
                                              Text(
                                                "$currentCount",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              // Plus button
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  setState(() {
                                                    partCounts[item
                                                            .productId
                                                            .id] =
                                                        currentCount + 1;
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 17,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        /// PAYMENT SUMMARY
                        // _paymentSummaryCard(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                PrimaryButton(
                  Width: double.infinity,
                  height: 50,
                  radius: 12,
                  color: AppColors.scoundry_clr,
                  text: AppLocalizations.of(context)!.proceedToPayment,
                  onPressed: _proceedToPayment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// AVAILABLE PARTS CARD (API DATA)
  Widget _availablePartsCard(List<Datum> spareParts) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          _cardHeader(AppLocalizations.of(context)!.availableParts, AppColors.primary_clr),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: spareParts.length,
            itemBuilder: (context, index) {
              final item = spareParts[index];
              final isChecked = selectedParts.contains(item);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: AppColors.scoundry_clr,
                      onChanged: !sparePartsUsed
                          ? null
                          : (value) {
                              setState(() {
                                value == true
                                    ? selectedParts.add(item)
                                    : selectedParts.remove(item);
                              });
                            },
                    ),
                    Expanded(child: Text(item.productId.productName,style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),)),
                    Text(
                      "BHD ${item.productId.price}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// PAYMENT SUMMARY CARD (DYNAMIC)
  // Widget _paymentSummaryCard() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
  //     ),
  //     child: Column(
  //       children: [
  //         _cardHeader(AppLocalizations.of(context)!.paymentSummary, AppColors.lightgray_clr),
  //         Padding(
  //           padding: const EdgeInsets.all(12),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //                Text(AppLocalizations.of(context)!.total),
  //               Text(
  //                 "BHD ${totalAmount.toStringAsFixed(2)}",
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   color: AppColors.primary_clr,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _cardHeader(String title, Color bgColor) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
