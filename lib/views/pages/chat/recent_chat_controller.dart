import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../model/chat_model.dart';
import '../../../model/message_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import 'messages/messages_page.dart';

class RecentChatController extends GetxController {
  static RecentChatController instance = Get.find();
  ScrollController recentScrollController = ScrollController();
  final isVisible = true.obs;


  @override
  void onInit() {
    super.onInit();
    recentScrollController.addListener(() {
      isVisible.value = recentScrollController.position.userScrollDirection ==
          ScrollDirection.forward;
    });
  }

  @override
  void onClose() {
    super.onClose();
    recentScrollController.dispose();
  }

  Stream<List<ChatConversation>> getChats() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseChatCollection)
        .where(
          'members',
          arrayContains: FirebaseAuth.instance.currentUser != null
              ? FirebaseAuth.instance.currentUser!.uid
              : '',
        )
        .orderBy('recent_time', descending: true)
        .snapshots()
        .asyncMap(
      (query) async {
        List<ChatConversation> chats = [];

        for (var chatData in query.docs) {
          // Get Users in chat
          List<WeBuzzUser> members = [];

          // iterate through all members uids
          for (var uid in chatData['members']) {
            // Get user's info using the iterated uid, in firestore
            DocumentSnapshot userSnapshot =
                await FirebaseService.getUserByID(uid);

            // Add them to the members list
            members.add(WeBuzzUser.fromDocument(userSnapshot));
          }

          // last message
          List<MessageModel> messages = [];
          QuerySnapshot chatMessages =
              await FirebaseService().getLastMessageForChat(chatData.id);
          if (chatMessages.docs.isNotEmpty) {
            messages.add(
                MessageModel.fromDocumentSnapshot(chatMessages.docs.first));
          }

          // chat instance
          chats.add(
            ChatConversation(
              uid: chatData.id,
              currentUserId: FirebaseAuth.instance.currentUser != null
                  ? FirebaseAuth.instance.currentUser!.uid
                  : '',
              group: chatData['is_group'],
              activity: chatData['is_activity'],
              members: members,
              createdAt: chatData['created_at'],
              messages: messages,
              groupTitle: chatData['group_title'],
              createdBy: chatData['created_by'],
              recentTime: Timestamp.now(),
            ),
          );
        }
        return chats;
      },
    );
  }

  Stream<List<Conversation>> getChat() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseChatCollection)
        .where(
          'members',
          arrayContains: FirebaseAuth.instance.currentUser != null
              ? FirebaseAuth.instance.currentUser!.uid
              : '',
        )
        .orderBy('recent_time', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((e) => Conversation.fromDocumentSnapshot(e))
            .toList());
  }

  void toMessagePage(Conversation chat, List<MessageModel> messages) {
    ChatConversation chatConversation = ChatConversation(
      uid: chat.uid,
      currentUserId: chat.currentUserId,
      createdBy: chat.createdBy,
      group: chat.isGroup,
      activity: chat.activity,
      members: chat.users,
      messages: messages,
      recentTime: chat.recentTime,
      createdAt: chat.createdAt,
      groupTitle: chat.groupTitle,
    );
    Get.to(
      () => MessagesPage(chat: chatConversation),
      transition: Transition.zoom,
      curve: Curves.linearToEaseOut,
    );
  }
}
