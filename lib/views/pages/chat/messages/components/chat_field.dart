import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/we_buzz_user_model.dart';
import 'package:hi_tweet/views/pages/dashboard/my_app_controller.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../model/chat_model.dart';
import '../../../../../model/message_enum_type.dart';
import '../../../../../services/image_picker_services.dart';
import '../messages_controller.dart';

class ChatMessageField extends StatelessWidget {
  const ChatMessageField({
    super.key,
    required this.controller,
    required this.chat,
    required this.otherChatUser,
  });

  final MessageController controller;
  final ChatConversation chat;
  final WeBuzzUser otherChatUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * .01,
        horizontal: MediaQuery.of(context).size.width * .025,
      ),
      child: Row(
        children: [
          // input field and button
          Expanded(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: GetBuilder<MessageController>(
                builder: (_) {
                  return SizedBox(
                    height: controller.hasNewLine ? controller.size : null,
                    child: Row(
                      children: [
                        // emji button
                        IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            controller.updateEmoji();
                          },
                          icon: const Icon(Icons.emoji_emotions),
                        ),
                        Expanded(
                          child: TextField(
                            autocorrect: true,
                            // autovalidateMode: AutovalidateMode.onUserInteraction,
                            clipBehavior: Clip.antiAlias,
                            onTap: () {
                              if (controller.showEmoji) {
                                controller.updateEmoji();
                              }
                            },
                            onChanged: (value) =>
                                controller.onTextChanged(value, chat.uid),

                            controller: controller.messageEditingController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            maxLength: 700,

                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Type message...',
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        // pick images from gallery button
                        IconButton(
                          onPressed: () async {
                            try {
                              final ImagePicker picker = ImagePicker();

                              //  pick multiple images
                              final List<XFile> images =
                                  await picker.pickMultiImage(
                                // source: ImageSource.gallery,
                                imageQuality: 70,
                              );

                              // controller.gemine('What is in this picture?', file);
                              // uploading and sending images one by one
                              for (var i in images) {
                                controller.isUploadingImage(true);

                                await ImagePickerService()
                                    .croppedImage(i.path)
                                    .then((value) async {
                                  if (value == null) return;
                                  await controller.sendChatImage(
                                    chatID: chat.uid,
                                    file: File(value.path),
                                    members: chat.members,
                                    isGroup: chat.group,
                                  );
                                });

                                controller.isUploadingImage(false);
                              }
                            } catch (e) {
                              log("Error trying to pick an image");
                              log(e);
                            }
                          },
                          icon: const Icon(Icons.image),
                        ),

                        // take image from camera button
                        IconButton(
                          onPressed: () async {
                            try {
                              final image =
                                  await ImagePickerService().imagePicker(
                                source: ImageSource.camera,
                                cropAspectRatio: const CropAspectRatio(
                                    ratioX: 16, ratioY: 9),
                              );

                              if (image == null) return;

                              controller.isUploadingImage(true);

                              await controller.sendChatImage(
                                chatID: chat.uid,
                                file: File(image.path),
                                members: chat.members,
                                isGroup: chat.group,
                              );
                              controller.isUploadingImage(false);
                            } catch (e) {
                              log('Error trying to pick image');
                              log(e);
                            }
                          },
                          icon: const Icon(Icons.camera_alt_rounded),
                        ),

                        // Adding some space
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .02,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // send message
          MaterialButton(
            onPressed: () {
              if (controller.messageEditingController.text.isNotEmpty) {
                // simple send message
                controller.sendTextMessage(
                  chatID: chat.uid,
                  members: chat.members,
                  text: controller.messageEditingController.text.trim(),
                  type: MessageType.text,
                  isGroup: chat.group,
                  senderID: FirebaseAuth.instance.currentUser!.uid,
                );
              }
              controller.messageEditingController.text = '';
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

class ChatMessageFWithBotield extends StatelessWidget {
  const ChatMessageFWithBotield({
    super.key,
    required this.controller,
    required this.chat,
    required this.otherChatUser,
  });
  final MessageController controller;
  final ChatConversation chat;
  final WeBuzzUser otherChatUser;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * .01,
        horizontal: MediaQuery.of(context).size.width * .025,
      ),
      child: Row(
        children: [
          // input field and button
          Expanded(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: GetBuilder<MessageController>(builder: (_) {
                return SizedBox(
                  height: controller.hasNewLine ? controller.size : null,
                  child: Row(
                    children: [
                      // emji button
                      IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          controller.updateEmoji();
                        },
                        icon: const Icon(Icons.emoji_emotions),
                      ),
                      Expanded(
                        child: TextField(
                          onTap: () {
                            if (controller.showEmoji) {
                              controller.updateEmoji();
                            }
                          },
                          controller: controller.messageEditingController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          maxLength: 500,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Type message...',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      // pick image from gallery button

                      GetBuilder<AppController>(
                        builder: (control) {
                          if (!control.currentUser!.isVerified) {
                            return const SizedBox();
                          }
                          return IconButton(
                            onPressed: () async {
                              try {
                                final ImagePicker picker = ImagePicker();
                                final image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 70,
                                );

                                controller.setImagePath(image!.path);

                                controller.isUploadingImage(true);

                                await controller
                                    .sendChatImage(
                                      chatID: chat.uid,
                                      file: File(image.path),
                                      members: chat.members,
                                      isGroup: chat.group,
                                    )
                                    .whenComplete(() =>
                                        controller.isUploadingImage(false));
                              } catch (e) {
                                log("Error trying to pick an image");
                                log(e);
                              }
                            },
                            icon: const Icon(Icons.image),
                          );
                        },
                      ),

                      // Adding some space
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .02,
                      )
                    ],
                  ),
                );
              }),
            ),
          ),
          // send message
          MaterialButton(
            onPressed: () {
              if (controller.messageEditingController.text.isNotEmpty) {
                // simple send message
                if (controller.paths.isNotEmpty) {
                  // Send chatImage to gemini

                  controller.sendTextMessage(
                    chatID: chat.uid,
                    members: chat.members,
                    text: controller.messageEditingController.text.trim(),
                    type: MessageType.text,
                    isGroup: chat.group,
                    senderID: FirebaseAuth.instance.currentUser!.uid,
                    isBot: true,
                  );
                  1.delay();
                  controller.gemineTextAndImage(
                    chatID: chat.uid,
                    members: chat.members,
                    text: controller.messageEditingController.text.trim(),
                    type: MessageType.text,
                    path: controller.paths,
                    senderID: otherChatUser.userId,
                    otherChatUser: otherChatUser,
                  );
                } else {
                  // Send text message to gemini
                  controller.sendTextMessage(
                    chatID: chat.uid,
                    members: chat.members,
                    text: controller.messageEditingController.text.trim(),
                    type: MessageType.text,
                    isGroup: false,
                    senderID: FirebaseAuth.instance.currentUser!.uid,
                    isBot: true,
                  );
                  2.delay();
                  controller.gemineText(
                    chatID: chat.uid,
                    members: chat.members,
                    text: controller.messageEditingController.text.trim(),
                    type: MessageType.text,
                    otherChatUser: otherChatUser,
                    senderID: otherChatUser.userId,
                  );
                }
              }
              controller.messageEditingController.text = '';
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
