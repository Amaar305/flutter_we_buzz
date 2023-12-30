import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../model/chat_message_model.dart';
import '../../../../../model/message_enum_type.dart';

// constants
import '../../../../../model/we_buzz_user_model.dart';
import '../../../../utils/constants.dart';

// Widgets
import '../../../../utils/custom_snackbar.dart';
import '../../../../utils/my_date_utils.dart';
import '../../../../widgets/bottom_sheet_option.dart';
import '../messages_controller.dart';
import 'audio_message.dart';
import 'image_message.dart';
import 'message_status_dot.dart';
import 'text_message.dart';

class Message extends StatelessWidget {
  const Message({
    super.key,
    required this.message,
    required this.chatID,
    required this.user,
    required this.isGroup,
  });
  final MessageModel message;
  final String chatID;
  final WeBuzzUser user;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    // check if is my message by comparing my userId with the reciever's id
    bool isMe = FirebaseAuth.instance.currentUser!.uid == message.senderID;

// update last read message if sender and the reciever are diffent
    if (message.status == MessageStatus.notView && !isMe) {
      MessageController.instance.updateChatMessageRead(chatID, message.docID);
      // TODO:update message read for group but make sure every member view the chat
    }
    Widget messageContaint(MessageModel message) {
      switch (message.type) {
        case MessageType.text:
          return TextMessage(
            message: message,
            isMe: isMe,
          );
        case MessageType.audio:
          return AudioMessage(
            message: message,
            isMe: isMe,
          );
        case MessageType.image:
          return ImageMessage(message: message);

        default:
          return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: CachedNetworkImageProvider(
                user.imageUrl ?? defaultProfileImage,
              ),
            ),
            const SizedBox(width: kDefaultPadding / 2),
          ],
          InkWell(
            borderRadius: message.type == MessageType.text
                ? BorderRadius.circular(30)
                : null,
            onLongPress: () => _showBottomSheet(isMe, context),
            child: messageContaint(message),
          ),
          if (isMe && !isGroup) MessageStatusDot(status: message.status)
        ],
      ),
    );
  }

// Bottom sheet for modifyinng message details
  void _showBottomSheet(bool isMe, BuildContext context) {
    Size size = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            // black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: size.height * .015,
                horizontal: size.width * .4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            if (message.type == MessageType.text)
              // copy option
              OptionItem(
                icon: Icon(
                  Icons.copy_all_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                ),
                name: 'Copy Text',
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: message.content))
                      .then(
                    (value) {
                      Get.back();
                      CustomSnackBar.showSnackbar('Message Copied');
                    },
                  );
                },
              )
            else
              // save option
              OptionItem(
                icon: Icon(
                  Icons.downloading,
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                ),
                name: 'Save Image',
                onTap: () async {
                  // try {
                  //   log(message.msg);
                  //   await GallerySaver.saveImage(widget.message.msg,
                  //           albumName: "Campus Connect")
                  //       .then((success) {
                  //     Navigator.pop(context);

                  //     // if (success != null && success) {
                  //     //   Dialogs.showSnackbar(
                  //     //       context, "Image Successifully Saved");
                  //     // }
                  //   });
                  // } catch (e) {
                  //   log("Error While Saving Image $e");
                  // }
                },
              ),

            // sepeartor or divider
            if (isMe)
              Divider(
                endIndent: size.width * .04,
                indent: size.width * .04,
              ),

            // edit option
            if (message.type == MessageType.text &&
                isMe &&
                message.senderID == FirebaseAuth.instance.currentUser!.uid)
              OptionItem(
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                ),
                name: 'Edit Message',
                onTap: () {
                  // for hiding bottomSheet
                  Get.back();

                  _showMessgaUpdateDialog(context);
                },
              ),

            // delete option
            if (isMe)
              OptionItem(
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 26,
                ),
                name: 'Delete Message',
                onTap: () async {
                  MessageController.instance.deleteChatMessage(message, chatID);
                  Get.back();
                },
              ),

            // sepeartor or divider
            Divider(
              endIndent: size.width * .04,
              indent: size.width * .04,
            ),

            // sent time
            OptionItem(
              icon: Icon(
                Icons.remove_red_eye,
                color: Theme.of(context).colorScheme.primary,
              ),
              name: 'Sent At ${MyDateUtil.getMessageTime(
                time: message.sentTime.millisecondsSinceEpoch.toString(),
                context: context,
              )}',
              onTap: () {},
            ),

            // recieve time
            OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.deepOrange,
              ),
              name: message.status == MessageStatus.notView
                  ? 'Read At: Not seen yet!'
                  : 'Read At ${MyDateUtil.getMessageTime(time: message.read, context: context)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void _showMessgaUpdateDialog(BuildContext context) {
    String updatedMsg = message.content;

    Get.dialog(
      WillPopScope(
        child: AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.message,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Text('Update Message'),
            ],
          ),
          content: TextFormField(
            initialValue: updatedMsg,
            maxLines: null,
            onChanged: (value) => updatedMsg = value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Cancle',
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            MaterialButton(
              onPressed: () {
                if (message.senderID ==
                    FirebaseAuth.instance.currentUser!.uid) {
                  MessageController.instance
                      .updateMessage(message.docID, chatID, updatedMsg);
                  Get.back();
                }
              },
              child: Text(
                'Send',
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      barrierColor: kPrimary.withOpacity(0.03),
      useSafeArea: true,
    );
  }
}
