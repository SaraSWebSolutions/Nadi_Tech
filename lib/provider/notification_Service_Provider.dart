import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/model/NotificationModel.dart';
import 'package:tech_app/services/NotificationApiService.dart';

final notificationServiceProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  return Notificationapiservice().fetchnodification();
});
