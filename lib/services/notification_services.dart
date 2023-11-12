import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/message_enum_type.dart';
import '../model/we_buzz_user_model.dart';
import '../views/pages/dashboard/my_app_controller.dart';
import 'firebase_constants.dart';

class NotificationServices {
  // for sending push notifiaction
  static Future<void> sendNotificationTokenForChat(
      WeBuzzUser weBuzzUser, String msg, MessageType messageType) async {
    try {
      final body = {
        "to": weBuzzUser.pushToken,
        "notification": {
          "title": AppController.instance.currentUser!.name,
          messageType == MessageType.image ? "image" : "body": msg,
          // "body": msg,
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

  static Future<void> sendNotificationTokenForBuzz(
      WeBuzzUser weBuzzUser, String msg) async {
    try {
      final body = {
        "to": weBuzzUser.pushToken,
        "notification": {
          "title": AppController.instance.currentUser!.name,
          "body": msg,
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

  static Future<void> sendNotificationTokenForFollowSytme(
    WeBuzzUser weBuzzUser,
  ) async {
    try {
      final body = {
        "to": weBuzzUser.pushToken,
        "notification": {
          "title": weBuzzUser.name,
          "body":
              "${AppController.instance.currentUser!.name} just followed you",
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
}
