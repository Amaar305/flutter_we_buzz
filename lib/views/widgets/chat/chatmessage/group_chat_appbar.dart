import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../model/chat_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../../pages/chat/group_chat_info/group_chat_info.dart';

class GroupChatAppBar extends StatelessWidget {
  const GroupChatAppBar({
    super.key,
    required this.chat,
  });

  final ChatConversation chat;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {
        Get.to(
          () => GroupChatInfo(groupChat: chat),
        );
      },
      child: Row(
        children: [
          // Arrow back
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
          ),

          // Chat avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(size.height * .03),
            child: CachedNetworkImage(
              width: size.height * .05,
              height: size.height * .05,
              fit: BoxFit.fill,
              imageUrl: chat.imageUrl(),
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Group title
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.title(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,

                  // color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              StreamBuilder<ChatConversation>(
                stream: FirebaseService.firebaseFirestore
                    .collection(firebaseChatCollection)
                    .doc(chat.uid)
                    .snapshots()
                    .map(
                  (chatData) {
                    return ChatConversation(
                      uid: chatData.id,
                      currentUserId: FirebaseAuth.instance.currentUser != null
                          ? FirebaseAuth.instance.currentUser!.uid
                          : '',
                      group: chatData['is_group'],
                      activity: chatData['is_activity'],
                      members: [],
                      createdAt: chatData['created_at'],
                      messages: [],
                      groupTitle: chatData['group_title'],
                      createdBy: chatData['created_by'],
                      recentTime: Timestamp.now(),
                    );
                  },
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.hasError ||
                      snapshot.data == null) {
                    return const Text(
                      'Group',
                      style: TextStyle(fontSize: 13),
                    );
                  }
                  if (snapshot.data!.activity) {
                    return const Text(
                      'typing...',
                      style:
                          TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                    );
                  } else {
                    return const Text(
                      'Group',
                      style: TextStyle(fontSize: 13),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
