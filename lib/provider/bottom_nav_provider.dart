import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final bottomNavProvider = StateNotifierProvider<BottomNavNotifier, int>((ref) {
  return BottomNavNotifier();
});

class BottomNavNotifier extends StateNotifier<int> {
  BottomNavNotifier() : super(0);

  void changeTab(int index) {
    state = index;
  }
}
