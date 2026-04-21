import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/core/utils/Time_Date.dart';
import 'package:tech_app/provider/notification_Service_Provider.dart';
import 'package:tech_app/services/NotificationApiService.dart';
class Notifications extends ConsumerStatefulWidget {
  const Notifications({super.key});

  @override
  ConsumerState<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends ConsumerState<Notifications> {

  @override
  Widget build(BuildContext context) {
    final Notificationapiservice _notificationapi = Notificationapiservice();
    final notificationAsync = ref.watch(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () async {
                await _notificationapi.deleteallnotifications();
                ref.refresh(notificationServiceProvider);
              },
              child: Image.asset("assets/images/notification.png"),
            ),
          ),
        ],
      ),

      body: notificationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, _) => Center(child: Text("Error: $err")),

        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text("No notifications", style: TextStyle()),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(notificationServiceProvider);
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];

                return Dismissible(
                  key: Key(n.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  onDismissed: (direction) async {
                    notifications.removeAt(index);
                    await _notificationapi.deletesinglenotification(id: n.id);
                    ref.refresh(notificationServiceProvider);
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
