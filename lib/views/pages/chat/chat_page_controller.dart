import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

// Models
import '../../../model/chat_message.dart';

import '../../../model/message_enum_type.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';

class ChatPageController extends GetxController {
  static final ChatPageController instance = Get.find();

  late ScrollController messageListViewController;
  late GlobalKey<FormState> messageFormState;

  late StreamSubscription keyboardTypeVisibilityStream;
  late KeyboardListener keyboardVisibilityController;

  late TextEditingController? messageEditingController;
  late TextEditingController searchUserEditingController;

  bool showEmoji = false;
  bool isUploading = false;

  void updateEmoji() {
    showEmoji = !showEmoji;
    update();
  }

  void isUploadingImage(bool isUploading) {
    this.isUploading = isUploading;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    messageListViewController = ScrollController();
    messageFormState = GlobalKey<FormState>();

    messageEditingController = TextEditingController();
    searchUserEditingController = TextEditingController();
  }

  Stream<List<ChatMessage>> streamChatMessagesForAChat(String chatID) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseChatCollection)
        .doc(chatID)
        .collection(firebaseMessageCollection)
        .orderBy('sentTime', descending: true)
        .snapshots()
        .map(
          (query) =>
              query.docs.map((item) => ChatMessage.fromDocument(item)).toList(),
        );
  }

// Send text message
  void sendTextMessage(String chatID, MessageType type) {
    if (messageEditingController != null) {
      ChatMessage message = ChatMessage(
        senderID: FirebaseAuth.instance.currentUser!.uid,
        content: messageEditingController!.text.trim(),
        type: type,
        sentTime: DateTime.now(),
        docID: '',
        read: '',
      );

      FirebaseService.sendChatMessageToChat(message, chatID).then(
        (_) async {
          await FirebaseService.updateChatData(
            chatID,
            {
              "recent_time": FieldValue.serverTimestamp(),
            },
          );
          log('recent_time update');
        },
      );
    }
  }

// Send chat image
  Future<void> sendChatImage(WeBuzzUser user, File file, String chatID) async {
    // getting image file extension
    final ext = file.path.split('.').last;

    // uploading imagel
    final ref = await FirebaseService.uploadImage(file,
        "chat_images/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch.toString()}.$ext");

    // updating image in firestore
    messageEditingController!.text = ref!;
    sendTextMessage(chatID, MessageType.image);
  }

  // for getting specific info of user
  Stream<WeBuzzUser> getUserInfo(WeBuzzUser weBuzzUser) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .where('userId', isEqualTo: weBuzzUser.userId)
        .snapshots()
        .map((event) => WeBuzzUser.fromDocument(event.docs.first));
  }

//  delete message and leave the page
  void deleteChat(String chatID) {
    Get.back();
    FirebaseService.deleteChat(chatID);
  }

  void deleteChatMessage(ChatMessage message, String chatID) {
    FirebaseService.deleteChatMessage(message, chatID);
  }

  @override
  void onClose() {
    super.onClose();
    messageListViewController.dispose();
  }
}
