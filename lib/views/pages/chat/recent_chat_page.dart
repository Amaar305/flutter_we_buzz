import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../model/chat_model.dart';
import '../../../model/message_enum_type.dart';
import '../../../model/message_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../widgets/chat/custom_list_view.dart';
import '../dashboard/my_app_controller.dart';
import 'add_users_page/add_users_page.dart';
import 'add_users_page/components/user_online_condition.dart';
import 'components/no_chat_page.dart';
import 'components/trailing_chat_widget.dart';
import 'messages/messages_page.dart';
import 'recent_chat_controller.dart';

class RecentChatPage extends GetView<RecentChatController> {
  const RecentChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: GoogleFonts.pacifico(
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AddUsersPage.routeName),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: kPadding,
        child: _chatList(),
      ),
    );
  }

  Widget _chatList() {
    List<ChatConversation>? chatConversations;
    return StreamBuilder<List<ChatConversation>>(
      stream: controller.getChats(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          // if conversation is loading
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Center(
              child: CircularProgressIndicator(),
            );

          // if some or all data is loaded then show it
          case ConnectionState.active:
          case ConnectionState.done:
            chatConversations = snapshot.data!;

            if (chatConversations != null) {
              if (chatConversations!.isNotEmpty) {
                return ListView.builder(
                  itemCount: chatConversations!.length,
                  itemBuilder: (context, index) => _chatTile(
                    chatConversations![index],
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    'No chat found!',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                );
              }
            } else {
              return const Center(
                child: Text('NULL'),
              );
            }
        }
      },
    );
  }

  Widget _chatTile(
    ChatConversation chatConversation,
  ) {
    List<WeBuzzUser> recepients = chatConversation.recipients;
    String subtitleText = '';
    bool isOnline = recepients.any((d) => d.isOnline);

    String? messageDoc;

    if (chatConversation.members.isNotEmpty) {
      if (chatConversation.messages.isNotEmpty) {
        messageDoc = chatConversation.messages.first.docID;
      }
      subtitleText = chatConversation.messages.isNotEmpty
          ? chatConversation.messages.first.type != MessageType.text
              ? 'Media Attachment'
              : chatConversation.messages.first.content.length > 25
                  ? '${chatConversation.messages.first.content.substring(0, 25)}...'
                  : chatConversation.messages.first.content
          : 'New chat';
    }
    return Builder(
      builder: (context) {
        final deviceHeight = MediaQuery.sizeOf(context).height;

        return CustomListViewTileWithActivity(
          onlineStatus: shouldDisplayOnlineStatus(
            recepients.firstWhere((user) =>
                user.userId != FirebaseAuth.instance.currentUser!.uid),
          ),
          height: deviceHeight * 0.10,
          title: chatConversation.title(),
          subtitle: subtitleText,
          imageUrl: chatConversation.imageUrl(),
          isOnline: isOnline,
          isActivity: chatConversation.activity,
          onTap: () {
            Get.to(
              () => MessagesPage(chat: chatConversation),
              transition: Transition.zoom,
              curve: Curves.linearToEaseOut,
            );
          },
          sentime: chatConversation.uid,
          messageDoc: messageDoc,
        );
      },
    );
  }
}

class NewRecentChat extends GetView<RecentChatController> {
  const NewRecentChat({super.key});

  @override
  Widget build(BuildContext context) {
    List<Conversation>? conversation;
    MessageModel? message;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: GoogleFonts.pacifico(
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AddUsersPage.routeName),
            icon: const Icon(Icons.person_add_outlined),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 0.03,
        ),
        child: StreamBuilder<List<Conversation>>(
          stream: controller.getChat(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              // if data is loading
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );

              // if some or all data is loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
                conversation = snapshot.data;

                if (conversation != null) {
                  if (conversation!.isNotEmpty) {
                    return ListView.builder(
                      controller: controller.recentScrollController,
                      itemCount: conversation!.length,
                      itemBuilder: (context, index) {
                        final chat = conversation![index];

                        List<WeBuzzUser> members = [];

                        for (var userId in chat.members) {
                          var filteredUser = AppController.instance.weBuzzUsers
                              .firstWhere((user) => user.userId == userId);
                              
                          members.add(filteredUser);
                        }

                        final otherUser = members.firstWhere((user) =>
                            user.userId !=
                            FirebaseAuth.instance.currentUser!.uid);

                        return StreamBuilder(
                          stream: FirebaseService()
                              .streamLastMessageForChat(chat.uid),
                          builder: (context, snap) {
                            final data = snap.data?.docs;
                            final list = data
                                    ?.map((e) =>
                                        MessageModel.fromDocumentSnapshot(e))
                                    .toList() ??
                                [];

                            if (list.isNotEmpty) message = list.first;
                            bool isOnline = members.any((d) => d.isOnline);
                            return CustomChatTileWithActivity(
                              isOnline: chat.isGroup
                                  ? isOnline
                                  : shouldDisplayOnlineStatus(otherUser),
                              user: otherUser,
                              chat: chat,
                              height: MediaQuery.sizeOf(context).height * 0.10,
                              isActivity: chat.activity,
                              lastMessage: message != null
                                  ? message!.type != MessageType.text
                                      ? 'Media Attachement'
                                      : message!.content
                                  : 'New chat',
                              title: chat.title(),
                              imageUrl: chat.imageUrl(otherUser),
                              trailing: TrailingChat(
                                message: message,
                              ),
                              onTap: () => controller.toMessagePage(chat, list),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return const NoChatPage();
                  }
                } else {
                  return const SizedBox();
                }
            }
          },
        ),
      ),
    );
  }
}
