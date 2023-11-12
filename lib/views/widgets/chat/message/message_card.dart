import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';

import '../../../../model/chat_message.dart';
import '../../../../model/message_enum_type.dart';
import '../../../../model/we_buzz_user_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/custom_snackbar.dart';
import '../../../utils/method_utils.dart';
import '../../../utils/my_date_utils.dart';
import '../../bottom_sheet_option.dart';

class MessagesCard extends StatelessWidget {
  const MessagesCard({super.key, required this.message, required this.user});
  final ChatMessage message;
  final WeBuzzUser user;

  @override
  Widget build(BuildContext context) {
    // check if is my message by comparing my userId with the reciever's id
    bool isMe = FirebaseAuth.instance.currentUser!.uid == message.senderID;

    return InkWell(
      child: isMe ? _yelloMessage() : _whiteMessage(),
      onLongPress: () => _showBottomSheet(isMe),
    );
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
                    message.content,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : FullScreenWidget(
                    disposeLevel: DisposeLevel.Medium,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: message.content,
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
                  MethodUtils.getFormattedDate(
                      time: message.sentTime.millisecondsSinceEpoch.toString()),
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
    // TODO implement read message
    // if (message.read.isEmpty) {
    //   ChatControllerOld.instance.updateMessageReadStatus(message);
    // }
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
                    message.content,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : FullScreenWidget(
                    disposeLevel: DisposeLevel.Medium,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: message.content,
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
                  MethodUtils.getFormattedDate(
                      time: message.sentTime.millisecondsSinceEpoch.toString()),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

// Bottom sheet for modifyinng message details
  void _showBottomSheet(bool isMe) {
    Size size = MediaQuery.of(Get.context!).size;

    showModalBottomSheet(
      context: Get.context!,
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
                  color: Theme.of(Get.context!).colorScheme.primary,
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
                  color: Theme.of(Get.context!).colorScheme.primary,
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
            if (message.type == MessageType.text && isMe)
              OptionItem(
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(Get.context!).colorScheme.primary,
                  size: 26,
                ),
                name: 'Edit Message',
                onTap: () {
                  // for hiding bottomSheet
                  Get.back();

                  _showMessgaUpdateDialog();
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
                  // TODO implement dele message
                  // await ChatPageController.instance
                  //     .deleteChat()
                  //     .then((value) {
                  //   // for hiding bottomSheet
                  //   Get.back();
                  // });
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
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
              name: 'Sent At ${MyDateUtil.getMessageTime(
                time: message.sentTime.millisecondsSinceEpoch.toString(),
              )}',
              onTap: () {},
            ),

            // recieve time
            OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.deepOrange,
              ),
              name: message.read.isEmpty
                  ? 'Read At: Not seen yet!'
                  : 'Read At ${MyDateUtil.getMessageTime(time: message.read)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void _showMessgaUpdateDialog() {
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
                color: Theme.of(Get.context!).colorScheme.primary,
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
                    fontSize: 16,
                    color: Theme.of(Get.context!).colorScheme.primary),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                // TODO IMPLEMENT UPDATE MESSAGE
                // Get.back();
                // await ChatControllerOld.instance
                //     .updateMessage(message, updatedMsg);
              },
              child: Text(
                'Send',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(Get.context!).colorScheme.primary),
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
