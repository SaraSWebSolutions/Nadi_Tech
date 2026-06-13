import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/preferences/AppPerfernces.dart';
import 'package:tech_app/provider/active_chat_provider.dart';
import 'package:tech_app/services/Stream_Chat_Service.dart';
import 'package:tech_app/widgets/header.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.app_background_clr,
              // borderRadius: BorderRadius.only(
              //   bottomLeft: Radius.circular(20),
              //   bottomRight: Radius.circular(20),
              // ),
            ),
            // padding: EdgeInsets.only(
            //   top: MediaQuery.of(context).padding.top,
            //   left: 15,
            //   right: 15,
            //   bottom: 12,
            // ),
            child: Header(
              title: widget.adminName ?? AppLocalizations.of(context)!.chat,
              showBackButton: true,
              showNotificationIcon: false,
              showRefreshIcon: false,
              onBackPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),

          /// ================= BODY =================
          Expanded(
            child: channel == null
                ? const Center(child: CircularProgressIndicator())
                : StreamChat(
                    client: client,
                    child: StreamChannel(
                      channel: channel!,
                      child: Column(
                        children: [
                          /// ================= CHAT LIST =================
                          Expanded(
                            child: StreamMessageListView(
                              showFloatingDateDivider: false,
                              messageBuilder:
                                  (context, details, messages, defaultMessage) {
                                    final message = details.message;

                                    final currentUser = StreamChat.of(
                                      context,
                                    ).client.state.currentUser;

                                    final isMe =
                                        message.user?.id == currentUser?.id;

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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                                AppColors.primary_clr,
                                            child: Text(
                                              (widget.adminName?.isNotEmpty ??
                                                      false)
                                                  ? widget.adminName![0]
                                                        .toUpperCase()
                                                  : AppLocalizations.of(
                                                      context,
                                                    )!.admin[0],
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
                                              showUserAvatar:
                                                  DisplayWidget.gone,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            ),
                          ),

                          /// ================= INPUT =================
                          StreamChatTheme(
                            data:
                                StreamChatThemeData.fromTheme(
                                  Theme.of(context),
                                ).copyWith(
                                  ownMessageTheme: StreamMessageThemeData(
                                    messageBackgroundColor:
                                        AppColors.app_background_clr,
                                    messageBorderColor: Colors.white
                                        .withOpacity(0.15),
                                    messageTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    avatarTheme: const StreamAvatarThemeData(
                                      constraints: BoxConstraints.tightFor(
                                        width: 0,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                  otherMessageTheme: StreamMessageThemeData(
                                    messageBackgroundColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1F1F1F)
                                        : Colors.grey.shade200,
                                    messageBorderColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.grey.shade300,
                                    messageTextStyle: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  messageInputTheme:
                                      StreamMessageInputThemeData(
                                        inputBackgroundColor:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF1A1A1A)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        inputTextStyle: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 15,
                                        ),
                                        inputDecoration: InputDecoration(
                                          hintText: AppLocalizations.of(
                                            context,
                                          )!.writeMessage,
                                          hintStyle: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white54
                                                : Colors.grey.shade500,
                                          ),
                                          filled: true,
                                          fillColor:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF1F1F1F)
                                              : Colors.grey.shade100,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 18,
                                                vertical: 10,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            borderSide: BorderSide(
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white.withOpacity(
                                                      0.06,
                                                    )
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            borderSide: const BorderSide(
                                              color:
                                                  AppColors.app_background_clr,
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                        sendButtonColor:
                                            AppColors.app_background_clr,
                                        actionButtonColor:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                      ),
                                ),
                            child: Container(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF0D0D0D)
                                  : Colors.white,
                              padding: EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 4,
                                bottom:
                                    MediaQuery.of(context).viewPadding.bottom >
                                        0
                                    ? 2
                                    : 4,
                              ),
                              child: StreamMessageInput(
                                attachmentButtonBuilder: (context, onPressed) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
