import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/core/utils/Time_Date.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/provider/notification_Service_Provider.dart';
import 'package:tech_app/services/NotificationApiService.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/widgets/AppCircleAvatar.dart';

class Notifications extends ConsumerStatefulWidget {
  const Notifications({super.key});

  @override
  ConsumerState<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends ConsumerState<Notifications> {
  final Notificationapiservice _notificationapi = Notificationapiservice();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // ✅ Mark all notifications as read in backend
        await ref.read(notificationServiceProvider.notifier).markAllAsRead();
      } catch (e) {
        debugPrint("Mark all as read error: $e");
      }
    });
  }

  Future<void> _showClearAllDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.deleteNotificationTitle),
          content: Text(l10n.clearAllNotificationsConfirm),

          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          actions: [
            Row(
              children: [
                // ❌ CANCEL (outlined / blocked style)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 🗑 DELETE (danger red button)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          l10n.delete,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
        // return AlertDialog(
        //   title: Text(l10n.deleteNotificationTitle),
        //   content: Text(l10n.clearAllNotificationsConfirm),
        //   actions: [
        //     TextButton(
        //       onPressed: () => Navigator.pop(dialogContext, false),
        //       child: Text(l10n.cancel),
        //     ),
        //     ElevatedButton(
        //       style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        //       onPressed: () => Navigator.pop(dialogContext, true),
        //       child: Text(l10n.delete),
        //     ),
        //   ],
        // );
      },
    );

    if (confirm == true) {
      await ref.read(notificationServiceProvider.notifier).deleteAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationAsync = ref.watch(notificationServiceProvider);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.app_background_clr,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 180, 189, 230),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        actions: [
          if (notificationAsync.asData?.value.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                onPressed: _showClearAllDialog,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),

      body: notificationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, _) =>
            Center(child: Text(l10n.errorWithDetail(err.toString()))),

        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(child: Text(l10n.noNotifications));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(notificationServiceProvider.notifier).refresh();
            },

            child: ListView.builder(
              itemCount: notifications.length,

              itemBuilder: (context, index) {
                final n = notifications[index];

                return Dismissible(
                  key: Key(n.id.toString()),

                  direction: DismissDirection.endToStart,

                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  confirmDismiss: (direction) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        final dlg = AppLocalizations.of(dialogContext)!;
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),

                          title: Text(dlg.deleteNotificationTitle),
                          content: Text(dlg.deleteNotificationConfirm),

                          actionsPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),

                          actions: [
                            Row(
                              children: [
                                // ❌ CANCEL (blocked style)
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: Text(
                                      dlg.cancel,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // 🗑 DELETE (red danger button)
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );

                    return confirm ?? false;
                  },

                  onDismissed: (direction) async {
                    await ref
                        .read(notificationServiceProvider.notifier)
                        .deleteSingle(n.id);
                  },

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    child: Container(
                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 42,
                            width: 42,

                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),

                            child: Icon(
                              n.type == "Service Request"
                                  ? Icons.work_outline
                                  : Icons.inventory_2_outlined,
                              color: Colors.blue,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.type,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  n.message,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Colors.black,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  formatDateForUI(n.time),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
