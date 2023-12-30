// import 'dart:async';
// import 'dart:io';

// // Packages
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:nb_utils/nb_utils.dart';

// // Models
// import '../../../model/chat_message_model.dart';
// import '../../../model/message_enum_type.dart';
// import '../../../model/notification_model.dart';
// import '../../../model/we_buzz_user_model.dart';

// // Services
// import '../../../services/firebase_constants.dart';
// import '../../../services/firebase_service.dart';
// import '../../../services/notification_services.dart';

// // Utils
// import '../../utils/custom_full_screen_dialog.dart';

// class ChatPageController extends GetxController {
//   static final ChatPageController instance = Get.find();

//   late StreamSubscription keyboardTypeVisibilityStream;
//   late KeyboardListener keyboardVisibilityController;

//   late TextEditingController? messageEditingController;

//   bool showEmoji = false;
//   bool isUploading = false;

//   void updateEmoji() {
//     showEmoji = !showEmoji;
//     update();
//   }

//   void isUploadingImage(bool isUploading) {
//     this.isUploading = isUploading;
//     update();
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     messageEditingController = TextEditingController();
//   }

//   Stream<List<ChatMessage>> streamChatMessagesForAChat(String chatID) {
//     return FirebaseService.firebaseFirestore
//         .collection(firebaseChatCollection)
//         .doc(chatID)
//         .collection(firebaseMessageCollection)
//         .orderBy('sentTime', descending: true)
//         .snapshots()
//         .map(
//           (query) =>
//               query.docs.map((item) => ChatMessage.fromDocument(item)).toList(),
//         );
//   }

// // Send text message
//   void sendTextMessage({
//     required String chatID,
//     required List<WeBuzzUser> members,
//     required String text,
//     required MessageType type,
//   }) async {
//     if (text.isNotEmpty) {
//       ChatMessage message = ChatMessage(
//         senderID: FirebaseAuth.instance.currentUser!.uid,
//         content: text,
//         type: type,
//         sentTime: DateTime.now(),
//         docID: '',
//         read: '',
//       );

//       await FirebaseService.sendChatMessageToChat(message, chatID).then(
//         (_) async {
//           await FirebaseService.updateChatData(
//             chatID,
//             {
//               "recent_time": FieldValue.serverTimestamp(),
//             },
//           );
//           // Getting chat members without current user
//           members = members
//               .where((member) =>
//                   member.userId != FirebaseAuth.instance.currentUser!.uid)
//               .toList();
//           for (var user in members) {
//             // Looping through all members and sending them notification
//             NotificationServices.sendNotification(
//               notificationType: NotificationType.chat,
//               targetUser: user,
//               msg: message.content,
//               messageType: message.type,
//             );
//           }
//         },
//       );
//     }
//   }

// // Send chat image
//   Future<void> sendChatImage({
//     required List<WeBuzzUser> members,
//     required File file,
//     required String chatID,
//   }) async {
//     // getting image file extension
//     final ext = file.path.split('.').last;

//     // uploading imagel
//     final ref = await FirebaseService.uploadImage(file,
//         "chat_images/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch.toString()}.$ext");

//     // Getting image url
//     final text = ref!;

//     sendTextMessage(
//       chatID: chatID,
//       members: members,
//       text: text,
//       type: MessageType.image,
//     );
//   }

//   // for getting specific info of user
//   Stream<WeBuzzUser> getUserInfo(WeBuzzUser weBuzzUser) {
//     return FirebaseService.firebaseFirestore
//         .collection(firebaseWeBuzzUserCollection)
//         .where('userId', isEqualTo: weBuzzUser.userId)
//         .snapshots()
//         .map((event) => WeBuzzUser.fromDocument(event.docs.first));
//   }

// //  delete message and leave the page
//   void deleteChat(String chatID, List<ChatMessage> messages, bool admin,
//       {bool isGroup = false, String? userID}) async {
//     Get.back(); // cancel the dialog
//     Get.back(); // go back to previous page
//     CustomFullScreenDialog.showDialog(); // show laodinng spinner
//     if (isGroup) {
//       // if isgroup remove current user from the groupchat
//       if (userID != null && admin) {
//         // if userId is not null and user is admin

//         // Delete the chat and the messages
//         for (var message in messages) {
//           if (message.content.isURL && message.type == MessageType.image) {
//             await FirebaseService.deleteImage(message.content);
//             continue;
//           }
//         }

//         // delete the group chat
//         await FirebaseService.deleteChat(chatID).whenComplete(
//           () {
//             CustomFullScreenDialog.cancleDialog(); // cancel loading spinner
//             toast('Successifully delete');
//           },
//         );
//       } else if (userID != null && !admin) {
//         // if userid is not null and user is not an admin

//         // Get all the current user's messages
//         List<ChatMessage> currentUserMessages =
//             messages.where((message) => message.senderID == userID).toList();

//         // loop and delete all the images in cloud storage
//         for (var message in currentUserMessages) {
//           if (message.content.isURL && message.type == MessageType.image) {
//             // if message content is a link and an image, then go ahead and delete the file in cloud storage
//             await FirebaseService.deleteImage(message.content);
//             continue;
//           }
//         }

//         // Detele every single message in the firestore
//         for (var message in currentUserMessages) {
//           deleteChatMessage(message, chatID);
//         }

//         await Future.delayed(const Duration(seconds: 2)); // delay for 2 sec.

//         // Exit the current user from the group
//         await FirebaseService.exitGroupChat(chatID, userID).whenComplete(
//           () {
//             CustomFullScreenDialog.cancleDialog(); // cancel loading spinner
//             toast('Successifully exit');
//           },
//         );
//       }
//     } else {
//       // else delete the chat completely

//       // delete all the images has been sent in the chat
//       for (var message in messages) {
//         if (message.content.isURL && message.type == MessageType.image) {
//           // if message content is a link, then go ahead and delete the file in cloud storage
//           await FirebaseService.deleteImage(message.content);
//           continue;
//         }
//       }

//       await Future.delayed(
//         const Duration(seconds: 2), //Two seconds delay before deleting the chat
//       );

//       // Delete the chat
//       await FirebaseService.deleteChat(chatID).whenComplete(
//         () {
//           CustomFullScreenDialog.cancleDialog(); // cancel loading spinner
//           toast('Successifully delete');
//         },
//       );
//     }
//   }

//   void showDeleteChatDialog(
//     String chatID,
//     bool admin,
//     List<ChatMessage> messages, {
//     bool isGroup = false,
//     String? userID,
//   }) {
//     Get.dialog(
//       AlertDialog(
//         title: Text(
//           isGroup
//               ? isGroup && admin
//                   ? 'Delete Chat'
//                   : 'Exit Chat'
//               : 'Delete Chat',
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         content: Text(
//           isGroup
//               ? isGroup && admin
//                   ? 'If you delete this chat you\'ll no longer gonna restore the chats!'
//                   : 'If you exit this chat you\'ll no longer gonna join the chat unless the admin has put you back again'
//               : 'If you delete this chat you\'ll no longer gonna restore the chats!',
//           style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
//         ),
//         actions: [
//           MaterialButton(
//             onPressed: () {
//               Get.back();
//             },
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           MaterialButton(
//             onPressed: () {
//               // Delete or Exit the chat
//               deleteChat(chatID, messages, admin,
//                   userID: userID, isGroup: isGroup);
//             },
//             child: Text(
//               isGroup
//                   ? isGroup && admin
//                       ? 'Delete'
//                       : 'Exit'
//                   : 'Delete',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// // Delete chat message
//   void deleteChatMessage(ChatMessage message, String chatID) {
//     try {
//       FirebaseService.deleteChatMessage(message, chatID).then((_) async {
//         toast("Message deleted");
//         await FirebaseService.updateChatData(
//           chatID,
//           {
//             "recent_time": FieldValue.serverTimestamp(),
//           },
//         );
//         log('recent_time update');
//       });
//     } catch (e) {
//       log("Error Deleting message");
//       log(e);
//     }
//   }

// // update chat message read
//   void updateChatMessageRead(String chatID, String messageDoc) async {
//     try {
//       await FirebaseService.updateChatMessageData(chatID, messageDoc, {
//         "read": DateTime.now().millisecondsSinceEpoch.toString(),
//       });
//     } catch (e) {
//       log("Error updating chat message read");
//       log(e);
//     }
//   }

// // update message
//   void updateMessage(
//     String messageDoc,
//     String chatID,
//     String updatedMsg,
//   ) async {
//     CustomFullScreenDialog.showDialog();
//     try {
//       await FirebaseService.updateChatMessageData(chatID, messageDoc, {
//         "content": updatedMsg,
//       }).then((value) async {
//         CustomFullScreenDialog.cancleDialog();
//         log('successifully updated !!!');
//         await FirebaseService.updateChatData(
//           chatID,
//           {
//             "recent_time": FieldValue.serverTimestamp(),
//           },
//         );
//         log('recent_time update');
//       });
//     } catch (e) {
//       CustomFullScreenDialog.cancleDialog();
//       log("Error updating chat message");
//       log(e);
//     }
//   }

//   @override
//   void onClose() {
//     super.onClose();
//     messageEditingController!.clear();
//   }
// }
