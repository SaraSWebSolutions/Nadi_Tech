import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/services/servicelist_service.dart';
import 'package:tech_app/model/ServiceList _Model.dart';
import 'package:tech_app/provider/home_tab_provider.dart';

/// SERVICE PROVIDER
final serviceListServiceProvider = Provider<ServicelistService>((ref) {
  return ServicelistService();
});

/// MAIN PROVIDER
final serviceListProvider =
    AsyncNotifierProvider.autoDispose<ServiceListNotifier, ServiceListModel?>(
      ServiceListNotifier.new,
    );

/// Fetches a single service by id from the full list (used on Details screen).
final serviceDetailProvider = FutureProvider.autoDispose
    .family<Datum?, String>((ref, id) async {
      final service = ref.read(serviceListServiceProvider);
      final data = await service.fetchServiceList(status: 'all');

      for (final item in data.data) {
        if (item.id == id) return item;
      }
      return null;
    });

/// Invalidates and waits for the home list to finish refetching.
Future<void> refreshServiceList(WidgetRef ref) async {
  ref.invalidate(serviceListProvider);
  await ref.read(serviceListProvider.future);
}

Future<void> refreshServiceDetail(WidgetRef ref, String id) async {
  ref.invalidate(serviceDetailProvider(id));
  await ref.read(serviceDetailProvider(id).future);
}

class ServiceListNotifier extends AsyncNotifier<ServiceListModel?> {
  static const _tabFilters = [
    'all',
    'accepted',
    'pending-approval',
    'in-progress',
    'completed',
  ];

  @override
  Future<ServiceListModel?> build() async {
    final index = ref.watch(homeTabProvider);
    final service = ref.read(serviceListServiceProvider);

    // User Approval tab includes both pending-approval and rejected.
    if (index == 2) {
      final pending = await service.fetchServiceList(status: 'pending-approval');
      final rejected = await service.fetchServiceList(status: 'rejected');

      final seen = <String>{};
      final merged = <Datum>[];

      for (final item in [...pending.data, ...rejected.data]) {
        if (seen.add(item.id)) merged.add(item);
      }

      return ServiceListModel(count: merged.length, data: merged);
    }

    return service.fetchServiceList(status: _tabFilters[index]);
  }
}
