import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/message_enum_type.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/message_model.dart';
import '../../../model/user.dart';
import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../../services/notification_services.dart';
import '../../widgets/chat/fquser_widget.dart';
import '../dashboard/dashboard_controller.dart';

class ChatController extends GetxController {
  static ChatController instance = Get.find();
  final List<FQUsers> fqusers = const [
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
  ];
  RxList<WeBuzzUser> weBuzzLists = RxList<WeBuzzUser>([]);
  RxList<Message> allMessage = RxList<Message>([]);

  late TextEditingController messageEditingController;

  bool showEmoji = false;
  bool isUploading = false;

  void updateEmoji() {
    showEmoji = !showEmoji;
    update();
  }

  void isUpdateFalse() {
    isUploading = false;
    update();
  }

  void isUpdateTrue() {
    isUploading = true;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    weBuzzLists.bindStream(_streamTweetBuzz());
    messageEditingController = TextEditingController();
  }

  Stream<List<WeBuzzUser>> _streamTweetBuzz() {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUser)
        .where('userId', isNotEqualTo: AppController.instance.auth.currentUser!.uid)
        .snapshots()
        .map((query) =>
            query.docs.map((user) => WeBuzzUser.fromDocument(user)).toList());
  }

  // For getting conversation id
  String getConversationId(String id) => AppController.instance.auth.currentUser!.uid.hashCode <= id.hashCode
      ? '${AppController.instance.auth.currentUser!.uid}_$id'
      : '${id}_${AppController.instance.auth.currentUser!.uid}';

// for getting all messages for a specific conversation from firestore database
  Stream<List<Message>> streamAllMessages(WeBuzzUser user) {
    return FirebaseService.firebaseFirestore
        .collection(
            'chats/${getConversationId(user.userId)}/$firebaseMessages/')
        .orderBy('sent', descending: true)
        .snapshots()
        .map((query) => query.docs
            .map((message) => Message.fromDocument(message))
            .toList());
  }

  // for sending message
  Future<void> sendMessage(
      WeBuzzUser webuzzUser, String message, MessageType messageType) async {
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
        'chats/${getConversationId(webuzzUser.userId)}/$firebaseMessages/');

    await ref.doc(time).set(msg.toMap()).then((value) {
      NotificationServices.sendNotificationTokenForChat(
          webuzzUser, message, messageType);
    });
  }

// update message read
  Future<void> updateMessageReadStatus(Message message) async {
    await FirebaseService.firebaseFirestore
        .collection(
            'chats/${getConversationId(message.fromId)}/$firebaseMessages/')
        .doc(message.sent)
        .update({
      'read': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

// get last messages for recent chats
  Stream<Message?> getLastMessage(WeBuzzUser weBuzzUser) {
    return FirebaseService.firebaseFirestore
        .collection(
            'chats/${getConversationId(weBuzzUser.userId)}/$firebaseMessages/')
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

// for getting specific info of user
  Stream<WeBuzzUser> getUserInfo(WeBuzzUser weBuzzUser) {
    return FirebaseService.firebaseFirestore
        .collection(firebaseWeBuzzUser)
        .where('userId', isEqualTo: weBuzzUser.userId)
        .snapshots()
        .map((event) => WeBuzzUser.fromDocument(event.docs.first));
  }

  @override
  void onClose() {
    super.onClose();
    messageEditingController.clear();
  }
}
