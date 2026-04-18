import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveChatChannelNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void updateState(String? value) => state = value;
}

final activeChatChannelProvider =
    NotifierProvider<ActiveChatChannelNotifier, String?>(
  () => ActiveChatChannelNotifier(),
);
