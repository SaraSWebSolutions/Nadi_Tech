import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
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
        appBar: AppBar(
          title: Text(widget.adminName ?? AppLocalizations.of(context)!.chat),
        ),
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
            leading: BackButton(color: Colors.black),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary_clr,
                  child: Text(
                    widget.adminName != null && widget.adminName!.isNotEmpty
                        ? widget.adminName![0].toUpperCase()
                        : AppLocalizations.of(context)!.admin[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.adminName ?? AppLocalizations.of(context)!.admin,
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
          body: Column(
            children: [
              Expanded(
                child: StreamMessageListView(
                  showFloatingDateDivider:
                      false, // ✅ IMPORTANT (removes duplicate)

                  messageBuilder: (context, details, messages, defaultMessage) {
                    final message = details.message;
                    final currentUser = StreamChat.of(
                      context,
                    ).client.state.currentUser;

                    final isMe = message.user?.id == currentUser?.id;

                    if (isMe) {
                      return defaultMessage.copyWith(
                        showUsername: false,
                        showUserAvatar: DisplayWidget.gone,
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary_clr,
                            child: Text(
                              (widget.adminName?.isNotEmpty ?? false)
                                  ? widget.adminName![0].toUpperCase()
                                  : AppLocalizations.of(context)!.admin[0],
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
              StreamChatTheme(
                data: StreamChatThemeData.fromTheme(Theme.of(context)).copyWith(
                  ownMessageTheme: StreamMessageThemeData(
                    messageBackgroundColor: AppColors.app_background_clr,

                    // ✅ Better visible border
                    messageBorderColor: Colors.white.withOpacity(0.15),

                    messageTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),

                    avatarTheme: const StreamAvatarThemeData(
                      constraints: BoxConstraints.tightFor(width: 0, height: 0),
                    ),
                  ),

                  otherMessageTheme: StreamMessageThemeData(
                    // ✅ Better dark mode bubble
                    messageBackgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1F1F1F)
                        : Colors.grey.shade200,

                    // ✅ Visible border
                    messageBorderColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.06),

                    // ✅ Better readable text
                    messageTextStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),

                    avatarTheme: const StreamAvatarThemeData(
                      constraints: BoxConstraints.tightFor(width: 0, height: 0),
                    ),
                  ),

                  messageInputTheme: StreamMessageInputThemeData(
                    inputBackgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1A1A1A)
                        : Theme.of(context).colorScheme.surface,

                    borderRadius: BorderRadius.circular(24),

                    inputDecoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.writeMessage,

                      hintStyle: TextStyle(color: Theme.of(context).hintColor),

                      border: InputBorder.none,

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),

                    actionButtonColor: Theme.of(context).iconTheme.color,

                    sendButtonColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                child: Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0D0D0D)
                      : Colors.white,

                  child: StreamMessageInput(
                    attachmentButtonBuilder: (context, onPressed) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),

              /// ✅ FILE UPLOAD REMOVED HERE
              // StreamMessageInput(
              //   attachmentButtonBuilder: (context, onPressed) {
              //     return const SizedBox.shrink();
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
