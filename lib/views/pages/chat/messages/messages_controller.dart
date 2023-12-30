import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/chat_message_model.dart';
import '../../../../model/message_enum_type.dart';
import '../../../../model/notification_model.dart';
import '../../../../model/we_buzz_user_model.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/notification_services.dart';
import '../../../utils/custom_full_screen_dialog.dart';

class MessageController extends GetxController {
  static final MessageController instance = Get.find();

  TextEditingController? messageEditingController;

  static const String deleteChatTitle = 'Delete Chat';
  static const String exitChatTitle = 'Exit Chat';

  List<MessageModel> _messages = [];
  late WeBuzzUser _otherChatUser;
  bool showEmoji = false;
  bool _isUploading = false;

  void updateEmoji() {
    showEmoji = !showEmoji;
    update();
  }

  void addMessages(List<MessageModel> messages) {
    _messages = messages;
  }

  List<MessageModel> get messages => _messages;

  void isUploadingImage(bool isUploading) {
    _isUploading = isUploading;
    update();
  }

  bool get isUploading => _isUploading;

  @override
  void onInit() {
    super.onInit();
    messageEditingController = TextEditingController();
  }

  void initiateOtherChatUser(WeBuzzUser user) {
    _otherChatUser = user;
    update();
  }

  WeBuzzUser get otherChatUser => _otherChatUser;

  Stream<List<MessageModel>> streamChatMessagesForAChat(String chatID) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseChatCollection)
        .doc(chatID)
        .collection(firebaseMessageCollection)
        .orderBy('sentTime', descending: true)
        .snapshots()
        .map(
          (query) => query.docs
              .map((item) => MessageModel.fromDocumentSnapshot(item))
              .toList(),
        );
  }

  // Send text message
  void sendTextMessage({
    required String chatID,
    required List<WeBuzzUser> members,
    required String text,
    required MessageType type,
  }) async {
    if (text.isNotEmpty) {
      MessageModel message = MessageModel(
        senderID: FirebaseAuth.instance.currentUser!.uid,
        content: text,
        type: type,
        sentTime: DateTime.now(),
        docID: '',
        read: '',
        status: MessageStatus.notSent,
      );

      await FirebaseService.sendChatMessageToChat(message, chatID).then(
        (messageID) async {
          // Update chat recent_chat in firestore
          await FirebaseService.updateChatData(
            chatID,
            {
              "recent_time": FieldValue.serverTimestamp(),
            },
          );

          if (messageID != null) {
            // if return value isn't null

            // updateChatMessageRead(chatID, messageDoc)
            await FirebaseService.updateChatMessageData(
              chatID,
              messageID,
              {
                "status": MessageStatus.notView.name,
              },
            );
          }

          // Getting chat members without current user
          members = members
              .where(
                (member) =>
                    member.userId != FirebaseAuth.instance.currentUser!.uid,
              )
              .toList();
          for (var user in members) {
            // Looping through all members and sending them notification
            NotificationServices.sendNotification(
              notificationType: NotificationType.chat,
              targetUser: user,
              msg: message.content,
              messageType: message.type,
            );
          }
        },
      );
    }
  }

// Send chat image
  Future<void> sendChatImage({
    required List<WeBuzzUser> members,
    required File file,
    required String chatID,
  }) async {
    // getting image file extension
    final ext = file.path.split('.').last;

    // uploading imagel
    final ref = await FirebaseService.uploadImage(file,
        "chat_images/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch.toString()}.$ext");

    // Getting image url
    final text = ref!;

    sendTextMessage(
      chatID: chatID,
      members: members,
      text: text,
      type: MessageType.image,
    );
  }

  // for getting specific info of user in appBar
  Stream<WeBuzzUser> getUserInfo(WeBuzzUser weBuzzUser) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .where('userId', isEqualTo: weBuzzUser.userId)
        .snapshots()
        .map((event) => WeBuzzUser.fromDocument(event.docs.first));
  }

// Delete a chat, including its messages and associated files (if any).
  void deleteChat(String chatID, List<MessageModel> messages, bool admin,
      {bool isGroup = false, String? userID}) async {
    try {
      // Close the current dialog and navigate back to the previous page.
      Get.back(); // cancel the dialog
      Get.back(); // go back to the previous page

      // Show a loading spinner during the deletion process.
      CustomFullScreenDialog.showDialog(); // show loading spinner

      if (isGroup) {
        // If it's a group chat...

        // Check if the user is an admin or not.
        if (userID != null && admin) {
          // If the user is an admin, delete the chat and associated files.

          // Iterate through messages and delete image files.
          for (var message in messages) {
            if (message.type == MessageType.video ||
                message.type == MessageType.text ||
                message.type == MessageType.audio) {
              // Skip non-image messages.
              continue;
            }
            await FirebaseService.deleteImage(message.content);
          }

          // Delete the group chat.
          await FirebaseService.deleteChat(chatID).whenComplete(() {
            CustomFullScreenDialog.cancleDialog(); // cancel loading spinner
            toast('Successfully deleted');
          });
        } else if (userID != null && !admin) {
          // If the user is not an admin, exit the group and delete associated files.

          // Get messages sent by the current user.
          List<MessageModel> currentUserMessages =
              messages.where((message) => message.senderID == userID).toList();

          // Delete image files sent by the current user.
          for (var message in currentUserMessages) {
            if (message.type == MessageType.video ||
                message.type == MessageType.text ||
                message.type == MessageType.audio) {
              // Skip non-image messages.
              continue;
            }
            await FirebaseService.deleteImage(message.content);
          }

          // After deleting files, delete the messages in Firestore.
          for (var message in currentUserMessages) {
            deleteChatMessage(message, chatID);
          }

          // Delay for 2 seconds before exiting the group.
          await Future.delayed(const Duration(seconds: 2));

          // Exit the current user from the group.
          await FirebaseService.exitGroupChat(chatID, userID).whenComplete(() {
            CustomFullScreenDialog.cancleDialog(); // cancel loading spinner
            toast('Successfully exited');
          });
        }
      } else {
        // If it's not a group chat, delete the chat and associated files.

        // Delete image files sent in the chat.
        for (var message in messages) {
          if (message.type == MessageType.video ||
              message.type == MessageType.text ||
              message.type == MessageType.audio) {
            // Skip non-image messages.
            continue;
          }
          await FirebaseService.deleteImage(message.content);
        }

        // Delay for 2 seconds before deleting the chat.
        await Future.delayed(const Duration(seconds: 2));

        // Delete the chat.
        await FirebaseService.deleteChat(chatID).whenComplete(() {
          CustomFullScreenDialog.cancleDialog(); // cancel loading spinner
          toast('Successfully deleted');
        });
      }
    } catch (error) {
      // Handle errors during the deletion process.
      CustomFullScreenDialog
          .cancleDialog(); // cancel loading spinner in case of an error
      log('Error deleting chat: $error');
      toast('An error occurred while deleting the chat');
    }
  }

// Show a dialog for confirming the deletion or exit of a chat.
  void showChatDeletionDialog(
    String chatID,
    bool admin,
    List<MessageModel> messages, {
    bool isGroup = false,
    String? userID,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          isGroup ? (admin ? deleteChatTitle : exitChatTitle) : deleteChatTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          // Provide information about the consequences of the action.
          isGroup
              ? (admin
                  ? 'If you delete this chat, you will no longer be able to restore the chats!'
                  : 'If you exit this chat, you will no longer be able to join unless the admin adds you back.')
              : 'If you delete this chat, you will no longer be able to restore the chats!',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              // Cancel the deletion action.
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              // Delete or exit the chat.
              deleteChat(chatID, messages, admin,
                  userID: userID, isGroup: isGroup);
            },
            child: Text(
              // Display the appropriate action label.
              isGroup ? (admin ? 'Delete' : 'Exit') : 'Delete',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Delete chat message
  void deleteChatMessage(MessageModel message, String chatID) async {
    try {
      await FirebaseService.deleteChatMessage(message, chatID).then((_) async {
        toast("Message deleted");
        await FirebaseService.updateChatData(
          chatID,
          {
            "recent_time": FieldValue.serverTimestamp(),
          },
        );
        log('recent_time update');
      });
    } catch (e) {
      log("Error Deleting message");
      log(e);
    }
  }

// update chat message read
  void updateChatMessageRead(String chatID, String messageDoc) async {
    try {
      await FirebaseService.updateChatMessageData(chatID, messageDoc, {
        "status": MessageStatus.viewed.name,
        "read": DateTime.now().millisecondsSinceEpoch.toString(),
      });
    } catch (e) {
      log("Error updating chat message read");
      log(e);
    }
  }

// update message
  void updateMessage(
    String messageDoc,
    String chatID,
    String updatedMsg,
  ) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.updateChatMessageData(chatID, messageDoc, {
        "content": updatedMsg.trim(),
      }).then((value) async {
        CustomFullScreenDialog.cancleDialog();
        log('successifully updated !!!');
        await FirebaseService.updateChatData(
          chatID,
          {
            "recent_time": FieldValue.serverTimestamp(),
          },
        );
        log('recent_time update');
      });
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log("Error updating chat message");
      log(e);
    }
  }
}
