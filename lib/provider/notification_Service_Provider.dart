import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tech_app/model/NotificationModel.dart';
import 'package:tech_app/services/NotificationApiService.dart';

final notificationServiceProvider =
    StateNotifierProvider<NotificationNotifier,
        AsyncValue<List<NotificationModel>>>(
  (ref) => NotificationNotifier(),
);

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {

  NotificationNotifier()
      : super(const AsyncLoading()) {
    fetchNotifications();
  }

  final Notificationapiservice _api =
      Notificationapiservice();

  // ================= FETCH =================
  Future<void> fetchNotifications() async {

    try {

      final notifications =
          await _api.fetchnodification();

      state = AsyncData(notifications);

    } catch (e, st) {

      state = AsyncError(e, st);

    }
  }

  // ================= REFRESH =================
  Future<void> refresh() async {
    await fetchNotifications();
  }

  // ================= MARK READ =================
Future<void> markAllAsRead() async {

  try {

    debugPrint("🔥 markAllAsRead START");

    // backend API
    await _api.markAllAsRead();

    debugPrint("✅ API SUCCESS");

    // instant UI update
    state.whenData((list) {

      final updated = list.map((e) {

        debugPrint(
          "Before => ${e.id} read:${e.read}",
        );

        final item = e.copyWith(
          read: true,
        );

        debugPrint(
          "After => ${item.id} read:${item.read}",
        );

        return item;

      }).toList();

      state = AsyncData(updated);

      debugPrint("✅ STATE UPDATED");

    });

  } catch (e, st) {

    debugPrint("❌ markAllAsRead ERROR: $e");

    debugPrintStack(stackTrace: st);

    state = AsyncError(e, st);

  }
}

  // ================= DELETE ALL =================
  Future<void> deleteAll() async {

    try {

      await _api.deleteallnotifications();

      state = const AsyncData([]);

    } catch (e, st) {

      state = AsyncError(e, st);

    }
  }

  // ================= DELETE SINGLE =================
  Future<void> deleteSingle(String id) async {

    try {

      await _api.deletesinglenotification(id: id);

      state.whenData((list) {

        state = AsyncData(
          list.where((e) => e.id != id).toList(),
        );

      });

    } catch (e, st) {

      state = AsyncError(e, st);

    }
  }
}