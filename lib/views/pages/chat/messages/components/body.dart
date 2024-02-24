import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../model/message_model.dart';
import '../../../../../model/chat_model.dart';
import '../../../../../model/we_buzz_user_model.dart';
import '../../../../utils/constants.dart';
import '../../../dashboard/my_app_controller.dart';
import '../../add_users_page/add_users_controller.dart';
import '../messages_controller.dart';
import 'chat_field.dart';
import 'message_widget.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.chat,
    required this.otherChatUser,
    required this.controller,
  });
  final ChatConversation chat;
  final WeBuzzUser otherChatUser;
  final MessageController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: StreamBuilder<List<MessageModel>>(
              stream: controller.streamChatMessagesForAChat(chat.uid),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  // if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const SizedBox();

                  // if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    controller.addMessages(snapshot.data!);

                    if (snapshot.data != null) {
                      if (controller.messages.isNotEmpty) {
                        return ListView.builder(
                          reverse: true,
                          shrinkWrap: false,
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            var message = controller.messages[index];
                            return Message(
                              message: message,
                              chatID: chat.uid,
                              user: chat.members.firstWhere(
                                  (user) => user.userId == message.senderID),
                              isGroup: chat.group,
                              conversation: chat,
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'Say Hii👋🏼',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: Text(
                          'Say Hii👋🏼',
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }
                }
              },
            ),
          ),
        ),

        // show this when uploading images
        GetBuilder<MessageController>(
          builder: (controller) {
            if (controller.isUploading) {
              return const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),

        // blocking conditions
        GetX<AppController>(
          builder: (control) {
            var currentUserBlockedCondition = control.weBuzzUsers
                .firstWhere((user) =>
                    user.userId == FirebaseAuth.instance.currentUser!.uid)
                .blockedUsers
                .contains(otherChatUser.userId);

            var targetUserBlockedCondition = control.weBuzzUsers
                .firstWhere((user) => user.userId == otherChatUser.userId)
                .blockedUsers
                .contains(FirebaseAuth.instance.currentUser!.uid);

            if (currentUserBlockedCondition && !chat.group) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * .01,
                  horizontal: MediaQuery.of(context).size.width * .025,
                ),
                child: TextButton(
                  onPressed: () {
                    AddUsersController.instance.showDiaologForBlockingUser(
                      otherChatUser,
                    );
                  },
                  child: const Text(
                    'You blocked this user, tap to unbloeck',
                  ),
                ),
              );
            } else if (targetUserBlockedCondition && !chat.group) {
              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * .01,
                  horizontal: MediaQuery.of(context).size.width * .055,
                ),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.19),
                ),
                child: const Text(
                  'This user blocked you, to keep We Buzz safe for everyone, you can\'t DM them!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            } else {
              return otherChatUser.bot
                  ? ChatMessageFWithBotield(
                      controller: controller,
                      chat: chat,
                      otherChatUser: otherChatUser,
                    )
                  : ChatMessageField(
                      controller: controller,
                      chat: chat,
                      otherChatUser: otherChatUser,
                    );
            }
          },
        ),

        // show this when using emojis
        GetBuilder<MessageController>(
          init: controller,
          builder: (controller) {
            return controller.showEmoji
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * .35,
                    child: EmojiPicker(
                      textEditingController:
                          controller.messageEditingController,
                      config: Config(
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.20 : 1.0),
                        bgColor: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  )
                : const SizedBox();
          },
        )
      ],
    );
  }
}
