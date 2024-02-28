import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/message_model.dart';
import '../../../../model/message_enum_type.dart';
import '../../../../model/notification_model.dart';
import '../../../../model/report/report.dart';
import '../../../../model/we_buzz_user_model.dart';
import '../../../../services/bot_service.dart';
import '../../../../services/firebase_constants.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/notification_services.dart';
import '../../../utils/custom_full_screen_dialog.dart';
import '../../../utils/method_utils.dart';

class MessageController extends GetxController {
  static final MessageController instance = Get.find();

  late TextEditingController messageEditingController;

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

  String paths = '';
  List<MessageModel> get messages => _messages;

  void isUploadingImage(bool isUploading) {
    _isUploading = isUploading;
    update();
  }

  void setImagePath(String path) {
    paths = path;
    update();
  }

  bool get isUploading => _isUploading;
  bool isTyping = false;
  Timer? typingTimer;

  var hasNewLine = false;
  double size = 150;

  String? _chatId;

  @override
  void onInit() {
    super.onInit();
    messageEditingController = TextEditingController();

    messageEditingController.addListener(() {
      _onTextChanged();
    });
  }

  void _onTextChanged() {
    String text = messageEditingController.text;
    // Replace the width value with your desired threshold
    double widthThreshold = 200.0; // Example threshold
    double textWidth = getTextWidth(text);
    hasNewLine = textWidth > widthThreshold;
    update();
  }

  double getTextWidth(String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14.6, // Adjust to your TextField's font size
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  void initiateOtherChatUser(WeBuzzUser user) {
    _otherChatUser = user;
    update();
  }

  void startTyping(String chatID) async {
    _chatId=chatID;
    try {
      await FirebaseService.updateChatData(chatID, {'is_activity': true});
    } catch (e) {
      log('Error trying to update istyping');
      log(e);
    }
    // isTyping = true;
    // update();
  }

  void stopTyping(String chatID) async {
    try {
      await FirebaseService.updateChatData(chatID, {'is_activity': false});
    } catch (e) {
      log('Error trying to update istyping');
      log(e);
    }
    // isTyping = false;
    // update();
  }

  void onTextChanged(String text, String chatID) {
    if (text.isNotEmpty) {
      if (typingTimer != null && typingTimer!.isActive) {
        typingTimer!.cancel(); // Cancel the previous timer
      }
      startTyping(chatID);

      // Start a new timer to detect when the user stops typing
      typingTimer = Timer(const Duration(seconds: 2), () {
        stopTyping(chatID);
      });
    } else {
      stopTyping(chatID);
    }
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

  void chatWithBot(
      {required String chatID,
      required List<WeBuzzUser> members,
      required String text,
      required MessageType type,
      required WeBuzzUser bot}) async {
    if (text.isNotEmpty) {
      MessageModel message = MessageModel(
        senderID: FirebaseAuth.instance.currentUser!.uid,
        content: text,
        type: type,
        sentTime: DateTime.now().millisecondsSinceEpoch.toString(),
        docID: '',
        read: '',
        status: MessageStatus.notSent,
      );

      final messageID =
          await FirebaseService.sendChatMessageToChat(message, chatID);

      if (messageID != null) {
        await FirebaseService.updateChatData(
          chatID,
          {
            "recent_time": FieldValue.serverTimestamp(),
          },
        );

        // updateChatMessageRead(chatID, messageDoc)
        await FirebaseService.updateChatMessageData(
          chatID,
          messageID,
          {
            "status": MessageStatus.notView.name,
          },
        );

        // Initiate Chat With But
        final botResponse = await BotService().getData(message.content);

        if (botResponse != null) {
          sendTextMessage(
            chatID: chatID,
            members: members,
            text: botResponse,
            type: type,
            isGroup: false,
            senderID: bot.userId,
          );
        }
      }
    }
  }

  // Send text message
  void sendTextMessage({
    required String chatID,
    required List<WeBuzzUser> members,
    required String text,
    required String senderID,
    required MessageType type,
    required bool isGroup,
    bool isBot = false,
  }) async {
    if (text.isNotEmpty) {
      MessageModel message = MessageModel(
        senderID: senderID,
        content: text,
        type: type,
        sentTime: DateTime.now().millisecondsSinceEpoch.toString(),
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
          if (!isBot) {
            for (var user in members) {
              // Looping through all members and sending them notification
              if (user.userId == FirebaseAuth.instance.currentUser!.uid) {
                // Skip if user is current user
                continue;
              }

              NotificationServices.sendNotification(
                notificationType: NotificationType.chat,
                targetUser: user,
                msg: message.content,
                messageType: message.type,
                notifiactionRef: chatID,
              );
            }
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
    required bool isGroup,
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
      isGroup: isGroup,
      senderID: FirebaseAuth.instance.currentUser!.uid,
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

  void _deleteGroupChat({
    required String chatID,
    required List<MessageModel> messages,
    required bool admin,
    String? userID,
  }) async {
    try {
      // Close the current dialog and navigate back to the previous page.
      Get.back(); // cancel the dialog
      Get.back(); // go back to the previous page
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
        await FirebaseService.deleteChat(chatID).then((_) async {
          toast('Successfully deleted');

          List<Report> reporters = [];

          // Query to get reports related to the chat
          final reportQuery = await FirebaseService.firebaseFirestore
              .collection(firebaseReportCollection)
              .where('reportedItemId', isEqualTo: chatID)
              .get();
          for (var doc in reportQuery.docs) {
            reporters.add(Report.fromSnapshot(doc));
          }

          // Iterate through reporters list and delete each report related to the post
          for (var report in reporters) {
            await FirebaseService.firebaseFirestore
                .collection(firebaseReportCollection)
                .doc(report.id)
                .delete();
          }
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
          toast('Successfully exited');
        });
      }
    } catch (error) {
      log('Error deleting chat: $error');
      toast('An error occurred while deleting the chat');
    }
  }

// Delete a chat, including its messages and associated files (if any).
  void _deleteChat(
    String chatID,
    List<MessageModel> messages, {
    String? userID,
  }) async {
    try {
      // Close the current dialog and navigate back to the previous page.
      Get.back(); // cancel the dialog
      Get.back(); // go back to the previous page

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
      await FirebaseService.deleteChat(chatID).then(
        (_) async {
          toast('Successfully deleted');

          List<Report> reporters = [];

          // Query to get reports related to the chat
          final reportQuery = await FirebaseService.firebaseFirestore
              .collection(firebaseReportCollection)
              .where('reportedItemId', isEqualTo: chatID)
              .get();
          for (var doc in reportQuery.docs) {
            reporters.add(Report.fromSnapshot(doc));
          }

          // Iterate through reporters list and delete each report related to the post
          for (var report in reporters) {
            await FirebaseService.firebaseFirestore
                .collection(firebaseReportCollection)
                .doc(report.id)
                .delete();
          }
        },
      );
    } catch (error) {
      // Handle errors during the deletion process.
      log('Error deleting chat: $error');
      toast('An error occurred while deleting the chat');
    }
  }

// Show a dialog for confirming the deletion or exition of a group chat.
  void showGroupChatDeletionDialog({
    required String chatID,
    String? userID,
    required bool admin,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          admin ? deleteChatTitle : exitChatTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          admin
              ? 'If you delete this chat, you will no longer be able to restore the chats!'
              : 'If you exit this chat, you will no longer be able to join unless the admin adds you back.',
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
              _deleteGroupChat(
                  chatID: chatID,
                  messages: messages,
                  admin: admin,
                  userID: userID);
            },
            child: Text(
              // Display the appropriate action label.
              (admin ? 'Delete' : 'Exit'),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }

// Show a dialog for confirming the deletion of a chat.
  void showChatDeletionDialog({
    required List<MessageModel> messages,
    required String chatID,
    String? userID,
  }) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          deleteChatTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          // Provide information about the consequences of the action.
          'If you delete this chat, you will no longer be able to restore the chats!',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
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
              _deleteChat(chatID, messages, userID: userID);
            },
            child: const Text(
              // Display the appropriate action label.
              'Delete',
              style: TextStyle(
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
      _chatId = chatID;
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

  void reportChat({
    String? userID,
    required String chatID,
    required List<MessageModel> messages,
    required bool isGroup,
    required WeBuzzUser otherUser,
  }) async {
    try {
      if (userID == null) return;

      var othersMessages = messages.where((m) => m.senderID != userID).toList();

      // Sorting the messages
      othersMessages.sort((a, b) {
        final DateTime aTime =
            DateTime.fromMillisecondsSinceEpoch(int.parse(a.sentTime));
        final DateTime bTime =
            DateTime.fromMillisecondsSinceEpoch(int.parse(b.sentTime));

        return bTime.compareTo(aTime);
      });
      // Get the last three Messages
      List<String> lastThreeMessages = [];

      for (var i = 0; i < othersMessages.length; i++) {
        if (i < 3) {
          lastThreeMessages.add(othersMessages[i].content);
        } else {
          continue;
        }
      }

      if (isGroup) {
        Report data = Report(
          id: MethodUtils.generatedId,
          reporterUserId: userID,
          reportedItemId: chatID,
          reportType: ReportType.groupChat,
          description: '',
          lastThreeMessages: lastThreeMessages,
        );

        await FirebaseService.reportBuzz(chatID, data, false).whenComplete(() {
          Get.back();
          toast('Group reported');
        });
      } else {
        Report chat = Report(
          id: MethodUtils.generatedId,
          reporterUserId: userID,
          reportedItemId: chatID,
          reportType: ReportType.chat,
          description: '',
          lastThreeMessages: lastThreeMessages,
        );
        Report user = Report(
          id: MethodUtils.generatedId,
          reporterUserId: userID,
          reportedItemId: otherChatUser.userId,
          reportType: ReportType.user,
          description: '',
          lastThreeMessages: lastThreeMessages,
        );

        await FirebaseService.reportBuzz(chatID, chat, false).whenComplete(() {
          Get.back();
          toast('Chat reported');
        });

        await 2.delay();

        await FirebaseService.reportBuzz(otherUser.userId, user, false)
            .whenComplete(() {
          Get.back();
          toast('User reported');
        });
      }
    } catch (e) {
      log("Error reporting post");
      log(e);
    }
  }

  void gemineTextAndImage({
    required String text,
    required String path,
    required String chatID,
    required List<WeBuzzUser> members,
    required String senderID,
    required MessageType type,
    required WeBuzzUser otherChatUser,
  }) async {
    try {
      final gemini = Gemini.instance;
      log('Calling bot');
      final file = File(path);

      gemini.streamGenerateContent(
        text,
        images: [file.readAsBytesSync()],
      ).listen((value) {
        final response = value.content?.parts?.last.text;
        if (response != null) {
          sendTextMessage(
            chatID: chatID,
            members: members,
            text: response,
            senderID: otherChatUser.userId,
            type: type,
            isGroup: false,
            isBot: true,
          );
        }
      });
    } catch (e) {
      log('textAndImageInput error: $e');
    }
  }

  void gemineText({
    required String text,
    required String chatID,
    required List<WeBuzzUser> members,
    required String senderID,
    required MessageType type,
    required WeBuzzUser otherChatUser,
  }) async {
    try {
      final gemini = Gemini.instance;
      // gemini.streamGenerateContent(text).listen((event) {
      //   sendTextMessage(
      //     chatID: chatID,
      //     members: members,
      //     text: event.output ?? 'Something went wrong',
      //     senderID: otherChatUser.userId,
      //     type: type,
      //     isGroup: false,
      //   );
      // });

      // gemini.streamGenerateContent(text);

      gemini.streamGenerateContent(text).listen((value) {
        if (value.output == null) return;
        sendTextMessage(
          chatID: chatID,
          members: members,
          text: value.output ?? 'Something went wrong',
          senderID: otherChatUser.userId,
          type: type,
          isGroup: false,
          isBot: true,
        );
      });
    } catch (e) {
      log('text chat error: $e');
    }
  }

  void gemineChat({
    required String text,
    required String chatID,
    required List<WeBuzzUser> members,
    required MessageType type,
    required WeBuzzUser bot,
    required List<MessageModel> messages,
  }) async {
    final gemini = Gemini.instance;

    try {
      messages.sort((a, b) {
        final DateTime aTime =
            DateTime.fromMillisecondsSinceEpoch(int.parse(a.sentTime));
        final DateTime bTime =
            DateTime.fromMillisecondsSinceEpoch(int.parse(b.sentTime));

        return aTime.compareTo(bTime);
      });

      // var contents = _messages.map((e) {
      //   if (e.senderID != bot.userId) {
      //     return Content(
      //       parts: [
      //         Parts(
      //           text: e.content,
      //         )
      //       ],
      //       role: 'user',
      //     );
      //   } else {
      //     return Content(
      //       parts: [
      //         Parts(
      //           text: e.content,
      //         )
      //       ],
      //       role: 'model',
      //     );
      //   }
      // }).toList();

      // log('I got called by chatting');
      // log(contents);
      // log(text);

      List<Content> formattedMessages = messages.map((message) {
        String role = (message.senderID == bot.userId) ? 'model' : 'user';
        List<Parts> partsList = [Parts(text: message.content)];
        return Content(parts: partsList, role: role);
      }).toList();

      log([
        ...formattedMessages,
        Content(parts: [Parts(text: text)], role: 'user'),
      ]);
      await gemini.chat(
        [
          Content(parts: [Parts(text: text)], role: 'user'),
        ],
      ).then((value) {
        log(value?.output ?? 'ERROR');
        sendTextMessage(
          chatID: chatID,
          members: members,
          text: value!.output ?? 'Something went wrong',
          senderID: bot.userId,
          type: type,
          isGroup: false,
          isBot: true,
        );
      });
    } catch (e) {
      log('text chat for chat error: $e');
    }

    // gemini
    // .chat([
    //   Content(
    //     parts: [
    //       Parts(
    //         text: 'Write the first line of a story about a magic backpack.',
    //       )
    //     ],
    //     role: 'user',
    //   ),
    //   Content(parts: [
    //     Parts(
    //         text:
    //             'In the bustling city of Meadow brook, lived a young girl named Sophie. She was a bright and curious soul with an imaginative mind.')
    //   ], role: 'model'),
    //   Content(parts: [
    //     Parts(text: 'Can you set it in a quiet village in 1600s France?')
    //   ], role: 'user'),
    // ])
    //     .then((value) => log(value?.output ?? 'without output'))
    //     .catchError((e) => log('chat, error: $e'));
  }

  @override
  void onClose() {
    super.onClose();
    messageEditingController.dispose();
    if (typingTimer != null) typingTimer!.cancel();
    if (_chatId != null) stopTyping(_chatId!);
  }
}
