import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/utils/snackbar_helper.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/model/Inventory_Material_Model.dart';
import 'package:tech_app/provider/language_provider.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/services/MaterialRequest_service.dart';
import 'package:tech_app/services/ProductList.dart';
import 'package:tech_app/widgets/header.dart';
import 'package:tech_app/widgets/inputs/app_dropdown.dart';
import 'package:tech_app/widgets/inputs/app_text_field.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';

class MaterialRequest extends ConsumerStatefulWidget {
  const MaterialRequest({super.key});

  @override
  ConsumerState<MaterialRequest> createState() => _MaterialRequestState();
}

class _MaterialRequestState extends ConsumerState<MaterialRequest> {
  Product? selectedProduct;
  List<Product> products = [];
  bool isLoading = false;
  final Productlist _productlist = Productlist();
  final MaterialrequestService _materialrequestService =
      MaterialrequestService();
  final _quantity = TextEditingController();
  final _optionalissuse = TextEditingController();
  final _fromkey = GlobalKey<FormState>();
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
      final int quantity = int.parse(_quantity.text);

      setState(() {
        isLoading = true;
      });

      final payload = <String, dynamic>{
        "requests": [
          {
            "productId": selectedProduct!.id,
            "quantity": quantity,
            "notes": _optionalissuse.text.trim(), // ✅ ADD THIS
          },
        ],
      };

      final result = await _materialrequestService.fetchmaterialrequest(
        payload: payload,
      );

      setState(() {
        isLoading = false;
      });

      SnackbarHelper.show(
        context,
        backgroundColor: AppColors.app_background_clr,
        message: AppLocalizations.of(context)!.materialRequestSuccess,
      );

      context.pop();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 CUSTOM HEADER
            Header(
              title: AppLocalizations.of(context)!.materialRequest,
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

            const Divider(height: 1),

            // 🔹 CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _fromkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.materialName,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 15),

                        AppDropdown(
                          label: AppLocalizations.of(context)!.selectProduct,
                          items: products.map((e) => e.productName).toList(),
                          value: selectedProduct?.productName,
                          validator: (value) => value == null
                              ? AppLocalizations.of(
                                  context,
                                )!.pleaseSelectProduct
                              : null,
                          onChanged: (value) {
                            final product = products.firstWhere(
                              (e) => e.productName == value,
                            );
                            setState(() {
                              selectedProduct = product;
                            });
                          },
                        ),

                        const SizedBox(height: 25),

                        Text(AppLocalizations.of(context)!.quantityNeeded),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: AppLocalizations.of(context)!.exampleQuantity,
                          controller: _quantity,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.enterQuantity;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 25),

                        Text(AppLocalizations.of(context)!.optionalNotes),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: AppLocalizations.of(
                            context,
                          )!.optionalNotesHint,
                          controller: _optionalissuse,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 35),

                        PrimaryButton(
                          radius: 12,
                          color: AppColors.primary_clr,
                          Width: double.infinity,
                          height: 50,
                          onPressed: () {
                            context.push(RouteName.bulk_request);
                          },
                          text: AppLocalizations.of(context)!.addBulkRequest,
                          icon: const Icon(
                            Icons.add,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        PrimaryButton(
                          radius: 12,
                          color: AppColors.app_background_clr,
                          Width: double.infinity,
                          height: 50,
                          isLoading: isLoading,
                          onPressed: () {
                            if (_fromkey.currentState!.validate()) {
                              submitrequest();
                            }
                          },
                          text: AppLocalizations.of(context)!.submitRequest,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
