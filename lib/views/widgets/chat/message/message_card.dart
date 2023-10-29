import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/message_enum_type.dart';
import 'package:hi_tweet/model/user.dart';
import 'package:hi_tweet/views/pages/chat/chat_controller.dart';
import 'package:hi_tweet/views/pages/dashboard/dashboard_controller.dart';
import 'package:hi_tweet/views/utils/method_utils.dart';

import '../../../../model/message_model.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message, required this.user});
  final Message message;
  final WeBuzzUser user;

  @override
  Widget build(BuildContext context) {
    return AppController.instance.auth.currentUser!.uid == message.fromId
        ? _yelloMessage()
        : _whiteMessage();
  }

  // our message
  Widget _yelloMessage() {
    Size size = MediaQuery.of(Get.context!).size;
    return Padding(
      padding: EdgeInsets.only(left: size.width * .08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(
              message.type == MessageType.image
                  ? size.width * .01
                  : size.width * .04,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: size.width * .04,
              vertical: size.height * .01,
            ),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(2),
              ),
            ),
            child: message.type == MessageType.text
                ? Text(
                    message.message,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : FullScreenWidget(
                    disposeLevel: DisposeLevel.Medium,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: message.message,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                  ),
            // 'I know, right? She\'s grown so much as a leader and singer!'
          ),

          // for showing  time sent
          Padding(
            padding: EdgeInsets.only(right: size.width * .01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // time sent
                Text(
                  MethodUtils.getFormattedDate(time: message.sent),
                  style: const TextStyle(fontSize: 13),
                ),

                // for adding  some extra spcace
                SizedBox(width: size.width * .01),

                // for showing  not read
                if (message.read.isEmpty && user.isOnline)
                  Icon(
                    Icons.circle_outlined,
                    size: size.width * .044,
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),

                // for showing  read message
                if (message.read.isNotEmpty)
                  CircleAvatar(
                    radius: size.width * .018,
                    child: FittedBox(
                      child: Icon(
                        Icons.done_all,
                        size: size.width * .03,
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  // sender or another user message
  Widget _whiteMessage() {
    // update last read message if sender and the reciever are diffent
    if (message.read.isEmpty) {
      ChatController().updateMessageReadStatus(message);
    }
    Size size = MediaQuery.of(Get.context!).size;
    return Padding(
      padding: EdgeInsets.only(right: size.width * .08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(
              message.type == MessageType.image
                  ? size.width * .01
                  : size.width * .04,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: size.width * .04,
              vertical: size.height * .01,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
                bottomLeft: Radius.circular(2),
              ),
            ),
            child: message.type == MessageType.text
                ? Text(
                    message.message,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : FullScreenWidget(
                    disposeLevel: DisposeLevel.Medium,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: message.message,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          // for showing  time sent
          Padding(
            padding: EdgeInsets.only(left: size.width * .04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // time sent
                Text(
                  MethodUtils.getFormattedDate(time: message.sent),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
// 'I know, right? She\'s grown so much as a leader and singer!'