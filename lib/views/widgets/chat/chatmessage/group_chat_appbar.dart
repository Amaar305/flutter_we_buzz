import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../model/chat_model.dart';
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
              const Text(
                'Group',
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
        ],
      ),
    );
  }
}
