import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../model/chat_model.dart';
import '../../../../utils/method_utils.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.groupChat,
  });

  final ChatConversation groupChat;

  @override
  Widget build(BuildContext context) {
     // Converting the created timestamp to date string
    final time = MethodUtils.getLastMessageTime(
      time: groupChat.createdAt.millisecondsSinceEpoch.toString(),
      showYear: true,
    );
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.height * 0.09,
            backgroundImage: CachedNetworkImageProvider(
              groupChat.imageUrl(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            groupChat.title(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Created on: $time",
            textAlign: TextAlign.justify,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
