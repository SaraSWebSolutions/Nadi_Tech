import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/routes/route_name.dart';
import 'package:tech_app/widgets/inputs/primary_button.dart';

class AcceptedView extends StatefulWidget {
  const AcceptedView({super.key});

  @override
  State<AcceptedView> createState() => _AcceptedViewState();
}

class _AcceptedViewState extends State<AcceptedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.scoundry_clr,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.scoundry_clr,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.customerDetails,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.name,
                            "MohammadSiraj",
                          ),
                          const Divider(),
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.email,
                            "MohammadSiraj@gmail.in",
                          ),
                          const Divider(),
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.phone,
                            "+973 78787887",
                          ),
                          const Divider(),
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.address,
                            "Building 12 Appartment1,floor2,Muharg",
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.locationLabel,
                                style: TextStyle(
                                  color: AppColors.lightgray_clr,
                                  fontSize: 12,
                                ),
                              ),

                              Container(
                                height: 90,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromARGB(
                                    196,
                                    189,
                                    185,
                                    185,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(),
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.distance,
                            AppLocalizations.of(context)!.distanceKm('7'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.scoundry_clr,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.scoundry_clr,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.serviceDetails,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.serviceType,
                            "MohammadSiraj",
                          ),
                          const Divider(),
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.description,
                            "kjshruihkbxzkheruiwhjkasfhiuwryjkdbzfjklgweuiargkjszdfhiuwer8kjdhgiseurodioeshtoi",
                          ),
                          const Divider(),
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.dateRequired,
                            "2025-10-15",
                          ),
                          const Divider(),
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.timeWindow,
                            "10:00AM - 12:00Am",
                          ),
                          const Divider(),
                          _infoRow(
                            context,
                            AppLocalizations.of(context)!.dateCreated,
                            "2025-10-15",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: PrimaryButton(
                  radius: 13,
                  height: 50,
                  Width: double.infinity,
                  color: AppColors.scoundry_clr,
                  onPressed: () {
                    context.push(RouteName.updated_status);
                  },
                  text: AppLocalizations.of(context)!.start,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.lightgray_clr, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
