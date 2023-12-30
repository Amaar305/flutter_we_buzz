import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/chat_model.dart';
import '../../../model/message_enum_type.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../widgets/chat/custom_list_view.dart';
import '../../widgets/custom_app_bar.dart';
import 'add_users_page/add_users_page.dart';
import 'add_users_page/components/user_online_condition.dart';
import 'messages/messages_page.dart';
import 'recent_chat_controller.dart';

late double _deviceHeight;
late double _deviceWidth;

class RecentChatPage extends GetView<RecentChatController> {
  const RecentChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI();
  }

  Widget _buildUI() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.03,
        vertical: _deviceHeight * 0.02,
      ),
      height: _deviceHeight * 0.90,
      width: _deviceWidth * 0.97,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomAppBar(
            'Chats',
            primaryAction: IconButton(
              onPressed: () => Get.toNamed(AddUsersPage.routeName),
              icon: const Icon(Icons.add),
            ),
          ),
          _chatList(),
        ],
      ),
    );
  }

  Widget _chatList() {
    List<ChatConversation>? chatConversations;
    return Expanded(
      child: StreamBuilder<List<ChatConversation>>(
        stream: controller.getChats(),
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
      ),
    );
  }

  Widget _chatTile(ChatConversation chatConversation) {
    List<WeBuzzUser> recepients = chatConversation.recepeints();
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
    return CustomListViewTileWithActivity(
      onlineStatus: shouldDisplayOnlineStatus(
        recepients.firstWhere(
            (user) => user.userId != FirebaseAuth.instance.currentUser!.uid),
      ),
      height: _deviceHeight * 0.10,
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
  }
}
