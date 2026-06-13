import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/utils/snackbar_helper.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/model/Inventory_Material_Model.dart';
import 'package:tech_app/provider/bottom_nav_provider.dart';
import 'package:tech_app/provider/language_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/MaterialRequest_service.dart';
import 'package:tech_app/services/ProductList.dart';
import 'package:tech_app/widgets/header.dart';
import 'package:tech_app/widgets/inputs/app_dropdown.dart';
import 'package:tech_app/widgets/inputs/app_text_field.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';

class BulkRequest extends ConsumerStatefulWidget {
  const BulkRequest({super.key});

  @override
  ConsumerState<BulkRequest> createState() => _BulkRequestState();
}

class _BulkRequestState extends ConsumerState<BulkRequest> {
  final Productlist _productlist = Productlist();
  bool isLoading = false;
  List<Product> products = []; // master product list

  final MaterialrequestService _materialrequestService =
      MaterialrequestService();

  List<MaterialSelection> materialSelections = [
    MaterialSelection(quantityController: TextEditingController()),
  ];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final lang = ref.read(languageProvider).languageCode;
    final result = await _productlist.fetchproductlist(lang);
    if (!mounted) return;
    setState(() {
      products = result;
    });
  }

  Future<void> submitrequest() async {
    try {
      setState(() => isLoading = true);

      final List<Map<String, dynamic>> requests = [];

      for (final item in materialSelections) {
        if (item.product == null || item.quantityController.text.isEmpty) {
          throw AppLocalizations.of(context)!.fillAllMaterials;
        }

        requests.add({
          "productId": item.product!.id,
          "quantity": int.parse(item.quantityController.text),
        });
      }

      final payload = {"requests": requests};

      await _materialrequestService.fetchmaterialrequest(payload: payload);

      SnackbarHelper.show(
        context,
        backgroundColor: AppColors.scoundry_clr,
        message: AppLocalizations.of(context)!.materialRequestSuccess,
      );
      ref.read(bottomNavProvider.notifier).state = 3;

      context.go(RouteName.bottom_nav);
    } catch (e) {
      SnackbarHelper.show(
        context,
        backgroundColor: Colors.red,
        message: e.toString(),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// ✅ FIXED HEADER (NO OVERFLOW)
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(60),
      //   child: SafeArea(
      //     bottom: false,
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Header(
      //           title: AppLocalizations.of(context)!.bulkRequest,
      //           showBackButton: true,
      //           showNotificationIcon: false,
      //           showRefreshIcon: false,
      //           showProfileIcon: false,
      //           onBackPressed: () {
      //             if (context.canPop()) {
      //               context.pop();
      //             } else {
      //               context.go(RouteName.bottom_nav);
      //             }
      //           },
      //         ),
      //         SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      //       ],
      //     ),
      //   ),
      // ),
      body: Column(
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
            //   left: 15,
            //   right: 15,
            //   bottom: 12,
            // ),
            child: Header(
              title: AppLocalizations.of(context)!.bulkRequest,
              showBackButton: true,
              showNotificationIcon: false,
              showRefreshIcon: false,
              showProfileIcon: false,
              onBackPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteName.bottom_nav);
                }
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ...materialSelections.asMap().entries.map(
                    (entry) => materialCard(entry.key),
                  ),

                  const SizedBox(height: 10),

                  PrimaryButton(
                    radius: 12,
                    color: AppColors.primary_clr,
                    height: 55,
                    Width: double.infinity,
                    onPressed: () {
                      setState(() {
                        materialSelections.add(
                          MaterialSelection(
                            quantityController: TextEditingController(),
                          ),
                        );
                      });
                    },
                    text: AppLocalizations.of(context)!.addNewMaterial,
                    icon: const Icon(Icons.add, size: 25, color: Colors.white),
                  ),

                  const SizedBox(height: 10),

                  PrimaryButton(
                    radius: 12,
                    color: AppColors.app_background_clr,
                    height: 55,
                    isLoading: isLoading,
                    Width: double.infinity,
                    onPressed: submitrequest,
                    text: AppLocalizations.of(context)!.submitRequest,
                  ),

                  /// ✅ FIX: prevents last pixel overflow
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget materialCard(int index) {
    final selection = materialSelections[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.35)
                : Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary_clr,

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Material ${index + 1}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (materialSelections.length > 1)
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        materialSelections.removeAt(index); //  remove card
                      });
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.materialName),
                const SizedBox(height: 8),
                AppDropdown(
                  label: AppLocalizations.of(context)!.selectProduct,
                  items: products.map((e) => e.productName).toList(),
                  value: selection.product?.productName,
                  onChanged: (value) {
                    final product = products.firstWhere(
                      (e) => e.productName == value,
                    );
                    setState(() {
                      selection.product = product;
                    });
                  },
                  validator: (value) => value == null
                      ? AppLocalizations.of(context)!.pleaseSelectProduct
                      : null,
                ),

                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.quantityNeeded),
                const SizedBox(height: 8),

                AppTextField(
                  label: AppLocalizations.of(context)!.exampleQuantity,
                  controller: selection.quantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter quantity";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialSelection {
  Product? product;
  TextEditingController quantityController;

  MaterialSelection({this.product, required this.quantityController});
}
