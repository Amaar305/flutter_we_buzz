import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/chat/add_users_page/add_users_controller.dart';

import '../../../../model/chat_model.dart';
import '../../../widgets/chat/chatmessage/group_chat_appbar.dart';
import '../../../widgets/chat/chatmessage/private_chat_appbar.dart';

import 'components/body.dart';

import 'messages_controller.dart';

class MessagesPage extends GetView<MessageController> {
  const MessagesPage({super.key, required this.chat});
  final ChatConversation chat;

  @override
  Widget build(BuildContext context) {
    // Other chat member, but not for a group chat
    var otherChatUser = chat.members.firstWhere(
      (user) => user.userId != FirebaseAuth.instance.currentUser!.uid,
    );

    // initiating the member
    controller.initiateOtherChatUser(otherChatUser);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if emojis are showing and back button is pressed then hide emojis
          // or else simple close the current page on back button
          onWillPop: () {
            if (controller.showEmoji) {
              controller.updateEmoji();
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: chat.group
                  ? GroupChatAppBar(chat: chat)
                  : PrivateChatAppBar(controller: controller, chatID: chat.uid),
              actions: [
                DropdownButton(
                  icon: const Icon(Icons.more_vert),
                  underline: Container(),
                  items: [
                    const DropdownMenuItem(
                      value: 'report',
                      child: Text('Report'),
                    ),
                    if (!chat.group) ...[
                      const DropdownMenuItem(
                        value: 'block',
                        child: Text('Block'),
                      ),
                      const DropdownMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    if (chat.group)
                      DropdownMenuItem(
                        value: 'exit',
                        child: Text(
                          chat.createdBy ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? 'Delete group'
                              : 'Exit chat',
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    if (value == 'report') {
                      // Report  chat
                      controller.reportChat(
                        chatID: chat.uid,
                        messages: controller.messages,
                        isGroup: chat.group,
                        userID: FirebaseAuth.instance.currentUser != null
                            ? FirebaseAuth.instance.currentUser!.uid
                            : null,
                        otherUser: otherChatUser,
                      );
                    } else if (value == 'delete' && !chat.group) {
                      // Delete chat
                      controller.showChatDeletionDialog(
                        messages: controller.messages,
                        chatID: chat.uid,
                        userID: FirebaseAuth.instance.currentUser != null
                            ? FirebaseAuth.instance.currentUser!.uid
                            : null,
                      );
                    } else if (value == 'block') {
                      // Block user
                      AddUsersController.instance.blockedUsers(otherChatUser);
                    } else if (value == 'exit' && chat.group) {
                      controller.showGroupChatDeletionDialog(
                        chatID: chat.uid,
                        userID: FirebaseAuth.instance.currentUser != null
                            ? FirebaseAuth.instance.currentUser!.uid
                            : null,
                        admin: chat.createdBy ==
                            FirebaseAuth.instance.currentUser!.uid,
                      );
                      // Exit group
                    }
                  },
                ),
                // IconButton(
                //   onPressed: () {
                //     controller.showChatDeletionDialog(
                //       chat.uid,
                //       chat.createdBy == FirebaseAuth.instance.currentUser!.uid,
                //       controller.messages,
                //       isGroup: chat.group,
                //       userID: FirebaseAuth.instance.currentUser!.uid,
                //     );
                //   },
                //   icon: const Icon(Icons.delete),
                // )
              ],
            ),
            body: Body(
              chat: chat,
              otherChatUser: controller.otherChatUser,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}
