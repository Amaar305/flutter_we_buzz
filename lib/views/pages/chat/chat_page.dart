import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/chat_message.dart';
import '../../../model/chat_model.dart';
import '../../../model/message_enum_type.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../utils/constants.dart';
import '../../utils/my_date_utils.dart';
import '../../widgets/chat/message/message_card.dart';
import '../view_profile/view_profile_page.dart';
import 'add_users_page/add_users_page.dart';
import 'chat_page_controller.dart';

class ChatPage extends StatefulWidget {
  final ChatConversation chat;
  const ChatPage({super.key, required this.chat});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Size size;

  final controller = ChatPageController.instance;
  late WeBuzzUser currentChatUser;

  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    currentChatUser = widget.chat.members.firstWhere(
      (user) => user.userId != FirebaseAuth.instance.currentUser!.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return _buildUI();
  }

  Widget _buildUI() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if emojis are showing and back button is pressed then hide emojis
          // or else simple close the current page on back button
          onWillPop: () {
            if (controller.showEmoji) {
              controller.updateEmoji();
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            body: Column(
              children: [
                _messageListView(),

                // show this when uploading images
                GetBuilder<ChatPageController>(
                  builder: (_) {
                    return controller.isUploading
                        ? const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const SizedBox();
                  },
                ),
                _chtInput(),
                // if (controller.showEmoji)
                GetBuilder<ChatPageController>(
                  builder: (_) {
                    return controller.showEmoji
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * .35,
                            child: EmojiPicker(
                              textEditingController:
                                  controller.messageEditingController,
                              config: Config(
                                  columns: 8,
                                  emojiSizeMax:
                                      32 * (Platform.isIOS ? 1.20 : 1.0),
                                  bgColor:
                                      Theme.of(context).colorScheme.background
                                  // bgColor: MediaQuery.of(context).platformBrightness ==
                                  //         Brightness.dark
                                  //     ? kScaffoldDarkBackgroundColour
                                  //     : kScaffoldLigthBackgroundColour,
                                  ),
                            ),
                          )
                        : const SizedBox();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _messageListView() {
    return Expanded(
      child: StreamBuilder<List<ChatMessage>>(
        stream: controller.streamChatMessagesForAChat(widget.chat.uid),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const SizedBox();

            // if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              _messages = snapshot.data!;

              if (snapshot.data != null) {
                if (_messages.isNotEmpty) {
                  return ListView.builder(
                    itemCount: _messages.length,
                    shrinkWrap: false,
                    itemBuilder: (context, index) => MessagesCard(
                      message: _messages[index],
                      user: widget.chat.members.firstWhere(
                        (user) =>
                            user.userId !=
                            FirebaseAuth.instance.currentUser!.uid,
                      ),
                    ),
                    reverse: true,
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

      // ),
    );
  }

  Widget _appBar() {
    if (widget.chat.group) {
      return InkWell(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(size.height * .03),
              child: CachedNetworkImage(
                width: size.height * .05,
                height: size.height * .05,
                fit: BoxFit.fill,
                imageUrl: widget.chat.imageUrl(),
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.title(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,

                    // color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 13),
                )
              ],
            ),
          ],
        ),
      );
    } else {
      return InkWell(
        onTap: () => Get.to(
          () => ViewProfilePage(
            weBuzzUser: widget.chat.members.firstWhere(
              (user) => user.userId != FirebaseAuth.instance.currentUser!.uid,
            ),
          ),
          transition: Transition.rightToLeftWithFade,
          curve: Curves.easeIn,
        ),
        child: StreamBuilder<WeBuzzUser>(
          stream: controller.getUserInfo(
            widget.chat.members.firstWhere(
              (user) => user.userId != FirebaseAuth.instance.currentUser!.uid,
            ),
          ),
          builder: (context, snapshot) {
            final data = snapshot.data;
            // final list = data
            //         ?.map((msg) => WeBuzzUser.fromJson(jsonEncode(msg.data())))
            //         .toList() ??
            //     [];

            // log(DateTime.now().millisecondsSinceEpoch.toString());
            return Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(size.height * .03),
                  child: CachedNetworkImage(
                    width: size.height * .05,
                    height: size.height * .05,
                    fit: BoxFit.fill,
                    imageUrl: data != null
                        ? data.imageUrl != null
                            ? data.imageUrl!
                            : defaultProfileImage
                        : widget.chat.members
                                    .firstWhere(
                                      (user) =>
                                          user.userId !=
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                    )
                                    .imageUrl !=
                                null
                            ? widget.chat.members
                                .firstWhere(
                                  (user) =>
                                      user.userId !=
                                      FirebaseAuth.instance.currentUser!.uid,
                                )
                                .imageUrl!
                            : defaultProfileImage,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data != null
                          ? data.name
                          : widget.chat.members
                              .firstWhere(
                                (user) =>
                                    user.userId !=
                                    FirebaseAuth.instance.currentUser!.uid,
                              )
                              .name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        // color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data != null
                          ? shouldDisplayOnlineStatus(data)
                              ? 'Online'
                              : MyDateUtil.getLastMessageTime(
                                  time: data.lastActive,
                                  showYear: true,
                                )
                          : MyDateUtil.getLastMessageTime(
                              time: widget.chat.members
                                  .firstWhere(
                                    (user) =>
                                        user.userId !=
                                        FirebaseAuth.instance.currentUser!.uid,
                                  )
                                  .lastActive,
                              showYear: true,
                            ),
                      style: const TextStyle(fontSize: 13),
                    )
                  ],
                )
              ],
            );
          },
        ),
      );
    }
  }

  Widget _chtInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height * .01,
        horizontal: size.width * .025,
      ),
      child: Row(
        children: [
          // input field and button
          Expanded(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  // emji button
                  IconButton(
                    onPressed: () {
                      FocusScope.of(Get.context!).unfocus();
                      controller.updateEmoji();
                    },
                    icon: const Icon(Icons.emoji_emotions),
                  ),
                  Expanded(
                    child: TextFormField(
                      onTap: () {
                        if (controller.showEmoji) {
                          controller.updateEmoji();
                        }
                      },
                      controller: controller.messageEditingController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // pick image from gallery button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      //  pick multiple images
                      final List<XFile> images = await picker.pickMultiImage(
                        // source: ImageSource.gallery,
                        imageQuality: 70,
                      );

                      // uploading and sending images one by one
                      for (var i in images) {
                        log("Image Path: ${i.path}");
                        controller.isUploadingImage(true);

                        await controller.sendChatImage(
                          currentChatUser,
                          File(i.path),
                          widget.chat.uid,
                        );
                        controller.isUploadingImage(false);
                      }
                    },
                    icon: const Icon(Icons.image),
                  ),

                  // take image from camera button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // pick an image
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 50,
                      );
                      if (image != null) {
                        log("Image Path: ${image.path}");
                        controller.isUploadingImage(true);
                        await controller.sendChatImage(
                          currentChatUser,
                          File(image.path),
                          widget.chat.uid,
                        );
                        controller.isUploadingImage(false);
                      }
                    },
                    icon: const Icon(Icons.camera_alt_rounded),
                  ),

                  // Adding some space
                  SizedBox(
                    width: size.width * .02,
                  )
                ],
              ),
            ),
          ),
          // send message
          MaterialButton(
            onPressed: () {
              if (controller.messageEditingController!.text.isNotEmpty) {
                // simple send message
                controller.sendTextMessage(widget.chat.uid, MessageType.text);
              }
              controller.messageEditingController!.text = '';
            },
            shape: const CircleBorder(),
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
            minWidth: 0,
            child: const Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
