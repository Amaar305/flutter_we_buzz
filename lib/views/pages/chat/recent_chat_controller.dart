import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../model/chat_message_model.dart';
import '../../../model/chat_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';

class RecentChatController extends GetxController {
  static RecentChatController instance = Get.find();

  // FIXME: error when logout because user is null

  Stream<List<ChatConversation>> getChats() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseChatCollection)
        .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
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
            messages.add(MessageModel.fromDocumentSnapshot(chatMessages.docs.first));
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
}
