import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_app/provider/language_provider.dart';
import 'package:tech_app/services/InventoryMaterial_List_Service.dart';

// final inventorylistprovider = FutureProvider((ref)async{
//   final local = ref.watch(languageProvider);
//   final lang = local.languageCode;
//   final result = InventorymaterialListService().InventoryList(lang);
//   return result ;
// });
final inventoryListProvider = FutureProvider((ref) async {
  final lang = ref.watch(languageProvider).languageCode;
  final result = InventorymaterialListService().InventoryList(lang);
  return result;
});
