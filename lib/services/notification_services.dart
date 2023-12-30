import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/message_enum_type.dart';
import '../model/notification_model.dart';
import '../model/we_buzz_user_model.dart';
import '../views/pages/dashboard/my_app_controller.dart';
import 'firebase_constants.dart';

class NotificationServices {
  // for sending push notifiaction
  static Future<void> _sendNotificationTokenForChat(
    WeBuzzUser weBuzzUser,
    String msg,
    MessageType messageType,
  ) async {
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

  static Future<void> _notifiactionRequest({
    required String pushToken,
    required String notificationBody,
    required String title,
    MessageType? messageType,
  }) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": title,
          messageType != null && messageType == MessageType.image
              ? "image"
              : "body": notificationBody,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${AppController.instance.currentUser!.userId}",
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
    MessageType? messageType,
  }) async {
    // Current user data
    final currentUser = AppController.instance.weBuzzUsers.firstWhere(
      (user) => user.userId == FirebaseAuth.instance.currentUser!.uid,
    );

    // All users of we buzz, except me
    final allUsers = AppController.instance.weBuzzUsers
        .where((user) => user.userId != currentUser.userId)
        .toList();

    switch (notificationType) {
      // Post creation by current user, send notification to his followers
      case NotificationType.postCreation:

        // Loop through all the current user's followers
        for (String userId in currentUser.followers) {
          WeBuzzUser user = allUsers.firstWhere(
              (user) => user.userId == userId && user.postNotifications);

          await _notifiactionRequest(
            title: "New Buzz",
            notificationBody: '${currentUser.username} just buzzed',
            pushToken: user.pushToken,
          );
        }

        break;
      // Current user likes a post, send the notification to the post owner
      case NotificationType.postLiking:
        if (targetUser.likeNotifications) {
          // if target user allowed notification for likes
          await _notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody: '${currentUser.username} just liked your buzz!',
            title: "Like",
          );
        }

        break;

      // Current user commented a post, send the notification to the post owner
      case NotificationType.postComment:
        if (targetUser.commentNotifications) {
          // if target user allowed notification for comment
          await _notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody:
                '${currentUser.username} just comment on your buzz!',
            title: "Comment",
          );
        }
        break;

      // Current user saved a post, send the notification to the post owner
      case NotificationType.postSaved:
        if (targetUser.saveNotifications) {
          // if target user allowed notification for saves
          await _notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody: '${currentUser.username} just saved your buzz!',
            title: targetUser.username,
          );
        }
        break;

      // Current user follows the target user, send the notification to the post owner
      case NotificationType.userFollows:
        if (targetUser.followNotifications) {
          // if target user allowed notification for follows
          await _notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody: '${currentUser.username} just followed you!',
            title: targetUser.username,
          );
        }
        break;
      // Current user create a group chat with the target user, send the notification to the target user
      case NotificationType.groupChat:
        if (groupChat != null) {
          // if groupchat is not null, send notification
          await _notifiactionRequest(
            pushToken: targetUser.pushToken,
            notificationBody:
                '${currentUser.username} create a group chat with you called $groupChat',
            title: "Group chat",
          );
        }
        break;
      // Current user send a chat to the target user, send the notification to the target user
      case NotificationType.chat:
        if (msg != null && messageType != null) {
          // if message and messageType is not null, send notification
          _sendNotificationTokenForChat(targetUser, msg, messageType);
        }
        break;
      case NotificationType.staff:
        await _notifiactionRequest(
          pushToken: targetUser.pushToken,
          notificationBody: 'You\'re now officially staff of Webuzz.',
          title: targetUser.username,
        );
        break;
      case NotificationType.unknown:
        toast('Unkown Notification');
        break;
    }
  }
}
