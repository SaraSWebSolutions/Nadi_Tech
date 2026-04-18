import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/active_chat_provider.dart';
import 'package:tech_app/services/Stream_Chat_Service.dart';

class ChatDetailsScreen extends ConsumerStatefulWidget {
  final String? adminId;
  final String? adminName;

  const ChatDetailsScreen({super.key, this.adminId, this.adminName});

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen>
    with WidgetsBindingObserver {
  late final StreamChatClient client;
  Channel? channel;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    client = StreamChatService().client;
    _setupStreamChat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && channel != null) {
      channel!.markRead().catchError((_) {});
    }
  }

  Future<void> _setupStreamChat() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final userId = await Appperfernces.getTechId();
      final adminId = widget.adminId;

      if (userId == null || adminId == null) {
        throw Exception('Missing user information. Please log in again.');
      }

      await StreamChatService().connectUserIfNeeded(userId);

      // Sorted IDs guarantee both sides always resolve the same channel
      final sortedIds = [userId, adminId]..sort();
      final channelId = sortedIds.join('_');

      final ch = client.channel(
        'messaging',
        id: channelId,
        extraData: {
          'members': [userId, adminId],
        },
      );

      await ch.watch();

      // Mark messages as read so unread count resets
      try {
        await ch.markRead();
      } catch (_) {}

      // Listen for new messages and mark them as read immediately
      _messageSubscription = ch.on(EventType.messageNew).listen((_) {
        ch.markRead().catchError((_) {});
      });

      if (mounted) {
        setState(() {
          channel = ch;
          _isLoading = false;
        });
        ref.read(activeChatChannelProvider.notifier).updateState(ch.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    ref.read(activeChatChannelProvider.notifier).updateState(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.adminName ?? 'Chat'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    /// Error state
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.adminName ?? 'Chat'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Could not load chat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _setupStreamChat,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Chat UI — StreamChat is at root (main.dart builder), only StreamChannel needed here
    return StreamChannel(
      channel: channel!,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.scoundry_clr,
                child: Text(
                  (widget.adminName?.isNotEmpty ?? false)
                      ? widget.adminName![0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.adminName ?? 'Admin',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamMessageListView(
                messageBuilder: (context, details, messages, defaultMessage) {
                  final message = details.message;
                  final currentUser =
                      StreamChat.of(context).client.state.currentUser;
                  final isMe = message.user?.id == currentUser?.id;

                  if (isMe) {
                    return defaultMessage.copyWith(
                      showUsername: false,
                      showUserAvatar: DisplayWidget.gone,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.scoundry_clr,
                          child: Text(
                            (widget.adminName?.isNotEmpty ?? false)
                                ? widget.adminName![0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: defaultMessage.copyWith(
                            showUsername: false,
                            showUserAvatar: DisplayWidget.gone,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const StreamMessageInput(),
          ],
        ),
      ),
    );
  }
}
