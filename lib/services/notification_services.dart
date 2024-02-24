import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hi_tweet/views/utils/method_utils.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/message_enum_type.dart';
import '../model/notification_model.dart';
import '../model/we_buzz_user_model.dart';
import '../views/pages/dashboard/my_app_controller.dart';
import 'api_keys.dart';
import 'firebase_service.dart';

class NotificationServices {
  // for sending push notifiaction
  static Future<void> _sendNotificationTokenForChat({
    required WeBuzzUser weBuzzUser,
    required String msg,
    required MessageType messageType,
    required String messageRef,
    required String type,
  }) async {
    try {
      final body = {
        "to": weBuzzUser.pushToken,
        "notification": {
          "title": AppController.instance.currentUser!.name,
          messageType == MessageType.image ? "image" : "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${AppController.instance.currentUser!.userId}",
          "type": type,
          "messageRef": messageRef,
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                "key=AAAAJFTH-o0:APA91bGRklMgyJwJJ2R2yss6N8HJwJjHRroVPALk6VPit3vMuXWqs7w9ddaL9WC5UxpFyfwkOgLrhG2phEDwL3N7RBxiDyiDjkWppOirvxU6JrV-TCuD_957P23g2dENJqIfidPvz71i",
          },
          body: jsonEncode(body));

      log("Response status: ${res.statusCode}");
      log("Response body: ${res.body}");
    } catch (e) {
      log("\nsendNotificationE: $e");
    }
  }

  static Future<void> notifiactionRequest({
    required String pushToken,
    required String notificationBody,
    required String title,
    MessageType? messageType,
    required String messageRef,
    required String type,
  }) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": title,
          if (messageType != null && messageType == MessageType.image)
            "image": notificationBody
          else
            "body": notificationBody,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${AppController.instance.currentUser!.userId}",
          "type": type,
          "messageRef": messageRef,
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: "key=$firebaseMessagingApiKey",
          },
          body: jsonEncode(body));

      log("Response status: ${res.statusCode}");
      log("Response body: ${res.body}");
    } catch (e) {
      log("\nsendNotificationE: $e");
    }
  }

  static void sendNotification({
    required WeBuzzUser targetUser,
    required NotificationType notificationType,
    String? groupChat,
    String? msg,
    required String notifiactionRef,
    MessageType? messageType,
  }) async {
    // terminate if currentuser is null
    if (FirebaseAuth.instance.currentUser == null) return;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Current user data
    final currentUser = await FirebaseService.userByID(currentUserId);
    if (currentUser == null) return;
    List<String> followersList = [];

    // All users of we buzz, except me
    // final allUsers = AppController.instance.weBuzzUsers
    //     .where((user) => user.userId != currentUser.userId)
    //     .toList();

    try {
      followersList = await FirebaseService.getFollowersList(currentUserId);
    } catch (e) {
      log('Error trying to get users followers and following');
      log(e);
    }

    switch (notificationType) {
      // Post creation by current user, send notification to his followers
      case NotificationType.postCreation:

        // Loop through all the current user's followers

        for (String id in followersList) {
          var user = await FirebaseService.userByID(id);
          if (user == null) return;

          if (!user.postNotifications) return;

          // Creating instance of notificationmodel
          NotificationModel notificationModel = NotificationModel(
            id: MethodUtils.generatedId,
            type: notificationType,
            senderId: currentUser.userId,
            recipientId: id,
            postOrUserReference: notifiactionRef,
            timestamp: DateTime.now(),
          );

          // Sending notification to current user's followers
          await notifiactionRequest(
            title: "New Buzz",
            notificationBody: '${currentUser.username} just buzzed',
            pushToken: user.pushToken,
            type: notificationType.name,
            messageRef: notifiactionRef,
          );

          // Creating notification document refrence in firestore with the target user's id
          await FirebaseService.createNotification(notificationModel);
        }

        break;
      // Current user likes a post, send the notification to the post owner
      case NotificationType.postLiking:
        if (!targetUser.postNotifications) break;
        // if target user does not allowed notification for likes terminate it

        // Creating instance of notificationmodel
        NotificationModel notificationModel = NotificationModel(
          id: MethodUtils.generatedId,
          type: notificationType,
          senderId: currentUser.userId,
          recipientId: targetUser.userId,
          postOrUserReference: notifiactionRef,
          timestamp: DateTime.now(),
        );

        await notifiactionRequest(
          pushToken: targetUser.pushToken,
          notificationBody: '${currentUser.username} just liked your buzz!',
          title: "Like",
          type: notificationType.name,
          messageRef: notifiactionRef,
        );

        // Creating notification document refrence in firestore with the target user's id
        await FirebaseService.createNotification(notificationModel);

        break;

      // Current user commented a post, send the notification to the post owner
      case NotificationType.postComment:
        if (targetUser.commentNotifications) {
          // if target user allowed notification for comment
          // Creating instance of notificationmodel
          NotificationModel notificationModel = NotificationModel(
            id: MethodUtils.generatedId,
            type: notificationType,
            senderId: currentUser.userId,
            recipientId: targetUser.userId,
            postOrUserReference: notifiactionRef,
            timestamp: DateTime.now(),
          );

          await notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody:
                '${currentUser.username} just comment on your buzz!',
            title: "Comment",
            type: notificationType.name,
            messageRef: notifiactionRef,
          );

          // Creating notification document refrence in firestore with the target user's id
          await FirebaseService.createNotification(notificationModel)
              .whenComplete(() {
            toast("Created in the comment");
          });
        }
        break;

      // Current user saved a post, send the notification to the post owner
      case NotificationType.postSaved:
        if (targetUser.saveNotifications) {
          // if target user allowed notification for saves

          // Creating instance of notificationmodel
          NotificationModel notificationModel = NotificationModel(
            id: MethodUtils.generatedId,
            type: notificationType,
            senderId: currentUser.userId,
            recipientId: targetUser.userId,
            postOrUserReference: notifiactionRef,
            timestamp: DateTime.now(),
          );

          await notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody: '${currentUser.username} just saved your buzz!',
            title: targetUser.username,
            type: notificationType.name,
            messageRef: notifiactionRef,
          );

          // Creating notification document refrence in firestore with the target user's id
          await FirebaseService.createNotification(notificationModel);
        }
        break;

      // Current user follows the target user, send the notification to the post owner
      case NotificationType.userFollows:
        if (targetUser.followNotifications) {
          // if target user allowed notification for follows

          // Creating instance of notificationmodel
          NotificationModel notificationModel = NotificationModel(
            id: MethodUtils.generatedId,
            type: NotificationType.userFollows,
            senderId: currentUser.userId,
            recipientId: targetUser.userId,
            postOrUserReference: notifiactionRef,
            timestamp: DateTime.now(),
          );

          await notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody: '${currentUser.username} just followed you!',
            title: targetUser.username,
            type: NotificationType.userFollows.name,
            messageRef: notifiactionRef,
          );
          // Creating notification document refrence in firestore with the target user's id
          await FirebaseService.createNotification(notificationModel)
              .whenComplete(() {
            log("Created in the firestoreeeeeeeeeeeeeeeeeeeeee");
          });
        }
        break;
      // Current user create a group chat with the target user, send the notification to the target user
      case NotificationType.groupChat:
        if (groupChat != null) {
          // if groupchat is not null, send notification

          // Creating instance of notificationmodel
          NotificationModel notificationModel = NotificationModel(
            id: MethodUtils.generatedId,
            type: NotificationType.groupChat,
            senderId: currentUser.userId,
            recipientId: targetUser.userId,
            postOrUserReference: notifiactionRef,
            timestamp: DateTime.now(),
          );

          await notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody:
                '${currentUser.username} create a group chat with you called $groupChat',
            title: "Group chat",
            type: NotificationType.groupChat.name,
            messageRef: notifiactionRef,
          );

          // Creating notification document refrence in firestore with the target user's id
          await FirebaseService.createNotification(notificationModel)
              .whenComplete(() {
            log("Created in the a group");
          });
        }
        break;

      // Current user send a chat to the target user, send the notification to the target user
      case NotificationType.chat:
        if (msg != null && messageType != null) {
          // if message and messageType is not null, send notification
          // Creating instance of notificationmodel
          NotificationModel notificationModel = NotificationModel(
            id: MethodUtils.generatedId,
            type: NotificationType.chat,
            senderId: currentUser.userId,
            recipientId: targetUser.userId,
            postOrUserReference: notifiactionRef,
            timestamp: DateTime.now(),
          );

          _sendNotificationTokenForChat(
            messageRef: notifiactionRef,
            type: NotificationType.chat.name,
            messageType: messageType,
            msg: msg,
            weBuzzUser: targetUser,
          );

          // Creating notification document refrence in firestore with the target user's id
          await FirebaseService.createNotification(notificationModel);
        }
        break;
      case NotificationType.staff:
        // Creating instance of notificationmodel
        NotificationModel notificationModel = NotificationModel(
          id: MethodUtils.generatedId,
          type: notificationType,
          senderId: currentUser.userId,
          recipientId: targetUser.userId,
          postOrUserReference: notifiactionRef,
          timestamp: DateTime.now(),
        );

        await notifiactionRequest(
          pushToken: targetUser.pushToken,
          notificationBody: 'You\'re now officially staff of Webuzz.',
          title: targetUser.username,
          type: notificationType.name,
          messageRef: notifiactionRef,
        );

        // Creating notification document refrence in firestore with the target user's id
        await FirebaseService.createNotification(notificationModel);
        break;

      case NotificationType.classRep:
       // Creating instance of notificationmodel
        NotificationModel notificationModel = NotificationModel(
          id: MethodUtils.generatedId,
          type: notificationType,
          senderId: currentUser.userId,
          recipientId: targetUser.userId,
          postOrUserReference: notifiactionRef,
          timestamp: DateTime.now(),
        );

        await notifiactionRequest(
          pushToken: targetUser.pushToken,
          notificationBody: 'You\'re now officially class rep on Webuzz.',
          title: targetUser.username,
          type: notificationType.name,
          messageRef: notifiactionRef,
        );

        // Creating notification document refrence in firestore with the target user's id
        await FirebaseService.createNotification(notificationModel);
      break;
      case NotificationType.unknown:
        toast('Unkown Notification');
        break;
    }
  }
}
