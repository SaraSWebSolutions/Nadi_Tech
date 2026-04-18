import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/active_chat_provider.dart';
import 'package:tech_app/services/Stream_Chat_Service.dart';

/// Real-time map of { otherUserId → unreadCount } from Stream Chat channels.
/// Automatically refreshes when new messages arrive or messages are read.
final streamUnreadCountsProvider = StreamProvider<Map<String, int>>((ref) async* {
  final techId = await Appperfernces.getTechId();
  if (techId == null) {
    yield {};
    return;
  }

  await StreamChatService().connectUserIfNeeded(techId);
  final client = StreamChatService().client;

  Future<Map<String, int>> fetchUnreadCounts() async {
    try {
      // Get the currently active chat channel so we can exclude it
      final activeChannelId = ref.read(activeChatChannelProvider);

      final channels = await client
          .queryChannels(
            filter: Filter.and([
              Filter.equal('type', 'messaging'),
              Filter.in_('members', [techId]),
            ]),
            channelStateSort: const [SortOption('last_message_at')],
            state: true,
            watch: true,
            presence: false,
          )
          .first;

      final Map<String, int> unreadMap = {};
      for (final channel in channels) {
        // Skip the channel the user is currently viewing
        if (activeChannelId != null && channel.id == activeChannelId) continue;

        final unread = channel.state?.unreadCount ?? 0;
        if (unread == 0) continue;
        final otherMember = channel.state?.members.firstWhere(
          (m) => m.userId != techId,
          orElse: () => Member(),
        );
        final otherId = otherMember?.userId;
        if (otherId != null) unreadMap[otherId] = unread;
      }
      return unreadMap;
    } catch (_) {
      return {};
    }
  }

  // Yield initial counts immediately
  yield await fetchUnreadCounts();

  // Re-yield whenever a new message arrives or messages are marked as read
  await for (final _ in client.on(
    EventType.notificationMessageNew,
    EventType.messageNew,
    EventType.messageRead,
    EventType.notificationMarkRead,
  )) {
    yield await fetchUnreadCounts();
  }
});
