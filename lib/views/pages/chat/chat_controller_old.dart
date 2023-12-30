import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/notification_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/message_enum_type.dart';
import '../../../model/message_model.dart';
import '../../../model/we_buzz_user_model.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../../services/notification_services.dart';
import '../../utils/custom_full_screen_dialog.dart';
import '../dashboard/my_app_controller.dart';

class ChatControllerOld extends GetxController {
  static ChatControllerOld instance = Get.find();

  RxList<WeBuzzUser> weBuzzLists = RxList<WeBuzzUser>([]);

  RxList<WeBuzzUser> searchUsers = RxList<WeBuzzUser>([]);
  RxBool isTyping = RxBool(false);
  RxBool isSearched = RxBool(false);

  late TextEditingController messageEditingController;
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

  void searchUser() {
    isTyping.value = true;
    searchUsers.value = weBuzzLists
        .where(
          (user) =>
              user.name.toLowerCase().contains(
                  searchUserEditingController.text.trim().toLowerCase()) ||
              user.email.toLowerCase().contains(
                    searchUserEditingController.text.toLowerCase().trim(),
                  ),
        )
        .toList();
  }

  void cancleSearch() {
    isTyping.value = !isTyping.value;
  }

  void search() {
    if (isSearched.isFalse) {
      isSearched.value = true;
      if (kDebugMode) {
        print('Search!!!');
      }
    } else {
      isSearched.value = false;

      if (kDebugMode) {
        print('Unsearch!!!');
      }
    }

    update();
  }

  @override
  void onInit() {
    super.onInit();
    weBuzzLists.bindStream(_streamTweetBuzz());
    messageEditingController = TextEditingController();
    searchUserEditingController = TextEditingController();
  }

// stream all users
  Stream<List<WeBuzzUser>> _streamTweetBuzz() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .snapshots()
        .map((query) => query.docs.map((user) {
              return WeBuzzUser.fromDocument(user);
            }).toList());
  }

// stream current user's friends id
  Stream<List<String>> streamCurrentUserFriendsID() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(firebaseMyUsersCollection)
        .snapshots()
        .map((query) => query.docs.map((user) {
              return user.id;
            }).toList());
  }

// stream current user's friens
  Stream<List<WeBuzzUser>> streamCurrentUserFriends(List<String> users) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .where('userId', whereIn: users)
        .snapshots()
        .map((q) =>
            q.docs.map((user) => WeBuzzUser.fromDocument(user)).toList());
  }

  // For getting conversation id
  String getConversationId(String id) =>
      AppController.instance.auth.currentUser!.uid.hashCode <= id.hashCode
          ? '${AppController.instance.auth.currentUser!.uid}_$id'
          : '${id}_${AppController.instance.auth.currentUser!.uid}';

// for getting all messages for a specific conversation from firestore database
  Stream<List<Message>> streamAllMessages(WeBuzzUser user) {
    return FirebaseService.firebaseFirestore
        .collection(
            'chats/${getConversationId(user.userId)}/$firebaseMessageCollection/')
        .orderBy('sent', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((message) => Message.fromDocument(message))
            .toList());
  }

  // for sending message
  Future<void> sendMessage(
    WeBuzzUser webuzzUser,
    String message,
    MessageType messageType,
  ) async {
    // message sending time, also used as id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message msg = Message(
      told: webuzzUser.userId,
      message: message,
      read: '',
      type: messageType,
      fromId: AppController.instance.auth.currentUser!.uid,
      sent: time,
    );
    final ref = FirebaseService.firebaseFirestore.collection(
        'chats/${getConversationId(webuzzUser.userId)}/$firebaseMessageCollection/');

    await ref.doc(time).set(msg.toMap()).then((value) {
      NotificationServices.sendNotification(
        notificationType: NotificationType.chat,
        targetUser: webuzzUser,
        messageType: messageType,
        msg: message,
      );
    });
  }

  // for adding an user to my_user collection when first message is send
  Future<void> sendFirstMessage(
    WeBuzzUser webuzzUser,
    String message,
    MessageType messageType,
  ) async {
    await FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzCollection)
        .doc(webuzzUser.userId)
        .collection(firebaseMyUsersCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({}).then((value) => sendMessage(webuzzUser, message, messageType));

    // message sending time, also used as id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message msg = Message(
      told: webuzzUser.userId,
      message: message,
      read: '',
      type: messageType,
      fromId: AppController.instance.auth.currentUser!.uid,
      sent: time,
    );
    final ref = FirebaseService.firebaseFirestore.collection(
        'chats/${getConversationId(webuzzUser.userId)}/$firebaseMessageCollection/');

    await ref.doc(time).set(msg.toMap()).then((value) {
      NotificationServices.sendNotification(
        notificationType: NotificationType.chat,
        targetUser: webuzzUser,
        messageType: messageType,
        msg: message,
      );
    });
  }

// update message read
  Future<void> updateMessageReadStatus(Message message) async {
    await FirebaseService.firebaseFirestore
        .collection(
            'chats/${getConversationId(message.fromId)}/$firebaseMessageCollection/')
        .doc(message.sent)
        .update({
      'read': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

// get last messages for recent chats
  Stream<Message?> getLastMessage(WeBuzzUser weBuzzUser) {
    return FirebaseService.firebaseFirestore
        .collection(
            'chats/${getConversationId(weBuzzUser.userId)}/$firebaseMessageCollection/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (q) => Message.fromDocument(q.docs.last),
        );
  }

// Send chat image
  Future<void> sendChatImage(WeBuzzUser user, File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;

    // storage file ref with path
    final ref = FirebaseStorage.instance.ref().child(
        "chat_images/${getConversationId(user.userId)}/${DateTime.now().millisecondsSinceEpoch.toString()}.$ext");

// uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      log("Data Transferred: ${p0.bytesTransferred / 1000} kb");
    });

    // updating image in firestore
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(user, imageUrl, MessageType.image);
  }

// for adding chat users
  Future<bool> addChatUser(String username) async {
    final data = await FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .where('username', isEqualTo: username)
        .get();

    log('data: ${data.docs}');
    if (data.docs.isNotEmpty &&
        data.docs.first.id != FirebaseAuth.instance.currentUser!.uid) {
      // user exits

      await FirebaseService.firebaseFirestore
          .collection(firebaseWeBuzzUserCollection)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(firebaseMyUsersCollection)
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      // user doesn't exits

      return false;
    }
  }

// for getting specific info of user
  Stream<WeBuzzUser> getUserInfo(WeBuzzUser weBuzzUser) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUserCollection)
        .where('userId', isEqualTo: weBuzzUser.userId)
        .snapshots()
        .map((event) => WeBuzzUser.fromDocument(event.docs.first));
  }

// update message
  Future<void> updateMessage(Message message, String updatedMsg) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.firebaseFirestore
          .collection(
              'chats/${getConversationId(message.told)}/$firebaseMessageCollection/')
          .doc(message.sent)
          .update({'message': updatedMsg}).then((value) {
        CustomFullScreenDialog.cancleDialog();
        log('successifully updated !!!');
      });
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log(e);
    }
  }

// delete message
  Future<void> deleteMessage(Message message) async {
    CustomFullScreenDialog.showDialog();
    try {
      await FirebaseService.firebaseFirestore
          .collection(
              'chats/${getConversationId(message.told)}/$firebaseMessageCollection/')
          .doc(message.sent)
          .delete()
          .then((value) {
        CustomFullScreenDialog.cancleDialog();
        log('successifully deleted!!!');
      });
      if (message.type == MessageType.image) {
        await FirebaseStorage.instance.refFromURL(message.message).delete();
      }
    } catch (e) {
      CustomFullScreenDialog.cancleDialog();
      log(e);
    }
  }

  @override
  void onClose() {
    super.onClose();
    messageEditingController.clear();
  }
}
