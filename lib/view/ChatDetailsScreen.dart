import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/active_chat_provider.dart';
import 'package:tech_app/services/Stream_Chat_Service.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String? adminId;
  final String? adminName;

  const ChatDetailsScreen({super.key, this.adminId, this.adminName});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late final StreamChatClient client;
  Channel? channel;

  @override
  void initState() {
    super.initState();
    client = StreamChatService().client;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final userId = await Appperfernces.getTechId();
    final adminId = widget.adminId;

    if (userId == null || adminId == null) return;

    await StreamChatService().connectUserIfNeeded(userId);

    channel = client.channel(
      'messaging',
      extraData: {
        'members': [userId, adminId],
      },
    );

    await channel!.watch();

    if (mounted) setState(() {});
  }
@override
Widget build(BuildContext context) {
  if (channel == null) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.adminName ?? "Chat")),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  return StreamChat(
    client: client, // ✅ REQUIRED
    child: StreamChannel(
      channel: channel!, // ✅ CORRECT
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary_clr,
                child: Text(
                  widget.adminName != null &&
                          widget.adminName!.isNotEmpty
                      ? widget.adminName![0].toUpperCase()
                      : "A",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.adminName ?? "Admin",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: 
   Column(
  children: [
    Expanded(
      child: StreamMessageListView(
          showFloatingDateDivider: false, // ✅ IMPORTANT (removes duplicate)

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
                  backgroundColor: AppColors.primary_clr,
                  child: Text(
                    (widget.adminName?.isNotEmpty ?? false)
                        ? widget.adminName![0].toUpperCase()
                        : "A",
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

    /// ✅ FILE UPLOAD REMOVED HERE
    StreamMessageInput(
      attachmentButtonBuilder: (context, onPressed) {
        return const SizedBox.shrink();
      },
    ),
  ],
),
      ),
    ),
  );
}
}