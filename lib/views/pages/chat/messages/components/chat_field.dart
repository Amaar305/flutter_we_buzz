import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../model/chat_model.dart';
import '../../../../../model/message_enum_type.dart';
import '../messages_controller.dart';

class ChatMessageField extends StatelessWidget {
  const ChatMessageField({
    super.key,
    required this.controller,
    required this.chat,
  });

  final MessageController controller;
  final ChatConversation chat;

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
              child: Row(
                children: [
                  // emji button
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      controller.updateEmoji();
                      toast('Got');
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
                      maxLines: 1,
                      maxLength: 200,
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
                          chatID: chat.uid,
                          file: File(i.path),
                          members: chat.members,
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
                          chatID: chat.uid,
                          file: File(image.path),
                          members: chat.members,
                        );
                        controller.isUploadingImage(false);
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
            ),
          ),
          // send message
          MaterialButton(
            onPressed: () {
              if (controller.messageEditingController!.text.isNotEmpty) {
                // simple send message

                controller.sendTextMessage(
                  chatID: chat.uid,
                  members: chat.members,
                  text: controller.messageEditingController!.text.trim(),
                  type: MessageType.text,
                );
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
