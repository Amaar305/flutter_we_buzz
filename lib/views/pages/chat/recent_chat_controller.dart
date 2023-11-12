import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/chat_message.dart';
import '../../../model/chat_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';

class RecentChatController extends GetxController {
  static RecentChatController instance = Get.find();

  RxList<ChatConversation> chatConversations = RxList<ChatConversation>([]);

  @override
  void onInit() {
    super.onInit();
    chatConversations.bindStream(_getChats());
  }

  Stream<List<ChatConversation>> _getChats() {
    log('streaming recent user chat!!!!!!!!!!!!!!!!!!!!!!!!!!');
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
          List<ChatMessage> messages = [];
          QuerySnapshot chatMessages =
              await FirebaseService().getLastMessageForChat(chatData.id);
          if (chatMessages.docs.isNotEmpty) {
            log('streaming recent user Message!!!!!!!!!!!!!!!!!!!!!!!!!!');

            messages.add(ChatMessage.fromDocument(chatMessages.docs.first));
          }

          // chat instance
          chats.add(
            ChatConversation(
              uid: chatData.id,
              currentUserId: FirebaseAuth.instance.currentUser!.uid,
              group: chatData['is_group'],
              activity: chatData['is_activity'],
              members: members,
              messages: messages,
              recentTime: Timestamp.now(),
              groupTitle: chatData['group_title']
            ),
          );
        }
        return chats;
      },
    );
  }
}
