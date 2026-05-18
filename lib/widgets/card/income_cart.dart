import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/core/utils/Time_Date.dart';
import 'package:tech_app/model/ServiceList%20_Model.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/service_timer_provider.dart';
import 'package:tech_app/services/Timmer_Service.dart';

class IncomeCard extends ConsumerStatefulWidget {
  final String name;
  final String service;
  final String? issue;
  final String? schedule;
  final String assignmentStatus;
  final VoidCallback onClick;
  final int? payment;
  final List<Assignment> assignments;

  const IncomeCard({
    super.key,
    required this.name,
    required this.service,
    this.issue,
    this.schedule,
    required this.assignmentStatus,
    required this.onClick,
    this.assignments = const [],
    this.payment,
  });

  @override
  ConsumerState<IncomeCard> createState() => _IncomeCardState();
}

class _IncomeCardState extends ConsumerState<IncomeCard> {
  final TimerService _timerService = TimerService();

  @override
  void initState() {
    super.initState();
    _loadTimerOnHome();
  }

  Future<void> _loadTimerOnHome() async {
    final userServiceId = await Appperfernces.getuserServiceId();

    if (userServiceId == null || userServiceId.isEmpty) {
      debugPrint("UserServiceId is null");
      return;
    }

    try {
      final response = await _timerService.fetchTimerData(
        userServiceId: userServiceId,
      );

      ref
          .read(timerProvider.notifier)
          .initialize(
            totalSeconds: response["totalSeconds"] ?? 0,
            isRunning: response["isRunning"] ?? false,
          );
    } catch (e) {
      debugPrint("Timer load error: $e");
    }
  }

  void logAssignments() {
    if (widget.assignments.isEmpty) {
      debugPrint("❌ No assignments found");
      return;
    }

    debugPrint("========== ASSIGNMENTS DEBUG ==========");

    for (int i = 0; i < widget.assignments.length; i++) {
      final a = widget.assignments[i];

      debugPrint("""
🧾 Assignment #${i + 1}
---------------------------------
Technician ID : ${a.technicianId}
Status        : ${a.status}
Notes         : ${a.notes}
Work Duration : ${a.workDuration}
PaymentRaised : ${a.paymentRaised}
WorkStartedAt : ${a.workStartedAt}
UpdatedAt     : ${a.updatedAt}
Media         : ${a.media}
Used Parts    : ${a.usedParts.map((p) => '${p.productName} x${p.count} = ${p.total}').toList()}
---------------------------------
""");
    }

    debugPrint("========== END ASSIGNMENTS ==========");
  }

  String formatWorkDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignments.isNotEmpty
        ? widget.assignments.first
        : null;

    final timerState = ref.watch(timerProvider);

    logAssignments();
debugPrint("""
======== INCOME CARD ========
Name       : ${widget.name}
Service    : ${widget.service}
Issue      : ${widget.issue}
Schedule   : ${widget.schedule}
Status     : ${widget.assignmentStatus}
Payment    : ${widget.payment}
=============================
""");
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.25)
                : Colors.black.withOpacity(0.15),

            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.onClick,
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.app_background_clr,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.issue ?? "-",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _infoRow(
                        image: Image.asset("assets/images/person.png"),
                        text: widget.name,
                      ),
                    ),

                    if (widget.assignmentStatus.toLowerCase() == 'in-progress')
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: AppColors.primary_clr,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timerState.formattedTime,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.app_background_clr,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                _infoRow(
                  image: Image.asset("assets/images/expect.png"),
                  text: widget.service,
                  iconBg:  const Color.fromARGB(255, 198, 205, 239),
                ),
                const SizedBox(height: 5),
                if (widget.payment != null) ...[
                  _infoRow(
                    image: Image.asset("assets/images/curuncy.png"),
                    text: AppLocalizations.of(context)!.bhdAmount(
                      widget.payment.toString(),
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                _infoRow(
                  icon: Icon(
                    Icons.date_range,
                    size: 18,
                    color: AppColors.scoundry_clr,
                  ),
                  text: " ${formatDateForUI(assignment!.updatedAt!)}",
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    if (assignment.status == "completed") ...[
                      _iconBox(
                        image: Image.asset("assets/images/clock.png"),
                        bgColor: const Color.fromARGB(255, 198, 205, 239),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          formatWorkDuration(assignment.workDuration),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.assignmentStatus == "pending"
                            ? AppColors.scoundry_clr
                            : widget.assignmentStatus == "rejected"
                            ? Colors.red
                            : AppColors.app_background_clr,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        widget.assignmentStatus.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------- REUSABLE ROW --------
  static Widget _infoRow({
    Image? image,
    Icon? icon,
    required String text,
    Color? iconBg,
  }) {
    return Row(
      children: [
        _iconBox(image: image, icon: icon, bgColor: iconBg),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static Widget _iconBox({Image? image, Icon? icon, Color? bgColor}) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(child: image ?? icon ?? const SizedBox()),
    );
  }
}
