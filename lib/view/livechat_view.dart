import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_app/core/constants/app_colors.dart';
import 'package:tech_app/provider/Chats_List_Provider.dart';
import 'package:tech_app/provider/connectivity_provider.dart';
import 'package:tech_app/provider/stream_unread_provider.dart';
import 'package:tech_app/l10n/app_localizations.dart';
import 'package:tech_app/widgets/header.dart';
import 'package:tech_app/widgets/no_internet_widget.dart';

class ChatsView extends ConsumerStatefulWidget {
  const ChatsView({super.key});

  @override
  ConsumerState<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends ConsumerState<ChatsView> {
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: unused_result
      ref.refresh(fetchchatslistprovider);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatlist = ref.watch(fetchchatslistprovider);
    final unreadCounts = ref.watch(streamUnreadCountsProvider);
    final connectivity = ref.watch(connectivityProvider);

    // Primary color for the Tech app chat badges
    const badgeColor = Color.fromRGBO(13, 95, 72, 1);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: connectivity.when(
        data: (isOnline) {
          if (!isOnline) return const NoInternetScreen();

          return SafeArea(
            child: Column(
              children: [
                /// TOP BAR
                // Padding(
                // padding: const EdgeInsetsDirectional.only(
                //   start: 15,
                //   end: 15,
                //   top: 20,
                // ),
                Header(
                  title: AppLocalizations.of(context)!.chatsTitle,
                  showBackButton: false,
                  showNotificationIcon: false,
                  showRefreshIcon: false,
                  showProfileIcon: false,
                ),

                //),
                const Divider(),

                /// SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Builder(
                    builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      return Container(
                        height: 52,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),

                          color: isDark
                              ? const Color(0xFF1F1F1F)
                              : Colors.white,

                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey.shade300,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.18)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            const SizedBox(width: 15),

                            Icon(
                              Icons.search,
                              color: isDark ? Colors.white70 : Colors.grey,
                              size: 22,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: TextField(
                                controller: searchController,
                                showCursor: true,

                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),

                                cursorColor: AppColors.app_background_clr,

                                onChanged: (value) {
                                  setState(() => searchText = value);
                                },

                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.searchMessagesHint,

                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade500,
                                    fontSize: 14,
                                  ),

                                  border: InputBorder.none,

                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// CHAT LIST
                Expanded(
                  child: chatlist.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.errorWithDetail(err.toString()),
                      ),
                    ),
                    data: (chatModel) {
                      final chats = chatModel.data;

                      final filteredChats = chats.where((user) {
                        final name = user.name?.toLowerCase() ?? "";
                        return name.contains(searchText.toLowerCase());
                      }).toList();

                      if (filteredChats.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noChatsFound,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final user = filteredChats[index];

                          // StreamProvider — auto-updates on new messages
                          final unread = unreadCounts.value?[user.id] ?? 0;
                          final hasUnread = unread > 0;

                          return InkWell(
                            onTap: () {
                              context
                                  .push(
                                    "/chatDetails",
                                    extra: {"id": user.id, "name": user.name},
                                  )
                                  .then((_) {
                                    ref.invalidate(streamUnreadCountsProvider);
                                  });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: hasUnread
                                    ? badgeColor.withOpacity(0.04)
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withOpacity(0.12),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  /// AVATAR
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: badgeColor,
                                        child: Text(
                                          (user.name?.isNotEmpty ?? false)
                                              ? user.name![0].toUpperCase()
                                              : "?",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      /// Green dot when there are unread messages
                                      if (hasUnread)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(width: 14),

                                  /// NAME + LAST MESSAGE
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.name ?? "",
                                          style: TextStyle(
                                            fontWeight: hasUnread
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (user.lastMessage?.message != null &&
                                            user
                                                .lastMessage!
                                                .message!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            user.lastMessage!.message!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: hasUnread
                                                  ? Colors.black87
                                                  : Colors.grey,
                                              fontSize: 13,
                                              fontWeight: hasUnread
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  /// UNREAD COUNT BADGE
                                  if (hasUnread)
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 22,
                                        minHeight: 22,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: badgeColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          unread > 99 ? '99+' : '$unread',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const NoInternetScreen(),
      ),
    );
  }
}
