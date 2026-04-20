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

class ServiceListNotifier extends AsyncNotifier<ServiceListModel?> {

  @override
  Future<ServiceListModel?> build() async {
    // ✅ WATCH TAB HERE (this triggers auto refresh)
    final index = ref.watch(homeTabProvider);

    final filters = [
      'all',
      'pending',
      'accepted',
      'rejected',
      'in-progress',
      'completed'
    ];

    final service = ref.read(serviceListServiceProvider);

    // ✅ DIRECT API CALL (no extra method needed)
    final data = await service.fetchServiceList(
      status: filters[index],
    );

    return data;
  }
}
// class ServiceListNotifier extends AsyncNotifier<ServiceListModel?> {
//   @override
//   Future<ServiceListModel?> build() async {
//     return fetchServiceByStatus('all'); 
//   }

// Future<ServiceListModel?> fetchServiceByStatus(String status) async {
//   final service = ref.read(serviceListServiceProvider);
//   try {
//     state = const AsyncValue.loading();
//     final data = await service.fetchServiceList(status: status.toLowerCase());
//     state = AsyncValue.data(data);
//     return data;
//   } catch (e, st) {
//     state = AsyncValue.error(e, st);
//     return null;
//   }
// }

  

// }







 

 // ServiceListNotifier --> Purpose: control API call + state + refresh